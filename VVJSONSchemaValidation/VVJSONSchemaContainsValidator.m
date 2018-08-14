//
//  VVJSONSchemaContainsValidator.m
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 14/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import "VVJSONSchemaContainsValidator.h"
#import "VVJSONSchema.h"
#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaErrors.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kSchemaKeywordContains = @"contains";

@implementation VVJSONSchemaContainsValidator

- (instancetype)initWithSchema:(VVJSONSchema *)schema
{
    NSParameterAssert(schema);
    self = [super init];
    if (self) {
        _schema = schema;
    }
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ schema: %@ }", self.schema];
}

+ (NSSet<NSString *> *)assignedKeywords
{
    return [NSSet setWithObject:kSchemaKeywordContains];
}

+ (nullable instancetype)validatorWithDictionary:(NSDictionary<NSString *, id> *)schemaDictionary schemaFactory:(__unused VVJSONSchemaFactory *)schemaFactory error:(NSError * __autoreleasing *)error
{
    id containsObject = schemaDictionary[kSchemaKeywordContains];
    NSError *internalError = nil;
    VVJSONSchema *containsSchema = nil;
    if ([containsObject isKindOfClass:[NSDictionary class]] ||
        [containsObject isKindOfClass:[NSNumber class]]) {
        // contains object is a dictionary or boolean - parse it as a schema;
        // schema will have scope extended by "/contains"
        VVJSONSchemaFactory *containsSchemaFactory = [schemaFactory factoryByAppendingScopeComponentsFromArray:@[ kSchemaKeywordContains ]];
        
        containsSchema = [containsSchemaFactory schemaWithObject:containsObject error:&internalError];
    }
    
    if (containsSchema) {
        return [[self alloc] initWithSchema:containsSchema];
    }
    else {
        if (error != NULL) {
            *error = internalError ?: [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
}

- (nullable NSArray<VVJSONSchema *> *)subschemas
{
    return @[ self.schema ];
}

- (BOOL)validateInstance:(id)instance inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSArray class]] == NO) {
        return YES;
    }
    
    if ([instance count] == 0) {
        if (error != NULL) {
            NSString *failureReason = @"Empty array is invalid.";
            *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
        }
        return NO;
    }
    
    NSError *internalError = nil;
    BOOL success = NO;
    for (id item in instance) {
        success = [self.schema validateObject:item inContext:context error:&internalError];
        // if any item succeded finish validation
        if (success) {
            break;
        }
    }
    
    if (success == NO) {
        if (error != NULL) {
            *error = internalError;
        }
    }
    
    return success;
}

@end

NS_ASSUME_NONNULL_END
