//
//  Constants.h
//  Advertiser
//
//  Created by Toma Popov on 5/14/15.
//  Copyright (c) 2015 tomapopov. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef __IPHONE_7_0
#warning "This project uses features only available in iOS SDK 7.0 and later."
#endif

////use DLog for Debug logging
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define LogFunction()  NSLog(@" -- %s [Line %d] -- ", __PRETTY_FUNCTION__, __LINE__)
#else
#define DLog(fmt, ...)
#define LogFunction()
#endif

static NSString * const kBroadcastStart = @"WAUBroadcastStart";
static NSString * const kBroadcastStop = @"WAUBroadcastStop";

static NSString * const kListenStart = @"WAUListenStart";
static NSString * const kListenStop = @"WAUListenStop";

static NSString * const kCacheOptionEnable = @"WAUCacheEnabled";
static NSString * const kCacheOptionDisable = @"WAUCacheDisable";

typedef NS_ENUM(NSUInteger, ListenOption) {
    ListenOptionStart,
    ListenOptionStop
};

typedef NS_ENUM(NSUInteger, CommandType) {
    CommandTypeUpdate,
    CommandTypeRefresh,
    CommandTypeAcknowledge,
    CommandTypeUndefined
};

static NSString * const kFilenameHTML = @"FilenameHTML";
static NSString * const kServicePrefix = @"wau";

static NSString * const kCommandRefresh = @"WAURefresh";
static NSString * const kCommandUpdate = @"WAUUpdate";
static NSString * const kCommandAcknowledge = @"WAUAcknowledge";
static NSString * const kCommandUndefined = @"WAU?";

/*
    Server sent commands are expected to be structured in the following format:
    command:<command>;payload:<payload>
*/

static NSString * const kCommandIndicator = @"command:";
static NSString * const kPayloadIndicator = @"payload:";
static NSString * const kSeparatorIndicator = @";";

@interface WAUConstants : NSObject

+ (CommandType)commandTypeEnumFromString:(NSString *)string;
+ (NSString *)commandTypeStringFromEnum:(CommandType)type;

@end
