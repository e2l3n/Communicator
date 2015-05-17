//
//  WAUCommandStorage.m
//  Communicator
//
//  Created by Toma Popov on 5/17/15.
//
//

#import "WAUInvokedUrlCommandStorage.h"
@interface WAUInvokedUrlCommandStorage ()

@property (nonatomic, strong) NSMutableArray *commands;

@end

@implementation WAUInvokedUrlCommandStorage

- (instancetype)init {
    if (self = [super init]) {
        self.commands = NSMutableArray.new;
    }
    
    return self;
}

- (void)addCommand:(CDVInvokedUrlCommand *)command {
   __block BOOL shouldAdd = YES;
    [self.commands enumerateObjectsUsingBlock:^(CDVInvokedUrlCommand *cmd, NSUInteger idx, BOOL *stop) {
        if ([command.callbackId isEqualToString:cmd.callbackId]) {
            shouldAdd = NO;
            *stop = YES;
        }
    }];
    
    if (shouldAdd) {
        [self.commands addObject:command];
    }
}

- (void)sendPluginResult:(CDVPluginResult *)result
       toCommandDelegate:(id<CDVCommandDelegate> )delegate
  commandTypesOfInterest:(NSArray *)types {
    NSMutableArray *commandsToRemove = NSMutableArray.new;
    [self.commands enumerateObjectsUsingBlock:^(CDVInvokedUrlCommand *cmd, NSUInteger idx, BOOL *stop) {
        [types enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
            if ([cmd.arguments.firstObject isEqualToString:type]) {
                [delegate sendPluginResult:result callbackId:cmd.callbackId];
                [commandsToRemove addObject:cmd];
                *stop = YES;
            }
        }];
    }];
    
    [self.commands removeObjectsInArray:commandsToRemove];
}

@end
