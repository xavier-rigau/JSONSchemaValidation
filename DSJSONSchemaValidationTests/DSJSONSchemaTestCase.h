//
//  DSJSONSchemaTestCase.h
//  DSJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <XCTest/XCTest.h>

@class DSJSONSchema;
@class DSJSONSchemaStorage;
@class DSJSONSchemaSpecification;
@class DSJSONSchemaValidationOptions;
@class DSJSONSchemaTest;

@interface DSJSONSchemaTestCase : NSObject

@property (nonatomic, readonly, copy) NSString *testCaseDescription;
@property (nonatomic, readonly, copy) NSDictionary<NSString *, id> *schemaObject;
@property (nonatomic, readonly, copy) NSArray<DSJSONSchemaTest *> *tests;
@property (nonatomic, readonly, strong) DSJSONSchema *schema;

+ (instancetype)testCaseWithObject:(NSDictionary<NSString *, id> *)testCaseObject specification:(DSJSONSchemaSpecification *)specification;
+ (NSArray<DSJSONSchemaTestCase *> *)testCasesWithContentsOfURL:(NSURL *)testCasesJSONURL specification:(DSJSONSchemaSpecification *)specification;

- (instancetype)initWithDescription:(NSString *)description schemaObject:(NSDictionary<NSString *, id> *)schemaObject tests:(NSArray<DSJSONSchemaTest *> *)tests specification:(DSJSONSchemaSpecification *)specification;

- (BOOL)instantiateSchemaWithReferenceStorage:(DSJSONSchemaStorage *)schemaStorage error:(NSError * __autoreleasing *)error;
- (BOOL)instantiateSchemaWithReferenceStorage:(DSJSONSchemaStorage *)schemaStorage options:(nullable DSJSONSchemaValidationOptions *)options error:(NSError *__autoreleasing *)error;
- (BOOL)runTestsWithError:(NSError * __autoreleasing *)error;

@end

@interface DSJSONSchemaTest : NSObject

@property (nonatomic, readonly, strong) NSString *testDescription;
@property (nonatomic, readonly, strong) id testData;
@property (nullable, nonatomic, readonly, strong) id shouldBeData;
@property (nonatomic, readonly, assign) BOOL isValid;

+ (instancetype)testWithObject:(NSDictionary<NSString *, id> *)testObject;

- (instancetype)initWithDescription:(NSString *)description data:(id)data shouldBeData:(nullable id)shouldBeData valid:(BOOL)valid;

@end
