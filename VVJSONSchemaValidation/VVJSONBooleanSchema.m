//
//  VVJSONBooleanSchema.m
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 11/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import "VVJSONBooleanSchema.h"
#import "NSURL+VVJSONReferencing.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Boolean Validator

@interface VVJSONSchemaBooleanSchemaValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, assign) BOOL schemaValue;

@end

@implementation VVJSONSchemaBooleanSchemaValidator

- (instancetype)initWithSchemaValue:(BOOL)schemaValue
{
    self = [super init];
    if (self) {
        _schemaValue = schemaValue;
    }
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ boolean value %@ }", self.schemaValue ? @"YES" : @"NO"];
}

+ (NSSet<NSString *> *)assignedKeywords
{
    NSAssert(NO, @"Assigned keywords are not available for boolean schema validator");
    return [NSSet setWithObject:@""];
}

+ (nullable instancetype)validatorWithDictionary:(__unused NSDictionary<NSString *, id> *)schemaDictionary schemaFactory:(__unused VVJSONSchemaFactory *)schemaFactory error:(__unused  NSError * __autoreleasing *)error
{
    NSAssert(NO, @"`validatorWithDictionary:schemaFactory:error` is not available for boolean schema validator");
    return nil;
}

- (nullable NSArray<VVJSONSchema *> *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(__unused id)instance inContext:(VVJSONSchemaValidationContext *)context error:(__unused NSError *__autoreleasing *)error
{
    if (self.schemaValue == NO) {
        if (error != NULL) {
            NSString *failureReason = [NSString stringWithFormat:@"Object does not satisfy '%@' schema.", self.schemaValue ? @"YES" : @"NO"];
            *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
        }
        return NO;
    }
    else {
        return YES;
    }
}

@end

#pragma mark - Boolean Schema

@implementation VVJSONBooleanSchema

#pragma mark - Schema parsing

+ (nullable instancetype)schemaWithNumber:(NSNumber *)schemaNumber baseURI:(nullable NSURL *)baseURI specification:(VVJSONSchemaSpecification *)specification error:(NSError * __autoreleasing *)error
{
    if ([schemaNumber isKindOfClass:NSNumber.class] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaNumber];
        }
        return nil;
    }

    // if base URI is not present, replace it with an empty one
    NSURL *scopeURI = baseURI ?: [NSURL URLWithString:@""];
    scopeURI = scopeURI.vv_normalizedURI;
    
    VVJSONBooleanSchema *schema = [[self alloc] initWithScopeURI:scopeURI schemaValue:schemaNumber.boolValue specification:specification];
    
    return schema;
}

- (instancetype)initWithScopeURI:(NSURL *)uri schemaValue:(BOOL)schemaValue specification:(VVJSONSchemaSpecification *)specification
{
    VVJSONSchemaBooleanSchemaValidator *validator = [[VVJSONSchemaBooleanSchemaValidator alloc] initWithSchemaValue:schemaValue];
    self = [super initWithScopeURI:uri title:nil description:nil validators:@[ validator ] subschemas:nil specification:specification];
    if (self) {
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
