//
//  VVJSONSchemaTests.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <QuartzCore/QuartzCore.h>
#import "VVJSONSchema.h"
#import "VVJSONSchemaFormatValidator.h"
#import "VVJSONSchemaTestCase.h"

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface VVJSONSchemaDraft6Tests : XCTestCase
{
    VVJSONSchemaStorage *_referenceStorage;
    NSArray<VVJSONSchemaTestCase *> *_testSuite;
}

@end

@implementation VVJSONSchemaDraft6Tests

+ (void)setUp
{
    [super setUp];
    
    // register custom format validators
    NSRegularExpression *noDigitsRegex = [NSRegularExpression regularExpressionWithPattern:@"^[^\\d]*$" options:(NSRegularExpressionOptions)0 error:NULL];
    [VVJSONSchemaFormatValidator registerFormat:@"com.argentumko.json.string-without-digits" withRegularExpression:noDigitsRegex error:NULL];
    [VVJSONSchemaFormatValidator registerFormat:@"com.argentumko.json.uuid" withBlock:^BOOL(id instance) {
        return [instance isKindOfClass:[NSString class]] == NO || [[NSUUID alloc] initWithUUIDString:instance] != nil;
    } error:NULL];
}

- (void)setUp
{
    [super setUp];

    // prepare URLs of test cases
    NSArray<NSURL *> *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"draft6"];
    if (urls.count == 0) {
        XCTFail(@"No JSON test cases found.");
    }
    
    // load all test cases
    NSMutableArray<VVJSONSchemaTestCase *> *testSuite = [NSMutableArray array];
    for (NSURL *url in urls) {
        NSArray<VVJSONSchemaTestCase *> *testCases = [VVJSONSchemaTestCase testCasesWithContentsOfURL:url specification:[self.class specification]];
        if (testCases != nil) {
            [testSuite addObjectsFromArray:testCases];
        } else {
            XCTFail(@"Failed to parse test cases from %@.", url);
        }
    }
    
    _testSuite = [testSuite copy];
    
    // load reference schemas
    _referenceStorage = [self.class remoteSchemasReferenceStorage];
    
    NSLog(@"Loaded %lu test cases.", (unsigned long)testSuite.count);
}

+ (VVJSONSchemaSpecification *)specification
{
    return [VVJSONSchemaSpecification draft6];
}

+ (VVJSONSchemaStorage *)remoteSchemasReferenceStorage
{
    static NSString * const kBaseRemoteSchemasURIString = @"http://localhost:1234/";

    VVMutableJSONSchemaStorage *storage = [VVMutableJSONSchemaStorage storage];
    NSURL *baseRemoteSchemasURI = [NSURL URLWithString:kBaseRemoteSchemasURIString];
    
    NSArray<NSURL *> *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"remotes"];
    for (NSURL *url in urls) {
        NSString *documentName = url.lastPathComponent;
        NSURL *schemaURI = [NSURL URLWithString:documentName relativeToURL:baseRemoteSchemasURI];
        [self addSchemaFromURL:url withScopeURI:schemaURI intoStorage:storage];
    }
    
    NSArray<NSURL *> *subfolderURLs = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"remotes/folder"];
    for (NSURL *url in subfolderURLs) {
        NSString *documentName = url.lastPathComponent;
        NSURL *schemaURI = [NSURL URLWithString:[@"folder" stringByAppendingPathComponent:documentName] relativeToURL:baseRemoteSchemasURI];
        [self addSchemaFromURL:url withScopeURI:schemaURI intoStorage:storage];
    }
    
    return [storage copy];
}

+ (void)addSchemaFromURL:(NSURL *)url withScopeURI:(NSURL *)scopeURI intoStorage:(VVMutableJSONSchemaStorage *)storage
{
    NSData *schemaData = [NSData dataWithContentsOfURL:url];
    VVJSONSchema *schema = [VVJSONSchema schemaWithData:schemaData baseURI:scopeURI referenceStorage:nil specification:[self specification] error:NULL];
    if (schema == nil) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to instantiate reference schema from %@.", url];
    }
    
    BOOL success = [storage addSchema:schema];
    if (success == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to add reference schema from %@ into the storage.", url];
    }
}

- (void)testSchemasDraft6InstantiationOnly
{
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasDraft6Validation
{
    // have to instantiate the schemas first!
    for (VVJSONSchemaTestCase *testCase in _testSuite) {
        BOOL success = [testCase instantiateSchemaWithReferenceStorage:_referenceStorage error:NULL];
        if (success == NO) {
            XCTFail(@"Failed to instantiate schema for test case '%@'.", testCase.testCaseDescription);
            return;
        }
    }
    
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

@end
