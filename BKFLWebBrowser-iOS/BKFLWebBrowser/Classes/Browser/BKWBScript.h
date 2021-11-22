//
//  LJWBScript.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/6/4.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKWBScript : NSObject

/// 字符串化脚本
@property (class, nonatomic, copy, readonly, nullable) NSString *stringifySource;

/// 上下文脚本
@property (class, nonatomic, copy, readonly, nullable) NSString *contextSource;

/// 从资源读取source
/// @param fileName 文件名
+ (NSString * _Nullable)sourceFromResource:(NSString *)fileName;

/// 从资源读取source
/// @param fileName 文件名
/// @param subspecName 分包名
+ (NSString * _Nullable)sourceFromResource:(NSString *)fileName inSubspec:(NSString *)subspecName;

/// 从资源读取source
/// @param fileName 文件名
/// @param bundleName bundle名
+ (NSString * _Nullable)sourceFromResource:(NSString *)fileName inBundle:(NSString *)bundleName;

/// 从source创建script
/// @param source JS source
+ (WKUserScript * _Nullable)scriptFromSource:(NSString *)source;

/// 从资源创建script
/// @param fileName 文件名
/// @param bundleName bundle名
+ (WKUserScript * _Nullable)scriptFromResource:(NSString *)fileName inBundle:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
