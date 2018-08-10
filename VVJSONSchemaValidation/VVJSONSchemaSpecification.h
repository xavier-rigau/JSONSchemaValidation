//
//  VVJSONSchemaSpecification.h
//  VVJSONSchemaValidation
//
//  Created by Andrew Podkovyrin on 10/08/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VVJSONSchemaSpecificationVersion) {
    VVJSONSchemaSpecificationVersionDraft4,
    VVJSONSchemaSpecificationVersionDraft6,
};

@interface VVJSONSchemaSpecification : NSObject

@property (readonly, assign, nonatomic) VVJSONSchemaSpecificationVersion version;

+ (instancetype)draft4;
+ (instancetype)draft6;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
