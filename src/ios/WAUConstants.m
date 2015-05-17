//
//  Constants.m
//  Advertiser
//
//  Created by Toma Popov on 5/14/15.
//  Copyright (c) 2015 tomapopov. All rights reserved.
//

#import "WAUConstants.h"

@implementation WAUConstants

+ (CommandType)commandTypeEnumFromString:(NSString *)string {
    if ([string isEqualToString:kCommandRefresh]) {
        return CommandTypeRefresh;
    } else if ([string isEqualToString:kCommandUpdate]) {
        return CommandTypeUpdate;
    } else if  ([string isEqualToString:kCommandAcknowledge]) {
        return CommandTypeAcknowledge;
    } else {
        DLog(@"Unexpected value.");
        return CommandTypeUndefined;
    }
}

+ (NSString *)commandTypeStringFromEnum:(CommandType)type {
    switch (type) {
        case CommandTypeRefresh:
            return kCommandRefresh;
        case CommandTypeAcknowledge:
            return kCommandAcknowledge;
        case CommandTypeUpdate:
            return kCommandUpdate;
        default:
            DLog(@"Unexpected value.");
            return kCommandUndefined;
            break;
    }
}

@end
