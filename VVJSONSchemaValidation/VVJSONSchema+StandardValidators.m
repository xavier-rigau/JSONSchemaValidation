//
//  VVJSONSchema+StandardValidators.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchema+StandardValidators.h"

@implementation VVJSONSchema (StandardValidators)

+ (void)load
{
    // register all standard validators for default metaschema
    NSArray<Class<VVJSONSchemaValidator>> *draft4ValidatorClasses = @[ [VVJSONSchemaDefinitions class], [VVJSONSchemaTypeValidator class], [VVJSONSchemaEnumValidator class], [VVJSONSchemaNumericValidator class], [VVJSONSchemaStringValidator class], [VVJSONSchemaArrayValidator class], [VVJSONSchemaArrayItemsValidator class], [VVJSONSchemaObjectValidator class], [VVJSONSchemaObjectPropertiesValidator class], [VVJSONSchemaDependenciesValidator class], [VVJSONSchemaCombiningValidator class], [VVJSONSchemaFormatValidator class] ];
    
    NSMutableArray<Class<VVJSONSchemaValidator>> *draft6ValidatorClasses = [draft4ValidatorClasses mutableCopy];
    [draft6ValidatorClasses addObjectsFromArray:@[ [VVJSONSchemaConstValidator class], [VVJSONSchemaContainsValidator class], [VVJSONSchemaPropertyNamesValidator class] ]];
    
    for (Class<VVJSONSchemaValidator> validatorClass in draft4ValidatorClasses) {
        if ([self registerValidatorClass:validatorClass forMetaschemaURI:nil specification:[VVJSONSchemaSpecification draft4]  withError:NULL] == NO) {
            [NSException raise:NSInternalInconsistencyException format:@"Failed to register standard JSON draft-04 Schema validators."];
        }
    }
    for (Class<VVJSONSchemaValidator> validatorClass in draft6ValidatorClasses) {
        if ([self registerValidatorClass:validatorClass forMetaschemaURI:nil specification:[VVJSONSchemaSpecification draft6]  withError:NULL] == NO) {
            [NSException raise:NSInternalInconsistencyException format:@"Failed to register standard JSON draft-06 Schema validators."];
        }
    }
}

@end
