//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBDictionaryItemRepository.h"



#pragma mark -

@implementation BBDictionaryItemRepository


#pragma mark BBItemRepository

- (void)reload
{
    
}

- (BOOL)flush
{
    return YES;
}

- (BBItem*)itemWithIdentifier:(NSString*)identifier
{
    return nil;
}

- (BOOL)addItem:(BBItem*)item
{
    return YES;
}

- (BOOL)removeItem:(BBItem*)item
{
    return YES;
}

@end
