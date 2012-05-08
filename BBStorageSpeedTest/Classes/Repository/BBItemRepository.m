//
//  BBInMemoryItemRepository.m
//  BBStorageSpeedTest
//
//  Created by Bruno de Carvalho on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBItemRepository.h"



#pragma mark -

@implementation BBItemRepository


#pragma mark Public methods

- (void)reset
{
    // should be overridden by subclasses
    _entries = [[NSMutableDictionary alloc] init];
}

- (void)reload
{
    // should be overridden by subclasses
    _entries = [[NSMutableDictionary alloc] init];
}

- (BOOL)flush
{
    NSAssert(_entries != nil, @"[%@] Please call -reload prior to calling this method",
             NSStringFromClass([self class]));

    // should be overridden by subclasses
    return YES;
}

- (BBItem*)itemWithIdentifier:(NSString*)identifier
{
    BBItem* item = [_entries objectForKey:identifier];

    return item;
}

- (void)addItem:(BBItem*)item
{
    NSAssert(_entries != nil, @"[%@] Please call -reload prior to calling this method",
             NSStringFromClass([self class]));

    [_entries setObject:item forKey:item.identifier];
}

- (void)removeItem:(BBItem*)item
{
    NSAssert(_entries != nil, @"[%@] Please call -reload prior to calling this method",
             NSStringFromClass([self class]));

    [_entries removeObjectForKey:item.identifier];
}

- (void)removeItemWithIdentifier:(NSString*)identifier
{
    NSAssert(_entries != nil, @"[%@] Please call -reload prior to calling this method",
             NSStringFromClass([self class]));

    [_entries removeObjectForKey:identifier];
}

@end
