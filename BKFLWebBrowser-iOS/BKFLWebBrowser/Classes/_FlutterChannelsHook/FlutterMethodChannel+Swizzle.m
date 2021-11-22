//
//  FlutterMethodChannel+Swizzle.m
//  flutter_file_override_plugin
//
//  Created by Solo on 2021/9/28.
//

#import "BKSwizzle.h"
#import "BKWBFlutterConstants.h"
#import "BKWBFlutterManager.h"

#import "FlutterMethodChannel+Swizzle.h"

@implementation FlutterMethodChannel (Swizzle)

+(void)load {
    if(!ljwbflutter_isFlutterExist()) {
        return;
    }
    
    [self hook_init];
    [self hook_invokeMethod];
    [self hook_setHandler];
}

+ (void)hook_init {
  
    SEL originSEL = @selector(initWithName:binaryMessenger:codec:);
    SEL swizzleSEL = @selector(hookInitWithName:binaryMessenger:codec:);

    LJ_SwizzleSelector([FlutterMethodChannel class], originSEL, swizzleSEL);
}

+ (void)hook_invokeMethod {
    
    SEL originSEL = @selector(invokeMethod:arguments:);
    SEL swizzleSEL = @selector(hookInvokeMethod:arguments:);
    LJ_SwizzleSelector([FlutterMethodChannel class], originSEL, swizzleSEL);
    
    originSEL = @selector(invokeMethod:arguments:result:);
    swizzleSEL = @selector(hookInvokeMethod:arguments:result:);
    LJ_SwizzleSelector([FlutterMethodChannel class], originSEL, swizzleSEL);
}

+ (void)hook_setHandler {
   
    SEL originSEL = @selector(setMethodCallHandler:);
    SEL swizzleSEL = @selector(hookSetMethodCallHandler:);
    LJ_SwizzleSelector([FlutterMethodChannel class], originSEL, swizzleSEL);
}

- (instancetype)hookInitWithName:(NSString*)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                       codec:(NSObject<FlutterMethodCodec>*)codec {
    
    FlutterMethodChannel *channel = [self hookInitWithName:name binaryMessenger:messenger codec:codec];
    
    //排除系统通道
    if([name containsString:@"/"]) {
        return channel;
    }
    
    //创建LJWBFlutterMethodChannel对象
    [BKWBFlutterManager.defaultManager registerMethodChannelWithName:name];

    return channel;
}

- (void)hookInvokeMethod:(NSString*)method arguments:(id _Nullable)arguments {
    
    [self hookInvokeMethod:method arguments:arguments];
    
    //多播
    NSString *name = [self valueForKey:@"name"];
    
    if([name containsString:@"/"]) {
        return;
    }
    BKWBFlutterMethodChannel *channel = BKWBFlutterManager.defaultManager.methodChannels[name];
    [channel invokeMethod:method arguments:arguments];
}

- (void)hookInvokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
        
    [self hookInvokeMethod:method arguments:arguments result:callback];
    
    //多播
    NSString *name = [self valueForKey:@"name"];
    
    if([name containsString:@"/"]) {
        return;
    }
    
    BKWBFlutterMethodChannel *channel = BKWBFlutterManager.defaultManager.methodChannels[name];
    [channel invokeMethod:method arguments:arguments result:callback];
}

- (void)hookSetMethodCallHandler:(FlutterMethodCallHandler _Nullable)handler {
    
    [self hookSetMethodCallHandler:handler];
    
    //桥接
    NSString *name = [self valueForKey:@"name"];
    
    if([name containsString:@"/"]) {
        return;
    }
    BKWBFlutterMethodChannel *channel = BKWBFlutterManager.defaultManager.methodChannels[name];
    [channel setMethodCallHandler:handler];
}


@end
