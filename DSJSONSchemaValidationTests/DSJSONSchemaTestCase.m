//
//  DSJSONSchemaTestCase.m
//  DSJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "DSJSONSchemaTestCase.h"
#import "DSJSONSchema.h"

@interface DSJSONSchemaTestCase ()

@property (nonatomic, readwrite, strong) DSJSONSchema *schema;
@property (strong, nonatomic) DSJSONSchemaSpecification *specification;

@end

@implementation DSJSONSchemaTestCase

+ (instancetype)testCaseWithObject:(NSDictionary<NSString *, id> *)testCaseObject specification:(DSJSONSchemaSpecification *)specification
{
    NSString *description = testCaseObject[@"description"];
    NSDictionary<NSString *, id> *schemaObject = testCaseObject[@"schema"];
    NSArray<NSDictionary<NSString *, id> *> *testsData = testCaseObject[@"tests"];
    
    NSMutableArray<DSJSONSchemaTest *> *tests = [NSMutableArray arrayWithCapacity:testsData.count];
    for (NSDictionary<NSString *, id> *testData in testsData) {
        [tests addObject:[DSJSONSchemaTest testWithObject:testData]];
    }
    
    return [[self alloc] initWithDescription:description schemaObject:schemaObject tests:tests specification:specification];
}

+ (NSArray<DSJSONSchemaTestCase *> *)testCasesWithContentsOfURL:(NSURL *)testCasesJSONURL specification:(DSJSONSchemaSpecification *)specification
{
    NSData *data = [NSData dataWithContentsOfURL:testCasesJSONURL];
    id json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:NULL];
    if (json == nil) {
        return nil;
    }
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        json = @[ json ];
    }
    
    NSMutableArray<DSJSONSchemaTestCase *> *testCases = [NSMutableArray arrayWithCapacity:[json count]];
    for (NSDictionary<NSString *, id> *testCaseData in json) {
        [testCases addObject:[self testCaseWithObject:testCaseData specification:specification]];
    }
    
    return [testCases copy];
}

- (instancetype)initWithDescription:(NSString *)description schemaObject:(NSDictionary<NSString *, id> *)schemaObject tests:(NSArray<DSJSONSchemaTest *> *)tests specification:(DSJSONSchemaSpecification *)specification
{
    self = [super init];
    if (self) {
        _testCaseDescription = [description copy];
        _schemaObject = [schemaObject copy];
        _tests = [tests copy];
        _specification = specification;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ '%@', %lu tests }", self.testCaseDescription, (unsigned long)self.tests.count];
}

- (BOOL)instantiateSchemaWithReferenceStorage:(DSJSONSchemaStorage *)schemaStorage error:(NSError * __autoreleasing *)error {
    return [self instantiateSchemaWithReferenceStorage:schemaStorage options:nil error:error];
}

- (BOOL)instantiateSchemaWithReferenceStorage:(DSJSONSchemaStorage *)schemaStorage options:(nullable DSJSONSchemaValidationOptions *)options error:(NSError *__autoreleasing *)error
{
    options = options ?: [[DSJSONSchemaValidationOptions alloc] init];
    
    self.schema = [DSJSONSchema schemaWithObject:self.schemaObject baseURI:nil referenceStorage:schemaStorage specification:self.specification options:options error:error];
    return (self.schema != nil);
}

- (BOOL)runTestsWithError:(NSError * __autoreleasing *)error
{
    DSJSONSchema *schema = self.schema;
    NSAssert(schema != nil, @"Instantiate the schema prior to running tests.");
    
    for (DSJSONSchemaTest *test in self.tests) {
        NSError *internalError = nil;
        BOOL valid = [schema validateObject:test.testData withError:&internalError];
        if (valid == NO && internalError == nil) {
            *error = [NSError errorWithDomain:@"com.argentumko.JSONSchemaValidationTests" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Validation failed, but no error was returned." }];
            NSLog(@"Test '%@' failed.", test);
            return NO;
        }
        
        if (valid == NO && test.isValid == YES) {
            if (error != NULL) {
                *error = internalError;
            }
            NSLog(@"Test '%@' failed.", test);
            return NO;
        } else if (valid == YES && test.isValid == NO) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.argentumko.JSONSchemaValidationTests" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Invalid test has passed schema validation." }];
            }
            NSLog(@"Test '%@' failed.", test);
            return NO;
        }
    }
    
    return YES;
}

@end

@implementation DSJSONSchemaTest

+ (instancetype)testWithObject:(NSDictionary<NSString *, id> *)testObject
{
    NSString *description = testObject[@"description"];
    id testData = testObject[@"data"];
    BOOL valid = [testObject[@"valid"] boolValue];
    
    return [[self alloc] initWithDescription:description data:testData valid:valid];
}

- (instancetype)initWithDescription:(NSString *)description data:(id)data valid:(BOOL)valid
{
    self = [super init];
    if (self) {
        _testDescription = description;
        _testData = data;
        _isValid = valid;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ '%@', isValid: %@ }", self.testDescription, self.isValid ? @"YES" : @"NO"];
}

@end
