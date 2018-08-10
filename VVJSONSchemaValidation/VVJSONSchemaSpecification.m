//
//  VVJSONSchemaSpecification.m
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 10/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import "VVJSONSchemaSpecification.h"

NS_ASSUME_NONNULL_BEGIN

@implementation VVJSONSchemaSpecification

+ (instancetype)draft4
{
    return [[self alloc] initWithVersion:VVJSONSchemaSpecificationVersionDraft4];
}

+ (instancetype)draft6
{
    return [[self alloc] initWithVersion:VVJSONSchemaSpecificationVersionDraft6];
}

- (instancetype)initWithVersion:(VVJSONSchemaSpecificationVersion)version
{
    self = [super init];
    if (self) {
        _version = version;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
