//
//  VVJSONSchemaConditionalValidator.h
//  VVJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 20/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Implements "if", "then" and "else" keywords. Applicable to any instances.
 */
@interface VVJSONSchemaConditionalValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, nullable, readonly, strong) VVJSONSchema *ifSchema;
@property (nonatomic, nullable, readonly, strong) VVJSONSchema *thenSchema;
@property (nonatomic, nullable, readonly, strong) VVJSONSchema *elseSchema;

@end

NS_ASSUME_NONNULL_END
