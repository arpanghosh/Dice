//
//  DemoCrumbAppLogger.m
//  DemoIOSAppUsingCrumb
//
//  Created by Arpan Ghosh on 1/23/14.
//  Copyright (c) 2014 Tracktor Beam. All rights reserved.
//

#import "DemoCrumbAppLogger.h"

@implementation DemoCrumbAppLogger

// Logging convenience method
+(void)logWithMessage:(NSString *)message andError:(NSError *)error{
    NSLog(@"%@ : %@\n%@ : %@", NSStringFromClass([self class]), message,
          [error localizedDescription],
          [error localizedFailureReason]);
}

@end
