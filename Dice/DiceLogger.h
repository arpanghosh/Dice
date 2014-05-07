//
//  DiceLogger.h
//  Dice
//
//  Created by Arpan Ghosh on 1/23/14.
//  Copyright (c) 2014 Redeye. All rights reserved.
//

@interface DiceLogger : NSObject

+(void)logWithClass:(Class)class Message:(NSString *)message andError:(NSError *)error;

@end

