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

@property (nonatomic, assign) bool updatePaused;

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, assign) long period;
@property (nonatomic, assign) long minAccuracy;
@property (nonatomic, assign) long distanceThreshold;
@property (nonatomic, assign) long speedDeltaThreshold;
@property (nonatomic, assign) long courseDeltaThreshold;

@end

@implementation TCPositionProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        // IOS 9 property to allow suspended app get location notification.
        if ([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
            BOOL yes = YES;
            NSMethodSignature* signature = [[CLLocationManager class] instanceMethodSignatureForSelector: @selector( setAllowsBackgroundLocationUpdates: )];
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
            [invocation setTarget: self.locationManager];
            [invocation setSelector: @selector( setAllowsBackgroundLocationUpdates: ) ];
            [invocation setArgument: &yes atIndex: 2];
            [invocation invoke];
        }
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        NSLog(@"Location manager auth status: %d", status);
        
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;

        self.updatePaused = NO;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.deviceId = [userDefaults stringForKey:@"device_id_preference"];
        self.period = [userDefaults integerForKey:@"frequency_preference"];
        self.minAccuracy = [userDefaults integerForKey:@"min_accuracy_preference"];
        self.distanceThreshold = [userDefaults integerForKey:@"distance_threshold_preference"];
        self.speedDeltaThreshold = [userDefaults integerForKey:@"speed_delta_threshold_preference"]/3.6;
        self.courseDeltaThreshold = [userDefaults integerForKey:@"course_delta_threshold_preference"];
    }
    return self;
}

- (void)startUpdates {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdates {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
    self.updatePaused = NO;
}

- (double)getBatteryLevel {
    UIDevice *device = [UIDevice currentDevice];
    return device.batteryLevel * 100;
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidPauseLocationUpdates");
    [TCStatusViewController addMessage:NSLocalizedString(@"Location updates paused", @"")];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.updatePaused = YES;
    // XXX: quit the app, so it will restart when detected significant location change?
    //      currently after it's paused, it never get resumed even if it changes significantly.
    // abort();
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidResumeLocationUpdates");
    [TCStatusViewController addMessage:NSLocalizedString(@"Location updates resumed", @"")];
    self.updatePaused = NO;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    if (self.updatePaused) {
        [TCStatusViewController addMessage:NSLocalizedString(@"Paused but got a location update", @"")];
        [self.locationManager startUpdatingLocation];
    }
    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 0 || (self.minAccuracy > 0 && location.horizontalAccuracy > self.minAccuracy) || (self.lastLocation && [location.timestamp isEqualToDate:self.lastLocation.timestamp]))
            continue;
        if (!self.lastLocation ||
            location.horizontalAccuracy < self.lastLocation.horizontalAccuracy ||
            (location.speed >= 0 && (self.lastLocation.speed < 0 || (self.speedDeltaThreshold > 0 && ABS(location.speed - self.lastLocation.speed) >= self.speedDeltaThreshold))) ||
            (location.course >= 0 && location.speed >= self.speedDeltaThreshold && (self.lastLocation.course < 0 || (self.courseDeltaThreshold > 0 && ABS(location.course - self.lastLocation.course) >= self.courseDeltaThreshold))) ||
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
