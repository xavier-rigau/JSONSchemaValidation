//
//  DSJSONSchemaBaseTests.h
//  DSJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 17/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DSJSONSchema.h"

@interface DSJSONSchemaBaseTests : XCTestCase {
    DSJSONSchemaStorage *_referenceStorage;
}

+ (DSJSONSchemaSpecification *)specification;

@end
