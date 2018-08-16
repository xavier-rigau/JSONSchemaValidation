//
//  VVJSONSchemaTests.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VVJSONSchemaBaseTests.h"
#import "VVJSONSchema.h"
#import "VVJSONSchemaTestCase.h"

@interface VVJSONSchemaDraft6Tests : VVJSONSchemaBaseTests
{
    NSArray<VVJSONSchemaTestCase *> *_testSuite;
}

@end

@implementation VVJSONSchemaDraft6Tests

+ (VVJSONSchemaSpecification *)specification
{
    return [VVJSONSchemaSpecification draft6];
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
    
    NSLog(@"Loaded %lu test cases.", (unsigned long)testSuite.count);
}

- (void)testSchemasInstantiationOnlyDraft6
{
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationDraft6
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
