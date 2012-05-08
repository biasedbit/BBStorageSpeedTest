//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#pragma mark -

@interface BBItem : NSObject <NSCoding>


#pragma mark Public properties

@property(strong, nonatomic) NSString*  identifier;
@property(strong, nonatomic) NSDate*    createdAt;
@property(strong, nonatomic) NSString*  hash;
@property(strong, nonatomic) NSData*    data;
@property(strong, nonatomic) NSString*  optionalString;
@property(assign, nonatomic) NSUInteger views;
@property(assign, nonatomic) CGRect     displayInRect;


#pragma mark Public static methods

+ (BBItem*)itemFromDictionary:(NSDictionary*)dictionary;


#pragma mark Public methods

- (NSDictionary*)convertToDictionary;

@end
