//
//  VVJSONSchemaConstValidator.h
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 13/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Implements "const" keyword. Applicable to all instance types.
 */
@interface VVJSONSchemaConstValidator : NSObject <VVJSONSchemaValidator>

/** Valid instance values for the receiver. */
@property (nonatomic, readonly, strong) id value;

@end

NS_ASSUME_NONNULL_END
