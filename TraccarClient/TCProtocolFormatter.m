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

#import "TCProtocolFormatter.h"
#import "KSURLQueryUtilities.h"

@implementation TCProtocolFormatter

+ (NSURL *)formatPostion:(TCPosition *)position address:(NSString *)address port:(long)port {
    return [NSURL ks_URLWithScheme:@"http"
                              host:[NSString stringWithFormat:@"%@:%ld", address, port]
                              path:@"/"
                   queryParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                    position.deviceId, @"id",
                                    [NSString stringWithFormat:@"%ld", (long) [position.time timeIntervalSince1970]], @"timestamp",
                                    [NSString stringWithFormat:@"%g", position.latitude], @"lat",
                                    [NSString stringWithFormat:@"%g", position.longitude], @"lon",
                                    [NSString stringWithFormat:@"%g", position.speed], @"speed",
                                    [NSString stringWithFormat:@"%g", position.course], @"bearing",
                                    [NSString stringWithFormat:@"%g", position.altitude], @"altitude",
                                    [NSString stringWithFormat:@"%g", position.battery], @"batt",
                                    nil]];
}

@end
