//
//  VVJSONSchemaSpecification.m
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 10/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import "VVJSONSchemaSpecification.h"

NS_ASSUME_NONNULL_BEGIN

@interface VVJSONSchemaSpecification ()

@property (nonatomic, strong) NSURL *defaultMetaschemaURI;
@property (nonatomic, copy) NSSet<NSURL *> *supportedMetaschemaURIs;
@property (nonatomic, copy) NSSet<NSURL *> *unsupportedMetaschemaURIs;

@end

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

- (NSString *)idKeyword {
    switch (self.version) {
        case VVJSONSchemaSpecificationVersionDraft4:
            return @"id";
        case VVJSONSchemaSpecificationVersionDraft6:
            return @"$id";
    }
}

- (NSURL *)defaultMetaschemaURI
{
    if (!_defaultMetaschemaURI) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullable-to-nonnull-conversion"
        switch (self.version) {
            case VVJSONSchemaSpecificationVersionDraft4: {
                _defaultMetaschemaURI = [NSURL URLWithString:@"http://json-schema.org/draft-04/schema#"];
                break;
            }   
            case VVJSONSchemaSpecificationVersionDraft6: {
                _defaultMetaschemaURI = [NSURL URLWithString:@"http://json-schema.org/draft-06/schema#"];
                break;
            }
        }
#pragma clang diagnostic pop
    }
    return _defaultMetaschemaURI;
}

- (NSSet<NSURL *> *)supportedMetaschemaURIs
{
    if (!_supportedMetaschemaURIs) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullable-to-nonnull-conversion"
        _supportedMetaschemaURIs = [NSSet setWithObjects:
                                    self.defaultMetaschemaURI,
                                    [NSURL URLWithString:@"http://json-schema.org/schema#"],
                                    nil];
#pragma clang diagnostic pop
    }
    return _supportedMetaschemaURIs;
}

- (NSSet<NSURL *> *)unsupportedMetaschemaURIs
{
    if (!_unsupportedMetaschemaURIs) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullable-to-nonnull-conversion"
        _unsupportedMetaschemaURIs = [NSSet setWithObjects:
                                      [NSURL URLWithString:@"http://json-schema.org/hyper-schema#"],
                                      [NSURL URLWithString:@"http://json-schema.org/draft-04/hyper-schema#"],
                                      [NSURL URLWithString:@"http://json-schema.org/draft-03/schema#"],
                                      [NSURL URLWithString:@"http://json-schema.org/draft-03/hyper-schema#"],
                                      nil];
#pragma clang diagnostic pop
    }
    return _unsupportedMetaschemaURIs;
}

@end

NS_ASSUME_NONNULL_END
