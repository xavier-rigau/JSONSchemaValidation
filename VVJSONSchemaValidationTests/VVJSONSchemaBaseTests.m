//
//  VVJSONSchemaBaseTests.m
//  VVJSONSchemaValidationTests
//
//  Created by Andrew Podkovyrin on 17/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import "VVJSONSchemaBaseTests.h"
#import "VVJSONSchemaFormatValidator.h"

@implementation VVJSONSchemaBaseTests

+ (VVJSONSchemaSpecification *)specification
{
    return [VVJSONSchemaSpecification draft6];
}

+ (void)setUp
{
    [super setUp];
    
    // register custom format validators
    NSRegularExpression *noDigitsRegex = [NSRegularExpression regularExpressionWithPattern:@"^[^\\d]*$" options:(NSRegularExpressionOptions)0 error:NULL];
    [VVJSONSchemaFormatValidator registerFormat:@"com.argentumko.json.string-without-digits" withRegularExpression:noDigitsRegex error:NULL];
    [VVJSONSchemaFormatValidator registerFormat:@"com.argentumko.json.uuid" withBlock:^BOOL(id instance) {
        return [instance isKindOfClass:[NSString class]] == NO || [[NSUUID alloc] initWithUUIDString:instance] != nil;
    } error:NULL];
}

- (void)setUp
{
    [super setUp];
    
    // load reference schemas
    _referenceStorage = [self.class remoteSchemasReferenceStorage];
}

#pragma mark - Helpers

+ (VVJSONSchemaStorage *)remoteSchemasReferenceStorage
{
    static NSString * const kBaseRemoteSchemasURIString = @"http://localhost:1234/";
    
    VVMutableJSONSchemaStorage *storage = [VVMutableJSONSchemaStorage storage];
    NSURL *baseRemoteSchemasURI = [NSURL URLWithString:kBaseRemoteSchemasURIString];
    
    NSArray<NSURL *> *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"remotes"];
    for (NSURL *url in urls) {
        NSString *documentName = url.lastPathComponent;
        NSURL *schemaURI = [NSURL URLWithString:documentName relativeToURL:baseRemoteSchemasURI];
        [self addSchemaFromURL:url withScopeURI:schemaURI intoStorage:storage];
    }
    
    NSArray<NSURL *> *subfolderURLs = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"remotes/folder"];
    for (NSURL *url in subfolderURLs) {
        NSString *documentName = url.lastPathComponent;
        NSURL *schemaURI = [NSURL URLWithString:[@"folder" stringByAppendingPathComponent:documentName] relativeToURL:baseRemoteSchemasURI];
        [self addSchemaFromURL:url withScopeURI:schemaURI intoStorage:storage];
    }
    
    return [storage copy];
}

+ (void)addSchemaFromURL:(NSURL *)url withScopeURI:(NSURL *)scopeURI intoStorage:(VVMutableJSONSchemaStorage *)storage
{
    NSData *schemaData = [NSData dataWithContentsOfURL:url];
    VVJSONSchema *schema = [VVJSONSchema schemaWithData:schemaData baseURI:scopeURI referenceStorage:nil specification:[self specification] error:NULL];
    if (schema == nil) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to instantiate reference schema from %@.", url];
    }
    
    BOOL success = [storage addSchema:schema];
    if (success == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to add reference schema from %@ into the storage.", url];
    }
}

@end
