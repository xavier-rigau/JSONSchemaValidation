//
//  NSNumber+DSNumberTypesTests.m
//  DSJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NSNumber+DSJSONNumberTypes.h"

@interface NSNumber_DSJSONNumberTypesTests : XCTestCase

@end

@implementation NSNumber_DSJSONNumberTypesTests

- (void)testBooleanTypes
{
    XCTAssertTrue([@(YES) ds_isBoolean]);
    XCTAssertTrue([@(NO) ds_isBoolean]);
    XCTAssertFalse([@(1) ds_isBoolean]);
    XCTAssertFalse([@(0) ds_isBoolean]);
    XCTAssertFalse([@(100) ds_isBoolean]);
    XCTAssertFalse([@(-100) ds_isBoolean]);
    XCTAssertFalse([@(0.0) ds_isBoolean]);
    XCTAssertFalse([@(1.0) ds_isBoolean]);
    XCTAssertFalse([@(1.3) ds_isBoolean]);
    XCTAssertFalse([@(-1.3) ds_isBoolean]);
    XCTAssertFalse([@(5e32) ds_isBoolean]);
}

- (void)testIntegerTypes
{
    XCTAssertFalse([@(YES) ds_isInteger]);
    XCTAssertFalse([@(NO) ds_isInteger]);
    XCTAssertTrue([@(1) ds_isInteger]);
    XCTAssertTrue([@(0) ds_isInteger]);
    XCTAssertTrue([@(100) ds_isInteger]);
    XCTAssertTrue([@(-100) ds_isInteger]);
    XCTAssertFalse([@(0.0) ds_isInteger]);
    XCTAssertFalse([@(1.0) ds_isInteger]);
    XCTAssertFalse([@(1.3) ds_isInteger]);
    XCTAssertFalse([@(-1.3) ds_isInteger]);
    XCTAssertFalse([@(5e32) ds_isInteger]);
}

- (void)testFloatTypes
{
    XCTAssertFalse([@(YES) ds_isFloat]);
    XCTAssertFalse([@(NO) ds_isFloat]);
    XCTAssertFalse([@(1) ds_isFloat]);
    XCTAssertFalse([@(0) ds_isFloat]);
    XCTAssertFalse([@(100) ds_isFloat]);
    XCTAssertFalse([@(-100) ds_isFloat]);
    XCTAssertTrue([@(0.0) ds_isFloat]);
    XCTAssertTrue([@(1.0) ds_isFloat]);
    XCTAssertTrue([@(1.3) ds_isFloat]);
    XCTAssertTrue([@(-1.3) ds_isFloat]);
    XCTAssertTrue([@(5e32) ds_isFloat]);
}

@end
