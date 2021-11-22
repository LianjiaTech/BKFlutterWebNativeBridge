//
//  LJWBFlutterChannelData.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/8.
//

#import "BKWBFlutterChannelData.h"

static const NSString *LJWBFlutterChannelDataMethod = @"method";
static const NSString *LJWBFlutterChannelDataArgs = @"args";
static const NSString *LJWBFlutterChannelDataType = @"type";

@interface BKWBFlutterChannelData ()

@end

@implementation BKWBFlutterChannelData

+ (BKWBFlutterChannelData *)dataWithData:(NSDictionary *)data {
    BKWBFlutterChannelData *_data = [[BKWBFlutterChannelData alloc] init];
    _data.method = data[LJWBFlutterChannelDataMethod];
    _data.type = data[LJWBFlutterChannelDataType];
    
    if([_data.type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_OBJECT]) {
        NSString *args = data[LJWBFlutterChannelDataArgs];
        
        id object;
        NSError *error = nil;

        if ([args isKindOfClass:[NSString class]]) {
            NSData *data = [args dataUsingEncoding:NSUTF8StringEncoding];
                  object = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingFragmentsAllowed
                                                                 error:&error];
        } else {
            object = args;
        }
       
        if(!object) {
            if(error) {
                NSLog(@"%@", error);
            }
        }
        
        _data.args = object;
    } else if([_data.type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_FUNC]) {
        _data.args = data[LJWBFlutterChannelDataArgs];
    } else if([_data.type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_SYMBOL]) {
        _data.args = data[LJWBFlutterChannelDataArgs];
    } else if([_data.type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_NUMBER]) {
        _data.args = data[LJWBFlutterChannelDataArgs];
    } else if([_data.type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_BIGINT]) {
        _data.args = data[LJWBFlutterChannelDataArgs];
    } else if([_data.type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_BOOLEAN]) {
        _data.args = data[LJWBFlutterChannelDataArgs];
    } else if([_data.type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_STRING]) {
        _data.args = data[LJWBFlutterChannelDataArgs];
    } else/*LJWB_FLUTTER_CHANNEL_DATA_TYPE_UNDEFINED*/{
        _data.args = data[LJWBFlutterChannelDataArgs];
    }
    
    return _data;
}

- (NSDictionary *)data {
    NSMutableDictionary *dataM = [@{
        LJWBFlutterChannelDataMethod: _method ? _method : @""
    } mutableCopy];
    
    if([_type isKindOfClass:[NSString class]]) {
        dataM[LJWBFlutterChannelDataType] = _type;
        
        if([_type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_DATA]) {
            NSString *base64 = [_args base64EncodedStringWithOptions:kNilOptions];
            dataM[LJWBFlutterChannelDataArgs] = base64 ? base64 : @"";
        } else if([_type isEqualToString:LJWB_FLUTTER_CHANNEL_DATA_TYPE_IMAGE]) {
            NSString *base64 = [_args base64EncodedStringWithOptions:kNilOptions];
            dataM[LJWBFlutterChannelDataArgs] = base64 ? base64 : @"";
        } else {
            dataM[LJWBFlutterChannelDataArgs] = _args ? _args : @"";
        }
    } else {
        if([_args isKindOfClass:[NSDictionary class]]
           || [_args isKindOfClass:[NSArray class]]) {
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:_args options:NSJSONReadingAllowFragments error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dataM[LJWBFlutterChannelDataType] = LJWB_FLUTTER_CHANNEL_DATA_TYPE_OBJECT;
            dataM[LJWBFlutterChannelDataArgs] = jsonString;
        } else if([_args isKindOfClass:[NSNumber class]]) {
            dataM[LJWBFlutterChannelDataType] = LJWB_FLUTTER_CHANNEL_DATA_TYPE_NUMBER;
            dataM[LJWBFlutterChannelDataArgs] = _args;
        } else if([_args isKindOfClass:[NSString class]]) {
            dataM[LJWBFlutterChannelDataType] = LJWB_FLUTTER_CHANNEL_DATA_TYPE_STRING;
            dataM[LJWBFlutterChannelDataArgs] = _args;
        } else if([_args isKindOfClass:[NSData class]]) {
            dataM[LJWBFlutterChannelDataType] = LJWB_FLUTTER_CHANNEL_DATA_TYPE_DATA;
            NSString *base64 = [_args base64EncodedStringWithOptions:kNilOptions];
            dataM[LJWBFlutterChannelDataArgs] = base64 ? base64 : @"";
        } else if([_args isKindOfClass:[UIImage class]]) {
            dataM[LJWBFlutterChannelDataType] = LJWB_FLUTTER_CHANNEL_DATA_TYPE_IMAGE;
            NSString *base64 = [_args base64EncodedStringWithOptions:kNilOptions];
            dataM[LJWBFlutterChannelDataArgs] = base64 ? base64 : @"";
        } else {
            dataM[LJWBFlutterChannelDataType] = LJWB_FLUTTER_CHANNEL_DATA_TYPE_UNDEFINED;
            dataM[LJWBFlutterChannelDataArgs] = _args;
        }
    }
    
    return [dataM copy];
}

@end

NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_OBJECT = @"object";//[JS]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_FUNC = @"function";//[JS]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_SYMBOL = @"symbol";//[JS]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_NUMBER = @"number";//[JS]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_BIGINT = @"bigint";//[JS]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_BOOLEAN = @"boolean";//[JS]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_STRING = @"string";//[JS]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_UNDEFINED = @"undefined";//[JS]

NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_DATA = @"data";//[Native]
NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_IMAGE = @"image";//[Native]
