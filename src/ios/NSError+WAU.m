//
//  NSError+WAU.m
//  Communicator
//
//  Created by Toma Popov on 5/15/15.
//
//

#import "NSError+WAU.h"
NSString * const kErrorDomain = @"com.xcode.fileOperation";

@implementation NSError (WAU)

+ (NSError *)errorWithCode:(ErrorCode)code description:(NSString *)description {
    return [NSError errorWithDomain:kErrorDomain code:code userInfo:[NSDictionary dictionaryWithObject:description
                                                                                                forKey:NSLocalizedDescriptionKey]];
}

@end
