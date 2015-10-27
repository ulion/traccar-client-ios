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

+ (NSURLRequest *)formatPostion:(TCPosition *)position address:(NSString *)address port:(long)port {
    NSURL *url = [NSURL ks_URLWithScheme:@"http"
                                    host:[NSString stringWithFormat:@"%@:%ld", address, port]
                                    path:@"/"
                         queryParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                          position.deviceId, @"id",
                                          [NSString stringWithFormat:@"%lld", (long long) (1000 * [position.time timeIntervalSince1970])], @"timestamp",
                                          [NSString stringWithFormat:@"%f", position.latitude], @"lat",
                                          [NSString stringWithFormat:@"%f", position.longitude], @"lon",
                                          [NSString stringWithFormat:@"%g", position.horizontalAccuracy], @"hacc",
                                          [NSString stringWithFormat:@"%g", position.verticalAccuracy], @"vacc",
                                          [NSString stringWithFormat:@"%g", position.speed], @"speed",
                                          [NSString stringWithFormat:@"%g", position.course], @"bearing",
                                          [NSString stringWithFormat:@"%g", position.altitude], @"altitude",
                                          [NSString stringWithFormat:@"%g", position.battery], @"batt",
                                          nil]];
    return [NSURLRequest requestWithURL:url];
}

+ (NSURLRequest *)formatPostions:(NSArray *)positions address:(NSString *)address port:(long)port {
    if (positions.count == 1)
        return [TCProtocolFormatter formatPostion:[positions objectAtIndex:0] address:address port:port];
    NSMutableArray *reqs = [NSMutableArray array];
    for (TCPosition *position in positions) {
        NSString *req = [NSURL ks_queryWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      position.deviceId, @"id",
                                                      [NSString stringWithFormat:@"%lld", (long long) (1000 * [position.time timeIntervalSince1970])], @"timestamp",
                                                      [NSString stringWithFormat:@"%f", position.latitude], @"lat",
                                                      [NSString stringWithFormat:@"%f", position.longitude], @"lon",
                                                      [NSString stringWithFormat:@"%g", position.horizontalAccuracy], @"hacc",
                                                      [NSString stringWithFormat:@"%g", position.verticalAccuracy], @"vacc",
                                                      [NSString stringWithFormat:@"%g", position.speed], @"speed",
                                                      [NSString stringWithFormat:@"%g", position.course], @"bearing",
                                                      [NSString stringWithFormat:@"%g", position.altitude], @"altitude",
                                                      [NSString stringWithFormat:@"%g", position.battery], @"batt",
                                                       nil]];
        [reqs addObject:req];
    }
    NSString *body = [reqs componentsJoinedByString:@"\n"];
    NSURL *url = [NSURL ks_URLWithScheme:@"http"
                                    host:[NSString stringWithFormat:@"%@:%ld", address, port]
                                    path:@"/"
                         queryParameters:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:[body UTF8String] length:strlen([body UTF8String])]];
    return request;
}

@end
