//
//  DiceLogger.m
//  Dice
//
//  Created by Arpan Ghosh on 1/23/14.
//  Copyright (c) 2014 Redeye. All rights reserved.
//

#import "DiceLogger.h"

@implementation DiceLogger

// Logging convenience method
+(void)logWithClass:(Class)class Message:(NSString *)message andError:(NSError *)error{
    NSLog(@"%@ : %@\n%@ : %@", NSStringFromClass(class), message,
          [error localizedDescription],
          [error localizedFailureReason]);
}

@end
