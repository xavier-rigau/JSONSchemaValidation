//
//  VVJSONSchemaRemoveAdditionalTests.m
//  VVJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 22/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VVJSONSchema.h"
#import "VVJSONSchemaTestCase.h"

@interface VVJSONSchemaRemoveAdditionalTests : XCTestCase
{
    VVJSONSchemaStorage *_referenceStorage;
    NSArray<VVJSONSchemaTestCase *> *_testSuite;
}

@end

@implementation VVJSONSchemaRemoveAdditionalTests

+ (VVJSONSchemaSpecification *)specification
{
    return [VVJSONSchemaSpecification draft7];
}

- (void)setUp
{
    [super setUp];
    
    _referenceStorage = [VVJSONSchemaStorage storage];
    
    // prepare URLs of test cases
    NSArray<NSURL *> *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:nil];
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

- (void)testSchemasInstantiationOnlyRemoveAdditional
{
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationRemoveAdditional
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
