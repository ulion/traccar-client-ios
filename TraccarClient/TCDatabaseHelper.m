//
// Copyright 2015 Anton Tananaev (anton.tananaev@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TCDatabaseHelper.h"
#import "TCAppDelegate.h"

@implementation TCDatabaseHelper

+ (NSManagedObjectContext *)managedObjectContext {
    UIApplication *application = [UIApplication sharedApplication];
    TCAppDelegate *delegate = (TCAppDelegate *) application.delegate;
    return delegate.managedObjectContext;
}

- (instancetype)init {
    NSManagedObjectContext *managedObjectContext = [TCDatabaseHelper managedObjectContext];
    return [self initWithManagedObjectContext:managedObjectContext];
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    if (self) {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}

- (TCPosition *)selectPosition {
    NSArray *fetchedObjects = [self selectPositions:1];
    if (fetchedObjects && fetchedObjects.count) {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}

- (void)deletePosition:(TCPosition *)position {
    [self.managedObjectContext deleteObject:position];
}

- (NSArray *)selectPositions:(NSUInteger)fetchLimit {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Position"];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO]];
    fetchRequest.fetchLimit = fetchLimit;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (fetchedObjects && fetchedObjects.count) {
        return fetchedObjects;
    }
    return nil;
}

- (void)deletePositions:(NSArray *)positions {
    for (TCPosition *position in positions) {
        [self.managedObjectContext deleteObject:position];
    }
}

@end
