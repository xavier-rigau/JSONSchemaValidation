//
//  NSObject+DSJSONComparisonTests.m
//  DSJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+DSJSONComparison.h"
#import "NSNumber+DSJSONNumberTypes.h"
#import "NSArray+DSJSONComparison.h"
#import "NSDictionary+DSJSONComparison.h"

@interface NSObject_DSJSONComparisonTests : XCTestCase

@end

@implementation NSObject_DSJSONComparisonTests

- (void)testObjectsComparison
{
    XCTAssertFalse([@[ @"test" ] vv_isJSONTypeStrictEqual:@YES]);
    XCTAssertFalse([@{ @"key" : @"object" } vv_isJSONTypeStrictEqual:@YES]);
    XCTAssertFalse([@"test" vv_isJSONTypeStrictEqual:@YES]);
    XCTAssertFalse([@[ @"test" ] vv_isJSONTypeStrictEqual:@1]);
    XCTAssertFalse([@{ @"key" : @"object" } vv_isJSONTypeStrictEqual:@1]);
    XCTAssertFalse([@"test" vv_isJSONTypeStrictEqual:@1]);
    
    XCTAssertTrue([@[ @"test" ] vv_isJSONTypeStrictEqual:@[ @"test" ]]);
    XCTAssertTrue([@{ @"key" : @"object" } vv_isJSONTypeStrictEqual:@{ @"key" : @"object" }]);
    XCTAssertTrue([@"test" vv_isJSONTypeStrictEqual:@"test"]);
    XCTAssertTrue([@1 vv_isJSONTypeStrictEqual:@1]);
    
    XCTAssertFalse([@[ @1 ] vv_isJSONTypeStrictEqual:@[ @1.0 ]]);
    XCTAssertTrue([@[ @1 ] vv_isJSONTypeStrictEqual:@[ @1 ]]);
    XCTAssertFalse([@{ @"key" : @1 } vv_isJSONTypeStrictEqual:@{ @"key" : @1.0 }]);
    XCTAssertTrue([@{ @"key" : @1.0 } vv_isJSONTypeStrictEqual:@{ @"key" : @1.0 }]);
    
    id object1 = @[ @{ @"key" : @1.0 }, @2.0 ];
    id object2 = @[ @{ @"key" : @YES }, @2.0 ];
    XCTAssertFalse([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @[ @{ @"key" : @1.0 }, @NO ];
    object2 = @[ @{ @"key" : @1.0 }, @NO ];
    XCTAssertTrue([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @{ @"key" : @[ @1.0, @0 ] };
    object2 = @{ @"key" : @[ @1, @NO ] };
    XCTAssertFalse([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @{ @"key" : @[ @1.0, @1, @YES ] };
    object2 = @{ @"key" : @[ @1, @YES, @1.0 ] };
    XCTAssertFalse([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @{ @"key" : @[ @1.0, @0, @YES ] };
    object2 = @{ @"key" : @[ @1.0, @0, @YES ] };
    XCTAssertTrue([object1 vv_isJSONTypeStrictEqual:object2]);
}

- (void)testNumbersComparison
{
    XCTAssertFalse([@(YES) ds_isStrictEqualToNumber:@(NO)]);
    XCTAssertTrue([@(YES) ds_isStrictEqualToNumber:@(YES)]);
    XCTAssertFalse([@(10) ds_isStrictEqualToNumber:@(20)]);
    XCTAssertTrue([@(30) ds_isStrictEqualToNumber:@(30)]);
    XCTAssertFalse([@(10.0) ds_isStrictEqualToNumber:@(10.1)]);
    XCTAssertTrue([@(20.0) ds_isStrictEqualToNumber:@(20.0)]);
    
    XCTAssertFalse([@(YES) ds_isStrictEqualToNumber:@(1)]);
    XCTAssertFalse([@(NO) ds_isStrictEqualToNumber:@(0)]);
    XCTAssertFalse([@(YES) ds_isStrictEqualToNumber:@(1.0)]);
    XCTAssertFalse([@(NO) ds_isStrictEqualToNumber:@(0.0)]);
    XCTAssertFalse([@(1) ds_isStrictEqualToNumber:@(1.0)]);
    XCTAssertFalse([@(0) ds_isStrictEqualToNumber:@(0.0)]);
}

- (void)testArrayDuplicates
{
    NSArray *array = @[ @1, @1.0, @YES ];
    XCTAssertFalse([array vv_containsDuplicateJSONItems]);
    array = @[ @0, @0.0, @NO ];
    XCTAssertFalse([array vv_containsDuplicateJSONItems]);
    array = @[ @1.0, @1.0, @NO ];
    XCTAssertTrue([array vv_containsDuplicateJSONItems]);
    array = @[ @1, @1, @NO ];
    XCTAssertTrue([array vv_containsDuplicateJSONItems]);
    array = @[ @NO, @2, @NO ];
    XCTAssertTrue([array vv_containsDuplicateJSONItems]);
    
    array = @[ @[ @NO ], @2, @NO ];
    XCTAssertFalse([array vv_containsDuplicateJSONItems]);
    array = @[ @[ @NO ], @2, @[ @NO ] ];
    XCTAssertTrue([array vv_containsDuplicateJSONItems]);
    array = @[ @[ @NO ], @2, @[ @1 ] ];
    XCTAssertFalse([array vv_containsDuplicateJSONItems]);
}

- (void)testArrayContainsObject
{
    NSArray *array = @[ @"test", @YES ];
    XCTAssertFalse([array vv_containsObjectTypeStrict:@1]);
    XCTAssertFalse([array vv_containsObjectTypeStrict:@1.0]);
    XCTAssertTrue([array vv_containsObjectTypeStrict:@YES]);
    
    array = @[ @"test", @[ @YES ], @{ @"key" : @0.0 } ];
    XCTAssertFalse([array vv_containsObjectTypeStrict:@[ @1 ]]);
    XCTAssertTrue([array vv_containsObjectTypeStrict:@[ @YES ]]);
    XCTAssertFalse([array vv_containsObjectTypeStrict:@{ @"key" : @0 }]);
    XCTAssertTrue([array vv_containsObjectTypeStrict:@{ @"key" : @0.0 }]);
    XCTAssertFalse([array vv_containsObjectTypeStrict:@{ @"keys" : @0.0 }]);
}

@end
