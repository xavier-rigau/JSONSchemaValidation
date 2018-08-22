//
//  VVJSONSchemaOptionsTests.m
//  VVJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 22/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VVJSONSchema.h"
#import "VVJSONSchemaTestCase.h"

@interface VVJSONSchemaOptionsTests : XCTestCase
{
    VVJSONSchemaStorage *_referenceStorage;
    NSArray<VVJSONSchemaTestCase *> *_testSuiteBasic;
    NSArray<VVJSONSchemaTestCase *> *_testSuiteFailing;
}

@end

@implementation VVJSONSchemaOptionsTests

+ (VVJSONSchemaSpecification *)specification
{
    return [VVJSONSchemaSpecification draft7];
}

- (void)setUp
{
    [super setUp];
    
    _referenceStorage = [VVJSONSchemaStorage storage];
    
    _testSuiteBasic = [self generateTestSuiteForFilename:@"removeAdditional"];
    _testSuiteFailing = [self generateTestSuiteForFilename:@"removeAdditionalFailing"];
    
    NSLog(@"Loaded %lu test cases.", (unsigned long)_testSuiteBasic.count + (unsigned long)_testSuiteFailing.count);
}

- (void)testSchemasInstantiationOnlyRemoveAdditional
{
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuiteBasic) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationRemoveAdditional
{
    VVJSONSchemaValidationOptions *options = [[VVJSONSchemaValidationOptions alloc] init];
    options.removeAdditional = VVJSONSchemaValidationOptionsRemoveAdditionalYes;
    
    // have to instantiate the schemas first!
    for (VVJSONSchemaTestCase *testCase in _testSuiteBasic) {
        BOOL success = [testCase instantiateSchemaWithReferenceStorage:_referenceStorage options:options error:NULL];
        if (success == NO) {
            XCTFail(@"Failed to instantiate schema for test case '%@'.", testCase.testCaseDescription);
            return;
        }
    }
    
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuiteBasic) {
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasInstantiationOnlyRemoveAdditionalFailing
{
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuiteFailing) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationRemoveAdditionalFailing
{
    VVJSONSchemaValidationOptions *options = [[VVJSONSchemaValidationOptions alloc] init];
    options.removeAdditional = VVJSONSchemaValidationOptionsRemoveAdditionalFailing;
    
    // have to instantiate the schemas first!
    for (VVJSONSchemaTestCase *testCase in _testSuiteFailing) {
        BOOL success = [testCase instantiateSchemaWithReferenceStorage:_referenceStorage options:options error:NULL];
        if (success == NO) {
            XCTFail(@"Failed to instantiate schema for test case '%@'.", testCase.testCaseDescription);
            return;
        }
    }
    
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuiteFailing) {
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

#pragma mark Helpers

- (NSArray<VVJSONSchemaTestCase *> *)generateTestSuiteForFilename:(NSString *)filename
{
    // prepare URLs of test cases
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:@"json" subdirectory:@"options"];
    if (url == nil) {
        XCTFail(@"No JSON test cases found.");
    }
    
    // load all test cases
    NSMutableArray<VVJSONSchemaTestCase *> *testSuite = [NSMutableArray array];
    NSArray<VVJSONSchemaTestCase *> *testCases = [VVJSONSchemaTestCase testCasesWithContentsOfURL:url specification:[self.class specification]];
    if (testCases != nil) {
        [testSuite addObjectsFromArray:testCases];
    } else {
        XCTFail(@"Failed to parse test cases from %@.", url);
    }
    
    return [testSuite copy];
}

@end
