//
//  CDEPersistentStoreImporter.h
//  Ensembles
//
//  Created by Drew McCormack on 21/09/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDEDefines.h"

@class CDEEventStore;
@class CDEPersistentStoreEnsemble;

@interface CDEPersistentStoreImporter : NSObject

@property (nonatomic, strong, readwrite) NSPersistentStoreDescription* storeDescription;
@property (nonatomic, strong, readonly) CDEEventStore *eventStore;
@property (nonatomic, weak, readwrite) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

- (id)initWithPersistentStoreDescription:(NSPersistentStoreDescription*)newStoreDescription managedObjectModel:(NSManagedObjectModel *)model eventStore:(CDEEventStore *)eventStore;

- (void)importWithCompletion:(CDECompletionBlock)completion;

@end
