//
//  VVJSONSchemaFactory.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 29/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaReference.h"
#import "VVJSONDictionarySchema.h"
#import "VVJSONBooleanSchema.h"
#import "NSURL+VVJSONReferencing.h"
#import "NSString+VVJSONPointer.h"
#import "NSNumber+VVJSONNumberTypes.h"

@implementation VVJSONSchemaFactory

static NSString * const kSchemaKeywordTitle = @"title";
static NSString * const kSchemaKeywordDescription = @"description";
static NSString * const kSchemaKeywordReference = @"$ref";

+ (instancetype)factoryWithScopeURI:(NSURL *)scopeURI keywordsMapping:(NSDictionary<NSString *, Class> *)keywordsMapping specification:(VVJSONSchemaSpecification *)specification
{
    return [[self alloc] initWithScopeURI:scopeURI keywordsMapping:keywordsMapping specification:specification];
}

- (instancetype)initWithScopeURI:(NSURL *)scopeURI keywordsMapping:(NSDictionary<NSString *, Class> *)keywordsMapping specification:(VVJSONSchemaSpecification *)specification
{
    NSParameterAssert(scopeURI);
    NSAssert(keywordsMapping.count > 0, @"Schema factory requires a valid mapping dictionary of schema keywords.");
    
    self = [super init];
    if (self) {
        _scopeURI = scopeURI;
        _keywordsMapping = [keywordsMapping copy];
        _specification = specification;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ scope %@; %lu keywords }", self.scopeURI, (unsigned long)self.keywordsMapping.count];
}

- (instancetype)factoryByReplacingScopeURI:(NSURL *)scopeURI
{
    NSParameterAssert(scopeURI);
    
    return [[self.class alloc] initWithScopeURI:scopeURI keywordsMapping:self.keywordsMapping specification:self.specification];
}

- (instancetype)factoryByAppendingScopeComponent:(NSString *)scopeComponent
{
    NSParameterAssert(scopeComponent);
    
    return [self factoryByAppendingScopeComponentsFromArray:@[ scopeComponent ]];
}

- (instancetype)factoryByAppendingScopeComponentsFromArray:(NSArray<NSString *> *)scopeComponentsArray
{
    NSParameterAssert(scopeComponentsArray);
    
    // combine the scope components into single path
    NSString *scopePath = nil;
    for (NSString *component in scopeComponentsArray) {
        NSAssert([component isKindOfClass:[NSString class]], @"Expecting scope components to be strings.");
        
        // escape JSON Pointer special characters
        NSString *encodedComponent = [component vv_stringByEncodingAsJSONPointer];
        if (scopePath != nil) {
            scopePath = [scopePath stringByAppendingPathComponent:encodedComponent];
        } else {
            scopePath = encodedComponent;
        }
    }
    
    // append the path to the fragment and construct a factory
    NSURL *newScopeURI = [self.scopeURI vv_URIByAppendingFragmentComponent:scopePath];
    return [[self.class alloc] initWithScopeURI:newScopeURI keywordsMapping:self.keywordsMapping specification:self.specification];
}

