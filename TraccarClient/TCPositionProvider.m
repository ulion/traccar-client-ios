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

#import "TCPositionProvider.h"
#import <CoreLocation/CoreLocation.h>
#import "TCDatabaseHelper.h"

@interface TCPositionProvider () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, readonly) double batteryLevel;

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, assign) long period;
@property (nonatomic, assign) long minAccuracy;
@property (nonatomic, assign) long distanceThreshold;

@end

@implementation TCPositionProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.deviceId = [userDefaults stringForKey:@"device_id_preference"];
        self.period = [userDefaults integerForKey:@"frequency_preference"];
        self.minAccuracy = [userDefaults integerForKey:@"min_accuracy_preference"];
        self.distanceThreshold = [userDefaults integerForKey:@"distance_threshold_preference"];
    }
    return self;
}

- (void)startUpdates {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdates {
    [self.locationManager stopUpdatingLocation];
}

- (double)getBatteryLevel {
    UIDevice *device = [UIDevice currentDevice];
    return device.batteryLevel * 100;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {

    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 0 || (self.minAccuracy > 0 && location.horizontalAccuracy > self.minAccuracy))
            continue;
        if (!self.lastLocation ||
            location.horizontalAccuracy < self.lastLocation.horizontalAccuracy ||
            [location.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] >= self.period ||
            (self.distanceThreshold > 0 && [location distanceFromLocation:self.lastLocation] >= self.distanceThreshold)
            ) {
            
            TCPosition *position = [[TCPosition alloc] initWithManagedObjectContext:[TCDatabaseHelper managedObjectContext]];
            position.deviceId = self.deviceId;
            position.location = location;
            position.battery = [self getBatteryLevel];
            
            [self.delegate didUpdatePosition:position];
            self.lastLocation = location;
        }
    }
}

@end
