//
//  DSJSONSchemaOptionsTests.m
//  DSJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 22/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DSJSONSchema.h"
#import "DSJSONSchemaTestCase.h"

@interface DSJSONSchemaOptionsTests : XCTestCase
{
    DSJSONSchemaStorage *_referenceStorage;
    NSArray<DSJSONSchemaTestCase *> *_testSuiteBasic;
    NSArray<DSJSONSchemaTestCase *> *_testSuiteFailing;
}

@end

@implementation DSJSONSchemaOptionsTests

+ (DSJSONSchemaSpecification *)specification
{
    return [DSJSONSchemaSpecification draft7];
}

- (void)setUp
{
    [super setUp];
    
    _referenceStorage = [DSJSONSchemaStorage storage];
    
    _testSuiteBasic = [self generateTestSuiteForFilename:@"removeAdditional"];
    _testSuiteFailing = [self generateTestSuiteForFilename:@"removeAdditionalFailing"];
    
    NSLog(@"Loaded %lu test cases.", (unsigned long)_testSuiteBasic.count + (unsigned long)_testSuiteFailing.count);
}

- (void)testSchemasInstantiationOnlyRemoveAdditional
{
    [self measureBlock:^{
        NSError *error = nil;
        for (DSJSONSchemaTestCase *testCase in self->_testSuiteBasic) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationRemoveAdditional
{
    DSJSONSchemaValidationOptions *options = [[DSJSONSchemaValidationOptions alloc] init];
    options.removeAdditional = DSJSONSchemaValidationOptionsRemoveAdditionalYes;
    
    // have to instantiate the schemas first!
    for (DSJSONSchemaTestCase *testCase in _testSuiteBasic) {
        BOOL success = [testCase instantiateSchemaWithReferenceStorage:_referenceStorage options:options error:NULL];
        if (success == NO) {
            XCTFail(@"Failed to instantiate schema for test case '%@'.", testCase.testCaseDescription);
            return;
        }
    }
    
    [self measureBlock:^{
        NSError *error = nil;
        for (DSJSONSchemaTestCase *testCase in self->_testSuiteBasic) {
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasInstantiationOnlyRemoveAdditionalFailing
{
    [self measureBlock:^{
        NSError *error = nil;
        for (DSJSONSchemaTestCase *testCase in self->_testSuiteFailing) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationRemoveAdditionalFailing
{
    DSJSONSchemaValidationOptions *options = [[DSJSONSchemaValidationOptions alloc] init];
    options.removeAdditional = DSJSONSchemaValidationOptionsRemoveAdditionalFailing;
    
    // have to instantiate the schemas first!
    for (DSJSONSchemaTestCase *testCase in _testSuiteFailing) {
        BOOL success = [testCase instantiateSchemaWithReferenceStorage:_referenceStorage options:options error:NULL];
        if (success == NO) {
            XCTFail(@"Failed to instantiate schema for test case '%@'.", testCase.testCaseDescription);
            return;
        }
    }
    
    [self measureBlock:^{
        NSError *error = nil;
        for (DSJSONSchemaTestCase *testCase in self->_testSuiteFailing) {
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

#pragma mark Helpers

- (NSArray<DSJSONSchemaTestCase *> *)generateTestSuiteForFilename:(NSString *)filename
{
    // prepare URLs of test cases
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:@"json" subdirectory:@"options"];
    if (url == nil) {
        XCTFail(@"No JSON test cases found.");
    }
    
    // load all test cases
    NSMutableArray<DSJSONSchemaTestCase *> *testSuite = [NSMutableArray array];
    NSArray<DSJSONSchemaTestCase *> *testCases = [DSJSONSchemaTestCase testCasesWithContentsOfURL:url specification:[self.class specification]];
    if (testCases != nil) {
        [testSuite addObjectsFromArray:testCases];
    } else {
        XCTFail(@"Failed to parse test cases from %@.", url);
    }
    
    return [testSuite copy];
}

@end
