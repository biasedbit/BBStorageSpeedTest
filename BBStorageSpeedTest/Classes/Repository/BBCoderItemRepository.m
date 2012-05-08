//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBCoderItemRepository.h"



#pragma mark -

@implementation BBCoderItemRepository
{
    __strong NSString* _indexFilePath;
}


#pragma mark Creation

- (id)init
{
    self = [super init];
    if (self != nil) {
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)
                          objectAtIndex:0];
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        path = [path stringByAppendingPathComponent:appBundleID];
        
        _indexFilePath = [path stringByAppendingPathComponent:@"BBCoderItemRepository.archive"];
//        BBLogTrace(@"%@", _indexFilePath);
    }

    return self;
}


#pragma mark Public static methods

+ (BBCoderItemRepository*)sharedRepository
{
    static BBCoderItemRepository* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBCoderItemRepository alloc] init];
    });

    return instance;
}


#pragma mark BBItemRepository

- (void)reload
{
    [super reload];
}

- (BOOL)flush
{
    if (![super flush]) {
        return NO;
    }

    return YES;
}

@end
