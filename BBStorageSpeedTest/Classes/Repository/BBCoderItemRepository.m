//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBCoderItemRepository.h"



#pragma mark -

@implementation BBCoderItemRepository
{
    __strong NSString* _archiveFilePath;
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

        // Make sure the directory exists
        [[NSFileManager defaultManager]
         createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];

        _archiveFilePath = [path stringByAppendingPathComponent:@"BBCoderItemRepository.archive"];
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

- (void)reset
{
    [super reset];
    
    // This will fail if no file exists so ignore
    [[NSFileManager defaultManager] removeItemAtPath:_archiveFilePath error:nil];
}

- (void)reload
{
    [super reload];

    NSMutableDictionary* entries = [NSKeyedUnarchiver unarchiveObjectWithFile:_archiveFilePath];
    if (entries == nil) {
        BBLogTrace(@"[%@] Could not read archive; creating empty repository.", NSStringFromClass([self class]));
        return;
    }

    // Entries are not null, so assign to the ivar
    _entries = entries;
}

- (BOOL)flush
{
    if (![super flush]) {
        return NO;
    }

    return [NSKeyedArchiver archiveRootObject:_entries toFile:_archiveFilePath];
}

@end
