//
//  WAUCommandStorage.h
//  Communicator
//
//  Created by Toma Popov on 5/17/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface WAUInvokedUrlCommandStorage : NSObject

- (void)addCommand:(CDVInvokedUrlCommand *)command;

- (void)sendPluginResult:(CDVPluginResult *)result
       toCommandDelegate:(id<CDVCommandDelegate> )delegate
  commandTypesOfInterest:(NSArray *)array;


@end
