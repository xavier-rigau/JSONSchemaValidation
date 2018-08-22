//
//  DSJSONSchemaTests.m
//  DSJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DSJSONSchemaBaseTests.h"
#import "DSJSONSchema.h"
#import "DSJSONSchemaTestCase.h"

@interface DSJSONSchemaDraft7Tests : DSJSONSchemaBaseTests
{
    NSArray<DSJSONSchemaTestCase *> *_testSuite;
}

@end

@implementation DSJSONSchemaDraft7Tests

+ (DSJSONSchemaSpecification *)specification
{
    return [DSJSONSchemaSpecification draft7];
}

- (void)setUp
{
    [super setUp];

    // prepare URLs of test cases
    NSArray<NSURL *> *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"draft7"];
    if (urls.count == 0) {
        XCTFail(@"No JSON test cases found.");
    }
    
    // load all test cases
    NSMutableArray<DSJSONSchemaTestCase *> *testSuite = [NSMutableArray array];
    for (NSURL *url in urls) {
        NSArray<DSJSONSchemaTestCase *> *testCases = [DSJSONSchemaTestCase testCasesWithContentsOfURL:url specification:[self.class specification]];
        if (testCases != nil) {
            [testSuite addObjectsFromArray:testCases];
        } else {
            XCTFail(@"Failed to parse test cases from %@.", url);
        }
    }
    
    _testSuite = [testSuite copy];
    
    NSLog(@"Loaded %lu test cases.", (unsigned long)testSuite.count);
}

- (void)testSchemasInstantiationOnlyDraft7
{
    [self measureBlock:^{
        NSError *error = nil;
        for (DSJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationDraft7
{
    // have to instantiate the schemas first!
    for (DSJSONSchemaTestCase *testCase in _testSuite) {
        BOOL success = [testCase instantiateSchemaWithReferenceStorage:_referenceStorage error:NULL];
        if (success == NO) {
            XCTFail(@"Failed to instantiate schema for test case '%@'.", testCase.testCaseDescription);
            return;
        }
    }
    
    [self measureBlock:^{
        NSError *error = nil;
        for (DSJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

@end
