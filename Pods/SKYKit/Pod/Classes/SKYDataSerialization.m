//
//  SKYDataSerialization.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYDataSerialization.h"

#import <CoreLocation/CoreLocation.h>

#import "SKYAsset_Private.h"
#import "SKYError.h"
#import "SKYReference.h"
#import "SKYSequence.h"

NSString *const SKYDataSerializationCustomTypeKey = @"$type";
NSString *const SKYDataSerializationAssetType = @"asset";
NSString *const SKYDataSerializationReferenceType = @"ref";
NSString *const SKYDataSerializationDateType = @"date";
NSString *const SKYDataSerializationLocationType = @"geo";
NSString *const SKYDataSerializationRelationType = @"relation";
NSString *const SKYDataSerializationSequenceType = @"seq";

static NSDictionary *remoteFunctionNameDict;
static NSDictionary *localFunctionNameDict;

NSString *remoteFunctionName(NSString *localFunctionName)
{
    if ([localFunctionName isEqualToString:@"distanceToLocation:fromLocation:"]) {
        return @"distance";
    } else {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:@"Unrecgonized local function name `%@`",
                                                         localFunctionName]
                     userInfo:nil];
    }
}

NSString *localFunctionName(NSString *remoteFunctionName)
{
    if ([remoteFunctionName isEqualToString:@"distance"]) {
        return @"distanceToLocation:fromLocation:";
    } else {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:@"Unrecgonized remote function name `%@`",
                                                         remoteFunctionName]
                     userInfo:nil];
    }
}

@implementation SKYDataSerialization

+ (id)deserializeSimpleObjectWithType:(NSString *)type value:(NSDictionary *)data
{
    id obj = nil;
    if ([type isEqualToString:SKYDataSerializationDateType]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        obj = [formatter dateFromString:data[@"$date"]];
    } else if ([type isEqualToString:SKYDataSerializationReferenceType]) {
        SKYRecordID *recordID = [[SKYRecordID alloc] initWithCanonicalString:data[@"$id"]];
        obj = [[SKYReference alloc] initWithRecordID:recordID];
    } else if ([type isEqualToString:SKYDataSerializationAssetType]) {
        obj = [self deserializeAssetWithDictionary:data];
    } else if ([type isEqualToString:SKYDataSerializationLocationType]) {
        obj = [self deserializeLocationWithDictionary:data];
    } else if ([type isEqualToString:SKYDataSerializationRelationType]) {
        obj = [self deserializeRelationWithDictionary:data];
    } else if ([type isEqualToString:SKYDataSerializationSequenceType]) {
        obj = [SKYSequence sequence];
    }
    return obj;
}

+ (id)deserializeObjectWithValue:(id)value
{
    if (!value) {
        return nil;
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)value
            enumerateObjectsUsingBlock:^(id valueInArray, NSUInteger idx, BOOL *stop) {
                [newArray addObject:[self deserializeObjectWithValue:valueInArray]];
            }];
        return newArray;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *type = [(NSDictionary *)value objectForKey:SKYDataSerializationCustomTypeKey];
        if (type) {
            return [self deserializeSimpleObjectWithType:type value:value];
        } else {
            NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
            [(NSDictionary *)value
                enumerateKeysAndObjectsUsingBlock:^(id key, id valueInDictionary, BOOL *stop) {
                    [newDictionary setObject:[self deserializeObjectWithValue:valueInDictionary]
                                      forKey:key];
                }];
            return newDictionary;
        }
    } else {
        return value;
    }
}

+ (SKYAsset *)deserializeAssetWithDictionary:(NSDictionary *)data
{
    NSString *name = data[@"$name"];
    NSString *rawURL = data[@"$url"];

    NSURL *url = nil;
    if (name.length && rawURL.length) {
        url = [NSURL URLWithString:rawURL];
    } else {
        return nil;
    }

    return [SKYAsset assetWithName:name url:url];
}

