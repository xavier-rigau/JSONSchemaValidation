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

/**
 Defines an object with schema specification version. 
 */
@interface VVJSONSchemaSpecification : NSObject

/** Specification version value. */
@property (nonatomic, readonly, assign) VVJSONSchemaSpecificationVersion version;
/** ID Schema Keyword ('id' for draft 4 or '$id' for draft 6). */
@property (nonatomic, readonly, copy) NSString *idKeyword;
@property (nonatomic, readonly, strong) NSURL *defaultMetaschemaURI;
@property (nonatomic, readonly, copy) NSSet<NSURL *> *supportedMetaschemaURIs;
@property (nonatomic, readonly, copy) NSSet<NSURL *> *unsupportedMetaschemaURIs;
/** Set of object and array schema keywords. */
@property (nonatomic, readonly, copy) NSSet<NSString *> *keywords;

/** Creates JSON Schema draft 4 configuration object. */
+ (instancetype)draft4;
/** Creates JSON Schema draft 6 configuration object. */
+ (instancetype)draft6;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
