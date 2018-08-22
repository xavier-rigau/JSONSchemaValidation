//
//  VVJSONSchemaValidationOptions.h
//  VVJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 22/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Different options that allows to change default behaviour of the validator classes. */
@interface VVJSONSchemaValidationOptions : NSObject

/**
 Allows filtering data during the validation. This option modifies original data.
 If this option is YES and `"additionalProperties": false` then properties that not described by the `"properties"` object will be removed.
 Default is NO.
 @see https://github.com/epoberezkin/ajv#filtering-data
 */
@property (nonatomic, assign) BOOL removeAdditional;

@end

NS_ASSUME_NONNULL_END
