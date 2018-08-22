//
//  VVJSONSchemaValidationOptions.h
//  VVJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 22/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Option to control the "additionalProperties" behavior.
 @see https://github.com/epoberezkin/ajv#filtering-data
 */
typedef NS_ENUM(NSUInteger, VVJSONSchemaValidationOptionsRemoveAdditional) {
    /** Default behavior. */
    VVJSONSchemaValidationOptionsRemoveAdditionalNone,
    /** Disallowed property will be valid if "additionalProperties" is boolean schema */
    VVJSONSchemaValidationOptionsRemoveAdditionalYes,
    /** All properties that disallowed by "additionalProperties" is valid. */
    VVJSONSchemaValidationOptionsRemoveAdditionalAll,
    /** Disallowed property will be valid regardless of its value or if its value is failing the schema in the inner "additionalProperties". */
    VVJSONSchemaValidationOptionsRemoveAdditionalFailing,
};

/** Different options that allows to change default behaviour of the validator classes. */
@interface VVJSONSchemaValidationOptions : NSObject

/**
 Allows filtering data during the validation.
 Changes the behavior of "additionalProperties" keyword validator.
 Default is `VVJSONSchemaValidationOptionsRemoveAdditionalNone`.
 @see https://github.com/epoberezkin/ajv#filtering-data
 */
@property (nonatomic, assign) VVJSONSchemaValidationOptionsRemoveAdditional removeAdditional;

@end

NS_ASSUME_NONNULL_END
