//
//  Communicator.m
//  Advertiser
//
//  Created by Toma Popov on 5/13/15.
//  Copyright (c) 2015 tomapopov. All rights reserved.
//

#import "WAUCommunicator.h"
#import <UIKit/UIKit.h>
#import "WAUCommand.h"
#import "WAUFileOperator.h"
#import "WAUInvokedUrlCommandStorage.h"
#import "PSWebSocketServer.h"


//Private constants.
static CGFloat const kTimeOut = 15.0f; // in seconds.
static NSUInteger const kPort = 4567;// TODO: Find and acquire a free system port.

@interface WAUCommunicator () <NSNetServiceDelegate, PSWebSocketServerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) NSNetService *netService;
@property (nonatomic, strong) PSWebSocketServer *server;
@property (strong, nonatomic) NSString *htmlContent;
@property (assign, nonatomic) BOOL isCachingEnabled;
@property (strong, nonatomic) WAUInvokedUrlCommandStorage *invokedUrlCommandStorage;

@end

@implementation WAUCommunicator

#pragma mark - Initialization

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView {
    self = [super initWithWebView:theWebView];
    if (self) {
        self.invokedUrlCommandStorage = WAUInvokedUrlCommandStorage.new;
        self.webView.delegate = self;
        
        NSString *serviceName = [NSString stringWithFormat:@"%@-%@", kServicePrefix, UIDevice.currentDevice.name];
        self.netService = [[NSNetService alloc] initWithDomain:@""
                                                          type:@"_http._tcp."
                                                          name:serviceName
                                                          port:kPort];
        if (self.netService) {
            [self.netService scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
            [self.netService setDelegate:self];
        } else {
            DLog(@"Failed to prepare service advertisement.");
        }
        
        self.server = [PSWebSocketServer serverWithHost:nil port:kPort];
        self.server.delegate = self;
    }
    return self;
}

#pragma mark - Public methods

- (void)broadcast:(CDVInvokedUrlCommand*)command {
    NSString *broadcastOpt = command.arguments.firstObject;
    
    if (![broadcastOpt isKindOfClass:NSString.class] ||
        (![broadcastOpt isEqualToString:kBroadcastStart] && ![broadcastOpt isEqualToString:kBroadcastStop])) {
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Invalid args."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        return;
    }
    
    if (!self.netService) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Internal error."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        return;
    }
    
    if ([broadcastOpt isEqualToString:kBroadcastStart]) {
        [self.netService startMonitoring];
        [self.netService resolveWithTimeout:kTimeOut];
        [self.netService publish];
    } else if ([broadcastOpt isEqualToString:kBroadcastStop]) {
        [self.netService stopMonitoring];
        [self.netService stop];
    }
    
    [self.invokedUrlCommandStorage addCommand:command];
}

- (void)listen:(CDVInvokedUrlCommand*)command {
    NSString *listenOpt = command.arguments.firstObject;
    
    if (![listenOpt isKindOfClass:NSString.class] ||
        (![listenOpt isEqualToString:kListenStart] && ![listenOpt isEqualToString:kListenStop])) {
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Invalid args."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        return;
    }
    
    if (!self.server) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Internal error."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        return;
    }
    
    if ([listenOpt isEqualToString:kListenStart]) {
        [self.server start];
    } else if ([listenOpt isEqualToString:kListenStop]) {
        [self.server stop];
    }
    
    [self.invokedUrlCommandStorage addCommand:command];
}

