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

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface DSJSONSchemaDraft4Tests : DSJSONSchemaBaseTests
{
    NSArray<DSJSONSchemaTestCase *> *_testSuite;
}

@end

@implementation DSJSONSchemaDraft4Tests

+ (DSJSONSchemaSpecification *)specification
{
    return [DSJSONSchemaSpecification draft4];
}

- (void)setUp
{
    [super setUp];

    // prepare URLs of test cases
    NSArray<NSURL *> *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"draft4"];
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

- (void)testSchemasInstantiationOnlyDraft4
{
    [self measureBlock:^{
        NSError *error = nil;
        for (DSJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidationDraft4
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

- (void)testPerformanceDraft4
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"advanced-example" withExtension:@"json" subdirectory:@"draft4"];
    DSJSONSchemaTestCase *testCase = [[DSJSONSchemaTestCase testCasesWithContentsOfURL:url specification:[self.class specification]] firstObject];

    CFTimeInterval startTime = CACurrentMediaTime();
    BOOL success = [testCase instantiateSchemaWithReferenceStorage:nil error:NULL];
    if (success == NO) {
        XCTFail(@"Invalid test case.");
        return;
    }
    CFTimeInterval firstInstantiationTime = CACurrentMediaTime() - startTime;
    NSLog(@"First instantiation time: %.2f ms", (firstInstantiationTime * 1000.0));
    
    uint64_t nanoseconds = dispatch_benchmark(1000, ^{
        [testCase instantiateSchemaWithReferenceStorage:nil error:NULL];
    });
    NSLog(@"Average instantiation time: %.2f ms", (nanoseconds * 1e-6));
    
    startTime = CACurrentMediaTime();
    success = [testCase runTestsWithError:NULL];
    if (success == NO) {
        XCTFail(@"Invalid test case.");
        return;
    }
    CFTimeInterval firstValidationTime = CACurrentMediaTime() - startTime;
    NSLog(@"First validation time: %.2f ms", (firstValidationTime * 1000.0));

    nanoseconds = dispatch_benchmark(1000, ^{
        [testCase runTestsWithError:NULL];
    });
    NSLog(@"Average validation time: %.2f ms", (nanoseconds * 1e-6));
}

- (void)testMultithreadingDraft4
{
    dispatch_queue_t queue = dispatch_queue_create("com.argentumko.DSJSONSchemaTests.Parallelism", DISPATCH_QUEUE_CONCURRENT);

    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"advanced-example" withExtension:@"json" subdirectory:@"draft4"];
    DSJSONSchemaTestCase *testCase = [[DSJSONSchemaTestCase testCasesWithContentsOfURL:url specification:[self.class specification]] firstObject];
    NSDictionary<NSString *, id> *schemaObject = testCase.schemaObject;
    
    for (NSUInteger parallelism = 0; parallelism < 10; parallelism++) {
        dispatch_async(queue, ^{
            DSJSONSchema *schema = [DSJSONSchema schemaWithObject:schemaObject baseURI:nil referenceStorage:self->_referenceStorage specification:[self.class specification] options:nil error:NULL];
            XCTAssertNotNil(schema);
        });
    }
    dispatch_sync(queue, ^{});
    
    [testCase instantiateSchemaWithReferenceStorage:_referenceStorage error:NULL];
    for (NSUInteger parallelism = 0; parallelism < 10; parallelism++) {
        dispatch_async(queue, ^{
            BOOL success = [testCase runTestsWithError:NULL];
            XCTAssertTrue(success);
        });
    }
    dispatch_sync(queue, ^{});
}

@end