- (VVJSONSchema *)schemaWithObject:(id)foundationObject error:(NSError * __autoreleasing *)error
{
    if ([foundationObject isKindOfClass:NSDictionary.class]) {
        NSString *schemaKeywordID = self.specification.idKeyword;
        NSDictionary <NSString *, id> *schemaDictionary = foundationObject;
        
        // if schema object contains $ref, it's a schema reference - process that immediately
        id schemaReferenceString = schemaDictionary[kSchemaKeywordReference];
        if (schemaReferenceString != nil) {
            NSURL *referenceURI = [self.class schemaReferenceURIWithJSONReference:schemaReferenceString scope:self.scopeURI];
            if (referenceURI != nil) {
                NSMutableSet<NSString *> *remainingKeys = [NSMutableSet setWithArray:schemaDictionary.allKeys];
                [remainingKeys minusSet:self.specification.keywords]; // $ref overrides any sibling keywords
                [remainingKeys removeObject:kSchemaKeywordReference];
                [remainingKeys removeObject:schemaKeywordID];
                [remainingKeys removeObject:kSchemaKeywordTitle];
                [remainingKeys removeObject:kSchemaKeywordDescription];
                
                NSArray<VVJSONSchema *> *unboundSubschemas = [self unboundSubschemasFromDictionary:schemaDictionary remainingKeys:remainingKeys];
                
                return [[VVJSONSchemaReference alloc] initWithScopeURI:self.scopeURI referenceURI:referenceURI subschemas:unboundSubschemas specification:self.specification];
            } else {
                if (error != NULL) {
                    *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaReference failingObject:schemaDictionary];
                }
                return nil;
            }
        }
        
        // retrieve altered resolution scope and construct a new factory if it's present
        id alteredResolutionScopeString = schemaDictionary[schemaKeywordID];
        VVJSONSchemaFactory *effectiveFactory;
        if (alteredResolutionScopeString != nil) {
            NSURL *alteredResolutionScopeURI = [self.class alteredResolutionScopeURIWithJSONAlteration:alteredResolutionScopeString currentScope:self.scopeURI];
            if (alteredResolutionScopeURI != nil) {
                effectiveFactory = [self factoryByReplacingScopeURI:alteredResolutionScopeURI];
            } else {
                if (error != NULL) {
                    *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidResolutionScope failingObject:schemaDictionary];
                }
                return nil;
            }
        } else {
            effectiveFactory = self;
        }
        
        // retrieve basic schema keywords, if they are present
        id title = schemaDictionary[kSchemaKeywordTitle];
        id description = schemaDictionary[kSchemaKeywordDescription];
        if ((title != nil && [title isKindOfClass:[NSString class]] == NO) ||
            (description != nil && [description isKindOfClass:[NSString class]] == NO)) {
            if (error != NULL) {
                *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
            }
            return nil;
        }
        
        // generate a set of validator classes present in the schema
        NSDictionary<NSString *, Class> *keywordsMapping = self.keywordsMapping;
        NSMutableSet<Class> *presentValidatorClasses = [NSMutableSet set];
        for (NSString *key in schemaDictionary.allKeys) {
            Class validatorClass = keywordsMapping[key];
            if (validatorClass != Nil) {
                [presentValidatorClasses addObject:validatorClass];
            }
        }
        
        // instantiate all validators, passing them only their relevant data
        NSMutableArray<id<VVJSONSchemaValidator>> *validators = [NSMutableArray arrayWithCapacity:presentValidatorClasses.count];
        for (Class<VVJSONSchemaValidator> validatorClass in presentValidatorClasses) {
            NSSet<NSString *> *relevantKeywords = [validatorClass assignedKeywords];
            NSMutableDictionary<NSString *, id> *relevantData = [NSMutableDictionary dictionaryWithCapacity:relevantKeywords.count];
            for (NSString *keyword in relevantKeywords) {
                id value = schemaDictionary[keyword];
                if (value != nil) {
                    relevantData[keyword] = value;
                }
            }
            
            id<VVJSONSchemaValidator> validator = [validatorClass validatorWithDictionary:relevantData schemaFactory:effectiveFactory error:error];
            if (validator != nil) {
                [validators addObject:validator];
            } else {
                return nil;
            }
        }
        
        // instantiate any remaining, unbound subschemas
        NSMutableSet<NSString *> *remainingKeys = [NSMutableSet setWithArray:schemaDictionary.allKeys];
        [remainingKeys minusSet:[NSSet setWithArray:keywordsMapping.allKeys]];
        [remainingKeys removeObject:schemaKeywordID];
        [remainingKeys removeObject:kSchemaKeywordTitle];
        [remainingKeys removeObject:kSchemaKeywordDescription];
        
        NSArray<VVJSONSchema *> *unboundSubschemas = [self unboundSubschemasFromDictionary:schemaDictionary remainingKeys:remainingKeys];
        
        // finally, instantiate the schema itself
        VVJSONDictionarySchema *schema = [[VVJSONDictionarySchema alloc] initWithScopeURI:effectiveFactory.scopeURI title:title description:description validators:validators subschemas:unboundSubschemas specification:self.specification];
        
        return schema;
    }
    else if ((self.specification.version == VVJSONSchemaSpecificationVersionDraft6 ||
              self.specification.version == VVJSONSchemaSpecificationVersionDraft7) &&
             [foundationObject isKindOfClass:NSNumber.class] &&
             ((NSNumber *)foundationObject).vv_isBoolean) {
        BOOL schemaValue = [foundationObject boolValue];
        VVJSONBooleanSchema *schema = [[VVJSONBooleanSchema alloc] initWithScopeURI:self.scopeURI schemaValue:schemaValue specification:self.specification];
        
        return schema;
    }
    else {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:foundationObject];
        }
    }
    
    return nil;
}

+ (NSURL *)schemaReferenceURIWithJSONReference:(id)reference scope:(NSURL *)scopeURI
{
    if ([reference isKindOfClass:[NSString class]] && [(NSString *)reference length] > 0) {
        return [[NSURL URLWithString:reference relativeToURL:scopeURI] vv_normalizedURI];
    } else {
        // fail if reference is not a string, is empty or is not a valid URI
        return nil;
    }
}

+ (NSURL *)alteredResolutionScopeURIWithJSONAlteration:(id)alteration currentScope:(NSURL *)currentScopeURI
{
    if ([alteration isKindOfClass:[NSString class]] && [(NSString *)alteration length] > 0 && [alteration isEqualToString:@"#"] == NO) {
        return [[NSURL URLWithString:alteration relativeToURL:currentScopeURI] vv_normalizedURI];
    } else {
        // fail if alteration is not a string, is empty, is an empty fragment or is not a valid URI
        return nil;
    }
}

- (nullable NSArray <VVJSONSchema *> *)unboundSubschemasFromDictionary:(NSDictionary <NSString *, id> *)schemaDictionary remainingKeys:(NSSet<NSString *> *)remainingKeys {
    NSMutableArray<VVJSONSchema *> *unboundSubschemas = nil;
    if (remainingKeys.count > 0) {
        unboundSubschemas = [NSMutableArray arrayWithCapacity:remainingKeys.count];
        for (NSString *key in remainingKeys) {
            id subschemaObject = schemaDictionary[key];
            // just skip non-dictionary and non-numbers objects
            if ([subschemaObject isKindOfClass:[NSDictionary class]] == NO &&
                [subschemaObject isKindOfClass:[NSNumber class]] == NO) {
                continue;
            }
            
            // schema will have scope extended by the key
            VVJSONSchemaFactory *subschemaFactory = [self factoryByAppendingScopeComponent:key];
            NSError *error = nil;
            VVJSONSchema *subschema = [subschemaFactory schemaWithObject:subschemaObject error:&error];
            if (subschema != nil) {
                [unboundSubschemas addObject:subschema];
            } else {
#ifdef DEBUG
                NSLog(@"Failed to create unbound schema with `schemaWithObject:error:` %@", error);
#endif /* DEBUG */
                return nil;
            }
        }
    }
    return [unboundSubschemas copy];
}

@end