- (void)enableCaching:(CDVInvokedUrlCommand*)command {
    NSString *cachingOpt = command.arguments.firstObject;
    
    if (![cachingOpt isKindOfClass:NSString.class] ||
        (![cachingOpt isEqualToString:kCacheOptionEnable] && ![cachingOpt isEqualToString:kCacheOptionDisable])) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Invalid args."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        return;
    }
    
    self.isCachingEnabled = [cachingOpt isEqualToString:kCacheOptionEnable];
    
    if (!self.isCachingEnabled) {
        [WAUFileOperator.sharedInstance performAllFilesCleanUp];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

#pragma mark - NSNetServiceDelegate

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:@"Net service did publish."];
    [self.invokedUrlCommandStorage sendPluginResult:pluginResult
                                  toCommandDelegate:self.commandDelegate
                             commandTypesOfInterest:@[kBroadcastStart]];
}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                      messageAsString:errorDict.description];
    [self.invokedUrlCommandStorage sendPluginResult:pluginResult
                                  toCommandDelegate:self.commandDelegate
                             commandTypesOfInterest:@[kBroadcastStart]];
}

/* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
 */
- (void)netServiceDidStop:(NSNetService *)sender {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:@"Net service did stop."];
    [self.invokedUrlCommandStorage sendPluginResult:pluginResult
                                  toCommandDelegate:self.commandDelegate
                             commandTypesOfInterest:@[kBroadcastStop]];
    
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    DLog(@"Server did start.");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:@"Server did start."];
    [self.invokedUrlCommandStorage sendPluginResult:pluginResult
                                  toCommandDelegate:self.commandDelegate
                             commandTypesOfInterest:@[kListenStart]];
}

- (void)serverDidStop:(PSWebSocketServer *)server {
    DLog(@"Server did stop.");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:@"Server did stop."];
    [self.invokedUrlCommandStorage sendPluginResult:pluginResult
                                  toCommandDelegate:self.commandDelegate
                             commandTypesOfInterest:@[kListenStop]];
}

- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    DLog(@"Server should accept request: %@", request);
    return YES;
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    WAUCommand *command = [WAUCommand generateFromSocketMessage:message];
    switch (command.type) {
        case CommandTypeUpdate: {
            if (![command.payload isKindOfClass:NSString.class]) {
                return;
            }
            
            NSData* data = [command.payload dataUsingEncoding:NSUTF8StringEncoding];
            [WAUFileOperator.sharedInstance storeData:data filename:kFilenameHTML
                                      completionQueue:NSOperationQueue.currentQueue
                                           completion:nil];
            
            self.htmlContent = command.payload;
        }
            break;
        case CommandTypeRefresh:
            if (self.htmlContent) {
                [self.webView loadHTMLString:self.htmlContent baseURL:nil];
            } else {
                __weak WAUCommunicator *weakSelf = self;
                
                void (^opBlock)(id, NSError *) = ^void(id result, NSError *error) {
                    if (result && !error) {
                        weakSelf.htmlContent = [[NSString alloc] initWithData:result
                                                                     encoding:NSUTF8StringEncoding];
                        [weakSelf.webView loadHTMLString:weakSelf.htmlContent baseURL:nil];
                    }
                };
                
                if (self.isCachingEnabled) {
                    opBlock(self.htmlContent, nil);
                    return;
                }
                
                [WAUFileOperator.sharedInstance loadDataForFileName:kFilenameHTML
                                                    completionQueue:NSOperationQueue.currentQueue
                                                         completion:^(NSData *result, NSError *error) {
                                                             opBlock(result, error);
                                                         }];
            }
            
            break;
            
        default:
            break;
    }
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    DLog(@"Server websocket did open");
}

- (void)server:(PSWebSocketServer *)server
     webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    DLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}

- (void)server:(PSWebSocketServer *)server
     webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
    [self.invokedUrlCommandStorage sendPluginResult:pluginResult
                                  toCommandDelegate:self.commandDelegate
                             commandTypesOfInterest:@[kListenStart, kListenStop]];
}

#pragma mark - Responding to device events

- (void)dispose {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                      messageAsString:@"Screen was disposed."];
    [self.invokedUrlCommandStorage sendPluginResult:pluginResult
                                  toCommandDelegate:self.commandDelegate
                             commandTypesOfInterest:@[kBroadcastStart, kBroadcastStop, kListenStart, kListenStop]];
}

@end
