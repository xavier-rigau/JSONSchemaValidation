//
//  VVJSONSchemaTypeValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaTypeValidator.h"
#import "VVJSONSchemaErrors.h"
#import "VVJSONSchemaFactory.h"
#import "NSNumber+VVJSONNumberTypes.h"

VVJSONSchemaInstanceTypes VVJSONSchemaInstanceTypeFromString(NSString *string);
NSString *NSStringFromVVJSONSchemaInstanceTypes(VVJSONSchemaInstanceTypes types);

@interface VVJSONSchemaTypeValidator ()

@property (nonatomic, strong) VVJSONSchemaSpecification *specification;

@end

@implementation VVJSONSchemaTypeValidator

static NSString * const kSchemaKeywordType = @"type";

- (instancetype)initWithTypes:(VVJSONSchemaInstanceTypes)types specification:(VVJSONSchemaSpecification *)specification
{
    self = [super init];
    if (self) {
        _types = types;
        _specification = specification;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ allowed types: %@ }", NSStringFromVVJSONSchemaInstanceTypes(self.types)];
}

+ (NSSet<NSString *> *)assignedKeywords
{
    return [NSSet setWithObject:kSchemaKeywordType];
}

+ (instancetype)validatorWithDictionary:(NSDictionary<NSString *, id> *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError * __autoreleasing *)error
{
    id typesObject = schemaDictionary[kSchemaKeywordType];
    
    VVJSONSchemaInstanceTypes types = VVJSONSchemaInstanceTypesNone;
    if ([typesObject isKindOfClass:[NSString class]]) {
        // parse type instance either as a string...
        types = VVJSONSchemaInstanceTypeFromString(typesObject);
    } else if ([typesObject isKindOfClass:[NSArray class]]) {
        // ... or as an array
        for (id typeObject in typesObject) {
            VVJSONSchemaInstanceTypes type = VVJSONSchemaInstanceTypesNone;
            if ([typeObject isKindOfClass:[NSString class]]) {
                type = VVJSONSchemaInstanceTypeFromString(typeObject);
            }
            
            if (type != VVJSONSchemaInstanceTypesNone && (types & type) == 0) {
                types |= type;
            } else {
                // fail if invalid instance is encountered or there is a duplicate type
                types = VVJSONSchemaInstanceTypesNone;
                break;
            }
        }
    }
    
    if (types != VVJSONSchemaInstanceTypesNone) {
        return [[self alloc] initWithTypes:types specification:schemaFactory.specification];
    } else {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
}

- (NSArray<VVJSONSchema *> *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(id)instance inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    VVJSONSchemaInstanceTypes types = self.types;
    if ((types & VVJSONSchemaInstanceTypesObject) != 0 && [instance isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    if ((types & VVJSONSchemaInstanceTypesArray) != 0 && [instance isKindOfClass:[NSArray class]]) {
        return YES;
    }
    if ((types & VVJSONSchemaInstanceTypesString) != 0 && [instance isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ((types & VVJSONSchemaInstanceTypesInteger) != 0 && [instance isKindOfClass:[NSNumber class]]) {
        if ([instance vv_isInteger]) {
            return YES;
        }
        if ((self.specification.version == VVJSONSchemaSpecificationVersionDraft6 ||
             self.specification.version == VVJSONSchemaSpecificationVersionDraft7) &&
            [instance vv_isFloat]) {
            // "a float without fractional part is an integer"
            double doubleValue = [instance doubleValue];
            double fractionalPart = fmod(doubleValue, 1.0);
            if (fractionalPart == 0.0) {
                return YES;
            }
        }
    }
    if ((types & VVJSONSchemaInstanceTypesNumber) != 0 && [instance isKindOfClass:[NSNumber class]] && [instance vv_isBoolean] == NO) {
        return YES;
    }
    if ((types & VVJSONSchemaInstanceTypesBoolean) != 0 && [instance isKindOfClass:[NSNumber class]] && [instance vv_isBoolean]) {
        return YES;
    }
    if ((types & VVJSONSchemaInstanceTypesNull) != 0 && instance == [NSNull null]) {
        return YES;
    }
    
    if (error != NULL) {
        NSString *failureReason = @"Object type is not allowed.";
        *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
    }
    return NO;
}

@end

VVJSONSchemaInstanceTypes VVJSONSchemaInstanceTypeFromString(NSString *string)
{
    static NSDictionary<NSString *, NSNumber *> *mapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{ @"object" : @(VVJSONSchemaInstanceTypesObject), @"array" : @(VVJSONSchemaInstanceTypesArray), @"string" : @(VVJSONSchemaInstanceTypesString), @"integer" : @(VVJSONSchemaInstanceTypesInteger), @"number" : @(VVJSONSchemaInstanceTypesNumber), @"boolean" : @(VVJSONSchemaInstanceTypesBoolean), @"null" : @(VVJSONSchemaInstanceTypesNull) };
    });
    
    NSNumber *typeNumber = mapping[string];
    if (typeNumber != nil) {
        return [typeNumber unsignedIntegerValue];
    } else {
        return VVJSONSchemaInstanceTypesNone;
    }
}

NSString *NSStringFromVVJSONSchemaInstanceTypes(VVJSONSchemaInstanceTypes types)
{
    if (types == VVJSONSchemaInstanceTypesNone) {
        return @"none";
    }
    
    NSMutableArray<NSString *> *typeStrings = [NSMutableArray array];
    if (types & VVJSONSchemaInstanceTypesObject) {
        [typeStrings addObject:@"object"];
    }
    if (types & VVJSONSchemaInstanceTypesArray) {
        [typeStrings addObject:@"array"];
    }
    if (types & VVJSONSchemaInstanceTypesString) {
        [typeStrings addObject:@"string"];
    }
    if (types & VVJSONSchemaInstanceTypesInteger) {
        [typeStrings addObject:@"integer"];
    }
    if (types & VVJSONSchemaInstanceTypesNumber) {
        [typeStrings addObject:@"number"];
    }
    if (types & VVJSONSchemaInstanceTypesBoolean) {
        [typeStrings addObject:@"boolean"];
    }
    if (types & VVJSONSchemaInstanceTypesNull) {
        [typeStrings addObject:@"null"];
    }
    
    return [typeStrings componentsJoinedByString:@", "];
}
