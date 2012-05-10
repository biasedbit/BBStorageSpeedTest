//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBItem.h"



#pragma mark - Constants

NSString* const kBBSampleModelFieldIdentifier = @"identifier";
NSString* const kBBSampleModelFieldCreatedAt = @"createdAt";
NSString* const kBBSampleModelFieldHash = @"hash";
NSString* const kBBSampleModelFieldData = @"data";
NSString* const kBBSampleModelFieldOptionalString = @"optionalString";
NSString* const kBBSampleModelFieldViews = @"views";
NSString* const kBBSampleModelFieldDisplayInRect = @"displayInRect";



#pragma mark -

@implementation BBItem


#pragma mark Property synthesizers

@synthesize identifier = _identifier;
@synthesize createdAt = _createdAt;
@synthesize hash = _hash;
@synthesize data = _data;
@synthesize optionalString = _optionalString;
@synthesize views = _views;
@synthesize displayInRect = _displayInRect;


#pragma mark Public static methods

+ (BBItem*)itemFromDictionary:(NSDictionary*)dictionary
{
    BBItem* model = [[BBItem alloc] init];
    // Object - straight forward conversions, retrieved from the dictionary without any further changes required
    model.identifier = [dictionary objectForKey:kBBSampleModelFieldIdentifier];
    model.createdAt = [dictionary objectForKey:kBBSampleModelFieldCreatedAt];
    model.hash = [dictionary objectForKey:kBBSampleModelFieldHash];
    model.data = [dictionary objectForKey:kBBSampleModelFieldData];
    // Scalar, require conversion from the objects stored in the NSDictionary
    NSNumber* viewsNumber = [dictionary objectForKey:kBBSampleModelFieldViews];
    if (viewsNumber != nil) {
        model.views = [viewsNumber unsignedIntegerValue];
    }
    NSString* displayInRectAsString = [dictionary objectForKey:kBBSampleModelFieldDisplayInRect];
    if (displayInRectAsString != nil) {
        model.displayInRect = CGRectFromString(displayInRectAsString);
    }
    // Optional
    model.optionalString = [dictionary objectForKey:kBBSampleModelFieldOptionalString];

    // Optionally, we can validate the model here
    if ((model.identifier == nil) ||
        (model.createdAt == nil) ||
        (model.hash == nil) ||
        (model.data == nil)) {
        BBLogDebug(@"Failed to deserialize model from dictionary:\n%@", dictionary);
        return nil;
    }

    return model;
}


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder*)coder
{
    // Object
    [coder encodeObject:_identifier forKey:kBBSampleModelFieldIdentifier];
    [coder encodeObject:_createdAt forKey:kBBSampleModelFieldCreatedAt];
    [coder encodeObject:_hash forKey:kBBSampleModelFieldHash];
    [coder encodeObject:_data forKey:kBBSampleModelFieldData];
    // Scalar
    [coder encodeInteger:_views forKey:kBBSampleModelFieldViews];
    [coder encodeCGRect:_displayInRect forKey:kBBSampleModelFieldDisplayInRect];
    // Optional
    if (_optionalString != nil) {
        [coder encodeObject:_optionalString forKey:kBBSampleModelFieldOptionalString];
    }
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self != nil) {
        // Object
        self.identifier = [decoder decodeObjectForKey:kBBSampleModelFieldIdentifier];
        self.createdAt = [decoder decodeObjectForKey:kBBSampleModelFieldCreatedAt];
        self.hash = [decoder decodeObjectForKey:kBBSampleModelFieldHash];
        self.data = [decoder decodeObjectForKey:kBBSampleModelFieldData];
        // Scalar
        self.views = [decoder decodeIntegerForKey:kBBSampleModelFieldViews];
        self.displayInRect = [decoder decodeCGRectForKey:kBBSampleModelFieldDisplayInRect];
        // Optional
        if ([decoder containsValueForKey:kBBSampleModelFieldOptionalString]) {
            self.optionalString = [decoder decodeObjectForKey:kBBSampleModelFieldOptionalString];
        }
    }

    return self;
}


#pragma mark Public methods

- (NSDictionary*)convertToDictionary
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       // Object
                                       _identifier, kBBSampleModelFieldIdentifier,
                                       _createdAt, kBBSampleModelFieldCreatedAt,
                                       _hash, kBBSampleModelFieldHash,
                                       _data, kBBSampleModelFieldData,
                                       // Scalar
                                       [NSNumber numberWithUnsignedInteger:_views], kBBSampleModelFieldViews,
                                       NSStringFromCGRect(_displayInRect), kBBSampleModelFieldDisplayInRect,
                                       nil];

    // Optional properties should be checked before being committed to the NSDictionary
    if (_optionalString != nil) {
        [dictionary setValue:_optionalString forKey:@"optionalString"];
    }

    return dictionary;
}

@end
