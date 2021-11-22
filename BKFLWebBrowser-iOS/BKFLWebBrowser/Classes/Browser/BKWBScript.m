//
//  LJWBScript.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/6/4.
//

#import "BKWBScript.h"
#import "BKWBCache.h"

#define LJWEBBROWSER_FRAMEWORK @"BKFLWebBrowser"

@implementation BKWBScript

+ (NSString *_Nullable)stringifySource {
    return [self sourceFromResource:@"stringify"];
}

+ (NSString *_Nullable)contextSource {
    return [self sourceFromResource:@"context"];
}

+ (NSString * _Nullable)sourceFromResource:(NSString *)fileName {
    NSString *bundleName = LJWEBBROWSER_FRAMEWORK;
    return [self sourceFromResource:fileName inBundle:bundleName];
}

+ (NSString * _Nullable)sourceFromResource:(NSString *)fileName inSubspec:(NSString *)subspecName {
    NSString *bundleName = LJWEBBROWSER_FRAMEWORK;
    bundleName = [bundleName stringByAppendingFormat:@"_%@", subspecName];
    return [self sourceFromResource:fileName inBundle:bundleName];
}

+ (NSString * _Nullable)sourceFromResource:(NSString *)fileName inBundle:(NSString *)bundleName {    
    NSString *identifier = [bundleName stringByAppendingString:@".bundle"];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [bundle.bundlePath stringByAppendingPathComponent:identifier];
    bundle = [NSBundle bundleWithPath:bundlePath];
    NSError *error = nil;
    
    NSString *_fileName = fileName;
    if([fileName hasSuffix:@".js"]) {
        _fileName = [_fileName componentsSeparatedByString:@".js"].firstObject;
    }
    
    NSString *path = [bundle pathForResource:_fileName ofType:@"js"];
    
    NSString *source = [BKWBCache.defaultCache objectForKey:path];
    if(source) {
        return source;
    }
    
    source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if(!source.length) {
        if(error) {
            NSLog(@"%@", error);
        }
        return nil;
    }

    [BKWBCache.defaultCache setObject:source forKey:path];
    return source;
}

+ (WKUserScript * _Nullable)scriptFromSource:(NSString *)source {
    WKUserScript *script = [[WKUserScript alloc] initWithSource:source
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:NO];
    return script;
}

+ (WKUserScript * _Nullable)scriptFromResource:(NSString *)fileName inBundle:(NSString *)bundleName {
    NSString *source = [self sourceFromResource:fileName inBundle:bundleName];
    return [self scriptFromSource:source];
}

@end
