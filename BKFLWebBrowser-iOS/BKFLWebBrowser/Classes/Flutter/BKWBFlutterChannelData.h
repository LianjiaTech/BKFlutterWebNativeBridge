//
//  LJWBFlutterChannelData.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/8.
//

#import <Foundation/Foundation.h>

/**

 [容器<->Flutter]约定
 使用JS类型作为[基本]数据类型，同时补充[常用]数据类型
 interface BridgeData {
    method: string,
    args: any,
    type: string
 }
 
 type对应JS类型：
 https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/typeof

*/

NS_ASSUME_NONNULL_BEGIN

typedef NSString * LJWB_FLUTTER_CHANNEL_DATA_TYPE;

@interface BKWBFlutterChannelData : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, strong) id args;
@property (nonatomic, copy) LJWB_FLUTTER_CHANNEL_DATA_TYPE type;

/// 使用Flutter(JS)数据转换为通道数据
/// @param data Flutter(JS)数据
+ (BKWBFlutterChannelData *)dataWithData:(NSDictionary *)data;

/// 数据
- (NSDictionary *)data;

@end

extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_OBJECT;//[JS]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_FUNC;//[JS]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_SYMBOL;//[JS]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_NUMBER;//[JS]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_BIGINT;//[JS]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_BOOLEAN;//[JS]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_STRING;//[JS]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_UNDEFINED;//[JS]

extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_DATA;//[Native]
extern NSString * const LJWB_FLUTTER_CHANNEL_DATA_TYPE_IMAGE;//[Native]

NS_ASSUME_NONNULL_END
