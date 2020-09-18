//
//  Ensembles.h
//  Ensembles Mac
//
//  Created by Damien DeVille on 3/7/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CDEAsynchronousOperation.h"
#import "CDEAsynchronousTaskQueue.h"
#import "CDEAvailabilityMacros.h"
#import "CDECloudDirectory.h"
#import "CDECloudFile.h"
#import "CDECloudFileSystem.h"
#import "CDEDefines.h"
#import "CDEFileDownloadOperation.h"
#import "CDEFileUploadOperation.h"
#import "CDEFoundationAdditions.h"
#import "CDEICloudFileSystem.h"
#import "CDELocalCloudFileSystem.h"
#import "CDEPersistentStoreEnsemble.h"
#import "NSMapTable+CDEAdditions.h"
#import "NSManagedObjectModel+CDEAdditions.h"

// For test purpose, should remove in future
#import "CDEEventRevision.h"
#import "CDEObjectChange.h"
#import "CDESaveMonitor.h"
#import "CDEStoreModificationEvent.h"
#import "CDEPropertyChangeValue.h"
#import "CDEGlobalIdentifier.h"
#import "CDERevision.h"
#import "CDEEventBuilder.h"
#import "CDEEventStore.h"
#import "CDERevisionSet.h"
#import "CDERebaser.h"
#import "CDEEventMigrator.h"
