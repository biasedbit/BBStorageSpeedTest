//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBDictionaryItemRepository.h"



#pragma mark -

@implementation BBDictionaryItemRepository
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

        // Make sure the directory exists
        [[NSFileManager defaultManager]
         createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];

        _indexFilePath = [path stringByAppendingPathComponent:@"BBDictionaryItemRepository.plist"];
//        BBLogTrace(@"%@", _indexFilePath);
    }

    return self;
}


#pragma mark Public static methods

+ (id)sharedRepository
{
    static BBDictionaryItemRepository* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBDictionaryItemRepository alloc] init];
    });

    return instance;
}


#pragma mark BBItemRepository

- (void)reset
{
    [super reset];

    // This will fail if no file exists so ignore
    [[NSFileManager defaultManager] removeItemAtPath:_indexFilePath error:nil];
}

- (void)reload
{
    [super reload];

    // Load the file as NSData
    NSData* dictionaryData = [NSData dataWithContentsOfFile:_indexFilePath];
    if (dictionaryData == nil) {
        BBLogTrace(@"[%@] Could not read cache index; creating an empty one.", NSStringFromClass([self class]));
        return;
    }

    // Deserialize the contents of the file to an NSDictionary
    NSString* error = nil;
    NSDictionary* serializedEntries = [NSPropertyListSerialization
                                       propertyListFromData:dictionaryData
                                       mutabilityOption:NSPropertyListImmutable
                                       format:NULL errorDescription:&error];
    if (error != nil) {
        BBLogTrace(@"[%@] Data read from index file but de-serialization failed: %@",
                   NSStringFromClass([self class]), error);
        return;
    }

    // Convert each key-value pair (NSString, NSDictionary) into our entries: (item.id, item)
    [serializedEntries enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* serializedEntry, BOOL* stop) {
        BBItem* item = [BBItem itemFromDictionary:serializedEntry];
        [_entries setObject:item forKey:key];
    }];

    BBLogTrace(@"[%@] Deserialized %d BBItem objects from index file.",
               NSStringFromClass([self class]), [_entries count]);
}

- (BOOL)flush
{
    if (![super flush]) {
        return NO;
    }

    // Convert each BBItem in the _entries dictionary to it's NSDictionary representation
    NSError* error = nil;
    NSMutableDictionary* serializedEntries = [NSMutableDictionary dictionaryWithCapacity:[_entries count]];
    [_entries enumerateKeysAndObjectsUsingBlock:^(NSString* key, BBItem* item, BOOL* stop) {
        NSDictionary* serializedEntry = [item convertToDictionary];
        [serializedEntries setObject:serializedEntry forKey:key];
    }];

    // Create NSData from the dictionary created above, by serializing using binary property lists.
    NSData* dictionaryData = [NSPropertyListSerialization
                              dataWithPropertyList:serializedEntries
                              format:NSPropertyListBinaryFormat_v1_0
                              options:0 error:&error];
    if (error != nil) {
        BBLogError(@"[%@] Failed to serialize index to binary format: %@",
                   NSStringFromClass([self class]), [error description]);
        return NO;
    }

    BBLogDebug(@"[%@] Serialized index to binary format (%d entries).",
               NSStringFromClass([self class]), [serializedEntries count]);
    if (![dictionaryData writeToFile:_indexFilePath options:NSDataWritingAtomic error:&error]) {
        BBLogError(@"[%@] Failed to write index file to disk: %@",
                   NSStringFromClass([self class]), [error description]);
        return NO;
    }

    return YES;
}

@end
