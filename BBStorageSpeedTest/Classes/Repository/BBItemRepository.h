//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBItem.h"



#pragma mark -

@protocol BBItemRepository <NSObject>

// Load data into memory
- (void)reload;

// Flush data to disk
- (BOOL)flush;

// Retrieve item with given identifier
- (BBItem*)itemWithIdentifier:(NSString*)identifier;

// Add a new item
- (BOOL)addItem:(BBItem*)item;

// Remove item
- (BOOL)removeItem:(BBItem*)item;

@end
