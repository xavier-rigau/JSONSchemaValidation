//
//  VVJSONSchemaBaseTests.h
//  VVJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 17/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VVJSONSchema.h"

@interface VVJSONSchemaBaseTests : XCTestCase {
    VVJSONSchemaStorage *_referenceStorage;
}

+ (VVJSONSchemaSpecification *)specification;

@end
