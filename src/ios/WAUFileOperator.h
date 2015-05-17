//
//  WAUFileOperator.h
//  Communicator
//
//  Created by Toma Popov on 5/15/15.
//
//

#import <Foundation/Foundation.h>

@interface WAUFileOperator : NSObject

+ (instancetype)sharedInstance;

/**
 Stores asynchronously data.
 A completion block is passed at the end.
 **/
- (void)storeData:(NSData *)data
         filename:(NSString *)filename
  completionQueue:(NSOperationQueue *)completionQueue
       completion:(void (^)(NSError *error))completion;

/**
 The method searches in the defined local cache dir for a file matchig the given.
 A completion block is executed at the end.
 **/
- (void)loadDataForFileName:(NSString *)filename
            completionQueue:(NSOperationQueue *)completionQueue
                 completion:(void (^)(NSData *result, NSError *error))completion;

/**
 Deletes asynchronously specific file corresponding to the filename param.
 A completion block is passed at the end.
 **/
- (void)removeCachedDataForFilename:(NSString *)filename
                        ofClassType:(Class)classType
                    completionQueue:(NSOperationQueue *)completionQueue
                         completion:(void (^)(NSError *error))completion;

/**
 Deletes asynchronously all cached files.
 **/
- (void)performAllFilesCleanUp;

@end
