//
//  CDEPersistentStoreImporter.m
//  Ensembles
//
//  Created by Drew McCormack on 21/09/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDEPersistentStoreImporter.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventStore.h"
#import "CDEEventBuilder.h"
#import "CDEEventRevision.h"

@implementation CDEPersistentStoreImporter

@synthesize storeDescription = storeDescription;
@synthesize eventStore = eventStore;
@synthesize managedObjectModel = managedObjectModel;

- (id)initWithPersistentStoreDescription:(NSPersistentStoreDescription*)newStoreDescription managedObjectModel:(NSManagedObjectModel *)newModel eventStore:(CDEEventStore *)newEventStore;
{
    self = [super init];
    if (self) {
        storeDescription = [newStoreDescription copy];
        eventStore = newEventStore;
        managedObjectModel = newModel;
    }
    return self;
}

- (void)importWithCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelVerbose, @"Importing persistent store");
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context performBlockAndWait:^{
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self->managedObjectModel];
        context.persistentStoreCoordinator = coordinator;
        context.undoManager = nil;
        
        if (!storeDescription.options) {
            [storeDescription setOption:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
            [storeDescription setOption:@YES forKey:NSInferMappingModelAutomaticallyOption];
        }
        
        [(id)coordinator lock];
        
        __weak typeof(self) weakSelf = self;
        __strong typeof(coordinator) strongCoordinator = coordinator;
        
        [coordinator addPersistentStoreWithDescription:storeDescription completionHandler:^(NSPersistentStoreDescription * _Nonnull desc, NSError * _Nonnull error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [(id)strongCoordinator unlock];
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(error);
                });
                return;
            }
            
            [strongSelf _importWithCompletionWithContext:context completion:completion];
        }];
    }];
}

- (void)_importWithCompletionWithContext:(NSManagedObjectContext*)context completion:(CDECompletionBlock)completion {
    NSManagedObjectContext *eventContext = eventStore.managedObjectContext;
    CDEEventBuilder *eventBuilder = [[CDEEventBuilder alloc] initWithEventStore:self.eventStore];
    eventBuilder.ensemble = self.ensemble;
    [eventBuilder makeNewEventOfType:CDEStoreModificationEventTypeBaseline uniqueIdentifier:nil];
    [eventBuilder performBlockAndWait:^{
        // Use distant past for the time, so the leeched data gets less
        // priority than existing data.
        eventBuilder.event.globalCount = 0;
        eventBuilder.event.timestamp = [[NSDate distantPast] timeIntervalSinceReferenceDate];
    }];
    
    NSMutableSet *allObjects = [[NSMutableSet alloc] initWithCapacity:1000];
    [context performBlock:^{
        for (NSEntityDescription *entity in self->managedObjectModel) {
            NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:entity.name];
            fetch.fetchBatchSize = 100;
            fetch.includesSubentities = NO;
            
            NSError *localError = nil;
            NSArray *objects = [context executeFetchRequest:fetch error:&localError];
            if (!objects) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(localError);
                });
                return;
            }
            [allObjects addObjectsFromArray:objects];
        }
        
        [eventBuilder addChangesForInsertedObjects:allObjects objectsAreSaved:YES inManagedObjectContext:context];
        
        [eventContext performBlock:^{
            NSError *localError = nil;
            [eventBuilder finalizeNewEvent];
            [eventContext save:&localError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(localError);
            });
        }];
    }];
}

@end
