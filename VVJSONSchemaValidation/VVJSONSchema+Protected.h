//
//  VVJSONSchema+Protected.h
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 11/08/2018.
//  Copyright © 2018 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchema.h"

NS_ASSUME_NONNULL_BEGIN

@interface VVJSONSchema ()

- (BOOL)resolveReferencesWithSchemaStorage:(VVJSONSchemaStorage *)schemaStorage error:(NSError * __autoreleasing *)error;
- (BOOL)detectReferenceCyclesWithError:(NSError * __autoreleasing *)error;

+ (NSDictionary<NSString *, Class> *)validatorsMappingForMetaschemaURI:(NSURL *)metaschemaURI specification:(VVJSONSchemaSpecification *)specification;

@end

NS_ASSUME_NONNULL_END