+ (CLLocation *)deserializeLocationWithDictionary:(NSDictionary *)data
{
    double lng = [data[@"$lng"] doubleValue];
    double lat = [data[@"$lat"] doubleValue];

    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng)
                                         altitude:0
                               horizontalAccuracy:0
                                 verticalAccuracy:0
                                        timestamp:[NSDate dateWithTimeIntervalSince1970:0]];
}

+ (SKYRelation *)deserializeRelationWithDictionary:(NSDictionary *)data
{
    NSString *name = data[@"$name"];
    if ([name isEqualToString:@"_friend"]) {
        name = @"friend";
    } else if ([name isEqualToString:@"_follow"]) {
        name = @"follow";
    }

    SKYRelationDirection direction;
    if ([data[@"$direction"] isEqualToString:@"outward"]) {
        direction = SKYRelationDirectionOutward;
    } else if ([data[@"$direction"] isEqualToString:@"inward"]) {
        direction = SKYRelationDirectionInward;
    } else if ([data[@"$direction"] isEqualToString:@"mutual"]) {
        direction = SKYRelationDirectionMutual;
    } else {
        NSLog(@"Unexpected relation direction %@. Assuming direction is outward.",
              data[@"$direction"]);
        direction = SKYRelationDirectionOutward;
    }

    return [SKYRelation relationWithName:name direction:direction];
}

+ (id)serializeSimpleObject:(id)obj
{
    id data = nil;
    if ([obj isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        data = @{
            SKYDataSerializationCustomTypeKey : SKYDataSerializationDateType,
            @"$date" : [formatter stringFromDate:obj],
        };
    } else if ([obj isKindOfClass:[SKYReference class]]) {
        data = @{
            SKYDataSerializationCustomTypeKey : SKYDataSerializationReferenceType,
            @"$id" : [(SKYReference *)obj recordID].canonicalString,
        };
    } else if ([obj isKindOfClass:[SKYAsset class]]) {
        data = @{
            SKYDataSerializationCustomTypeKey : SKYDataSerializationAssetType,
            @"$name" : [obj name],
        };
    } else if ([obj isKindOfClass:[CLLocation class]]) {
        CLLocationCoordinate2D coordinate = [obj coordinate];
        data = @{
            SKYDataSerializationCustomTypeKey : SKYDataSerializationLocationType,
            @"$lng" : @(coordinate.longitude),
            @"$lat" : @(coordinate.latitude),
        };
    } else if ([obj isKindOfClass:[SKYRelation class]]) {
        SKYRelation *relation = (SKYRelation *)obj;
        NSString *name = relation.name;
        if ([name isEqualToString:@"follow"]) {
            name = @"_follow";
        } else if ([name isEqualToString:@"friend"]) {
            name = @"_friend";
        }

        NSString *direction;
        switch (relation.direction) {
            case SKYRelationDirectionInward:
                direction = @"inward";
                break;
            case SKYRelationDirectionOutward:
                direction = @"outward";
                break;
            case SKYRelationDirectionMutual:
                direction = @"mutual";
                break;
            default:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"Unexpected relation direction."
                                             userInfo:nil];
        }

        data = @{
            SKYDataSerializationCustomTypeKey : SKYDataSerializationRelationType,
            @"$name" : name,
            @"$direction" : direction,
        };
    } else if ([obj isKindOfClass:[SKYSequence class]]) {
        data = @{ @"$type" : @"seq" };
    } else {
        data = obj;
    }
    return data;
}

+ (id)serializeObject:(id)obj
{
    if (!obj) {
        return nil;
    }

    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id objInArray, NSUInteger idx, BOOL *stop) {
            [newArray addObject:[self serializeObject:objInArray]];
        }];
        return newArray;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        [(NSDictionary *)obj
            enumerateKeysAndObjectsUsingBlock:^(id key, id objInDictionary, BOOL *stop) {
                [newDictionary setObject:[self serializeObject:objInDictionary] forKey:key];
            }];
        return newDictionary;
    } else {
        return [self serializeSimpleObject:obj];
    }
}

@end
