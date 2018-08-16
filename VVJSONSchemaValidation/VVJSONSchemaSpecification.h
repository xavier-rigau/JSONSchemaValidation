//
//  VVJSONSchemaSpecification.h
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 10/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VVJSONSchemaSpecificationVersion) {
    VVJSONSchemaSpecificationVersionDraft4,
    VVJSONSchemaSpecificationVersionDraft6,
};

@interface VVJSONSchemaSpecification : NSObject

@property (nonatomic, readonly, assign) VVJSONSchemaSpecificationVersion version;
@property (nonatomic, readonly, copy) NSString *idKeyword;
@property (nonatomic, readonly, strong) NSURL *defaultMetaschemaURI;
@property (nonatomic, readonly, copy) NSSet<NSURL *> *supportedMetaschemaURIs;
@property (nonatomic, readonly, copy) NSSet<NSURL *> *unsupportedMetaschemaURIs;
@property (nonatomic, readonly, copy) NSSet<NSString *> *keywords;

+ (instancetype)draft4;
+ (instancetype)draft6;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
