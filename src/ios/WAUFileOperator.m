//
//  WAUFileOperator.m
//  Communicator
//
//  Created by Toma Popov on 5/15/15.
//
//

#import "WAUFileOperator.h"
#import "NSError+WAU.h"

@interface WAUFileOperator ()

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSString *cachesDirectoryPath;

@end

@implementation WAUFileOperator

#pragma mark - Public Interface -
#pragma mark Initialization
+ (instancetype)sharedInstance {
    static WAUFileOperator *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;//Serial queue
        self.cachesDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:self.cachesDirectoryPath]) {
            [manager createDirectoryAtPath:self.cachesDirectoryPath
               withIntermediateDirectories:YES
                                attributes:nil error:NULL];
        }
    }
    
    return self;
}


#pragma mark Public Interface
- (void)storeData:(NSData *)data
         filename:(NSString *)filename
  completionQueue:(NSOperationQueue *)completionQueue
       completion:(void (^)(NSError *error))completion {
    if (!data || !filename) {
        NSError *err = [NSError errorWithCode:ErrorCodeFileOperation description:@"Missing data or filename string."];
        if (completion) {
            [self operationQueue:completionQueue performBlock:^{
                completion(err);
            }];
        }
        
        return;
    }
    
    NSBlockOperation *fileLookOp = [NSBlockOperation new];
    [fileLookOp addExecutionBlock:^{
        NSString *filePath = [self localFilePathForFilename:filename];
        if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil]) {
            NSError *err = [NSError errorWithCode:ErrorCodeFileOperation description:@"Saving failed."];
            if (completion) {
                [self operationQueue:completionQueue performBlock:^{
                    completion(err);
                }];
            }
            
            return;
        }
        
        if (completion) {
            [self operationQueue:completionQueue performBlock:^{
                completion(nil);
            }];
        }
    }];
    
    [self.operationQueue addOperation:fileLookOp];
}

- (void)loadDataForFileName:(NSString *)filename
            completionQueue:(NSOperationQueue *)completionQueue
                 completion:(void (^)(NSData *result, NSError *error))completion {
    if (!filename.length) {
        NSError *err = [NSError errorWithCode:ErrorCodeFileOperation description:@"Missing filename."];
        if (completion) {
            [self operationQueue:completionQueue performBlock:^{
                completion(nil, err);
            }];
        }
        
        return;
    }
    
    NSBlockOperation *fileLookOp = [NSBlockOperation new];
    [fileLookOp addExecutionBlock:^{
        NSData *cachedData = [self fileForFilePath:[self localFilePathForFilename:filename]];
        
        if (completion) {
            if (cachedData) {
                [self operationQueue:completionQueue performBlock:^{
                    completion(cachedData, nil);
                }];
            } else {
                NSError *error = [NSError errorWithCode:ErrorCodeFileOperation description:@"No cached file found."];
                [self operationQueue:completionQueue performBlock:^{
                    completion(nil, error);
                }];
            }
        }
    }];
    
    [self.operationQueue addOperation:fileLookOp];
    
}

- (void)removeCachedDataForFilename:(NSString *)filename
                        ofClassType:(Class)classType
                    completionQueue:(NSOperationQueue *)completionQueue
                         completion:(void (^)(NSError *error))completion {
    NSBlockOperation *fileLookOp = [NSBlockOperation new];
    [fileLookOp addExecutionBlock:^{
        NSString *filePath = [self localFilePathForFilename:filename];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *fileOpErr;
        NSError *err = nil;
        BOOL success = [fileManager removeItemAtPath:filePath error:&fileOpErr];
        if (!success) {
            err = [NSError errorWithCode:ErrorCodeFileOperation description:@"Failed to delete file."];
        }
        
        if (completion) {
            [self operationQueue:completionQueue performBlock:^{
                completion(err);
            }];
        }
    }];
    
    [self.operationQueue addOperation:fileLookOp];
}


- (void)performAllFilesCleanUp {
    [[NSFileManager defaultManager] removeItemAtPath:self.cachesDirectoryPath error:nil];
}

#pragma mark - File retrieving
#pragma mark - Local Image Retrieval
- (NSData *)fileForFilePath:(NSString *)filePath {
    NSData *result = nil;
    if (filePath) {
        //check in local storage
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            result = [NSData dataWithContentsOfFile:filePath];
        }
    }
    
    return result;
}

#pragma mark - Local path utilities
- (NSString *)localFilePathForFilename:(NSString *)filename {
    return filename ? [self.cachesDirectoryPath stringByAppendingPathComponent:filename] : nil;
}

#pragma mark - Dispatch on queue
- (void)operationQueue:(NSOperationQueue *)operationQueue performBlock:(void (^)(void))block {
    if (!block) {
        return;
    }
    
    if (operationQueue && operationQueue != NSOperationQueue.currentQueue) {
        [operationQueue addOperationWithBlock:block];
    } else {
        block();
    }
}


@end
