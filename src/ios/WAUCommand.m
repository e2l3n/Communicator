//
//  Command.m
//  Advertiser
//
//  Created by Toma Popov on 5/14/15.
//  Copyright (c) 2015 tomapopov. All rights reserved.
//

#import "WAUCommand.h"
@interface WAUCommand ()

@property (assign, nonatomic) CommandType type;
@property (strong, nonatomic) id payload;

@end

@implementation WAUCommand

+ (instancetype)generateFromSocketMessage:(NSString *)message {
    NSRange separatorRange = [message rangeOfString:kSeparatorIndicator];
    NSString *commandStr = [message substringToIndex:separatorRange.location];
    NSString *payloadStr = [message substringFromIndex:separatorRange.location + separatorRange.length];
    
    WAUCommand *newCommand = nil;
    
    if ([commandStr rangeOfString:kCommandIndicator].location != NSNotFound &&
        [payloadStr rangeOfString:kPayloadIndicator].location != NSNotFound) {
        newCommand = [WAUCommand new];
        newCommand.type = [WAUConstants commandTypeEnumFromString:[commandStr substringFromIndex:kCommandIndicator.length]];
        newCommand.payload = [payloadStr substringFromIndex:kPayloadIndicator.length];
    }
    
    return newCommand;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n<COMMAND Description>\nclass: %@\ncommand: %@\npayload: %@",
            NSStringFromClass(WAUCommand.class),
            [WAUConstants commandTypeStringFromEnum:self.type],
            self.payload];
}

@end
