//
//  BBInMemoryItemRepository.h
//  BBStorageSpeedTest
//
//  Created by Bruno de Carvalho on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBItem.h"



#pragma mark -

@interface BBItemRepository : NSObject
{
@protected
    __strong NSMutableDictionary* _entries;
}


#pragma mark Public methods

// Erase all content
- (void)reset;
// Load data into memory
- (void)reload;
// Flush data to disk
- (BOOL)flush;
// Operations on repository
- (NSUInteger)itemCount;
- (BBItem*)itemWithIdentifier:(NSString*)identifier;
- (void)addItem:(BBItem*)item;
- (void)removeItem:(BBItem*)item;
- (void)removeItemWithIdentifier:(NSString*)identifier;

@end
