//
//  Command.h
//  Advertiser
//
//  Created by Toma Popov on 5/14/15.
//  Copyright (c) 2015 tomapopov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAUConstants.h"

@interface WAUCommand : NSObject

+ (instancetype)generateFromSocketMessage:(NSString *)message;

@property (assign, nonatomic, readonly) CommandType type;
@property (strong, nonatomic, readonly) id payload;

@end
