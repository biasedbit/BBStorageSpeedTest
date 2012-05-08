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
// Retrieve item with given identifier
- (BBItem*)itemWithIdentifier:(NSString*)identifier;
// Add a new item
- (void)addItem:(BBItem*)item;
// Remove item
- (void)removeItem:(BBItem*)item;
// Remove item by key
- (void)removeItemWithIdentifier:(NSString*)identifier;

@end
