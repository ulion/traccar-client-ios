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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

@interface TCPosition : NSManagedObject

@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSDate *time;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double altitude;
@property (nonatomic) double horizontalAccuracy;
@property (nonatomic) double verticalAccuracy;
@property (nonatomic) double speed;
@property (nonatomic) double course;
@property (nonatomic) double battery;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)setLocation:(CLLocation *)location;

@end
