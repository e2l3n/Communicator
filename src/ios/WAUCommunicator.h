//
//  Communicator.h
//  Advertiser
//
//  Created by Toma Popov on 5/13/15.
//  Copyright (c) 2015 tomapopov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

#import "WAUConstants.h"

#import "WAUCommand.h"

@interface WAUCommunicator : CDVPlugin

- (void)broadcast:(CDVInvokedUrlCommand*)command;
- (void)listen:(CDVInvokedUrlCommand*)command;

@end
