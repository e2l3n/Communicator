//
//  NSError+WAU.h
//  Communicator
//
//  Created by Toma Popov on 5/15/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    ErrorCodeFileOperation = 1002
} ErrorCode;

extern NSString * const kErrorDomain;

@interface NSError (WAU)

+ (NSError *)errorWithCode:(ErrorCode)code description:(NSString *)description;

@end
