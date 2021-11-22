//
//  FlutterBasicMessageChannel+Swizzle.m
//  flutter_file_override_plugin
//
//  Created by Solo on 2021/9/28.
//

#import "BKWBFlutterConstants.h"
#import "BKSwizzle.h"
#import "BKWBFlutterManager.h"

#import "FlutterBasicMessageChannel+Swizzle.h"

@implementation FlutterBasicMessageChannel (Swizzle)

+(void)load {
    if(!ljwbflutter_isFlutterExist()) {
        return;
    }
    //TODO: NOT IMPLEMENTED
//    [self hook_init];
//    [self hook_sendMessage];
//    [self hook_setMessageHandler];
}

+ (void)hook_init {
  
    SEL originSEL = @selector(initWithName:binaryMessenger:codec:);
    SEL swizzleSEL = @selector(hookInitWithName:binaryMessenger:codec:);

    LJ_SwizzleSelector([FlutterBasicMessageChannel class], originSEL, swizzleSEL);
}

+ (void)hook_sendMessage {
    
    SEL originSEL = @selector(sendMessage:);
    SEL swizzleSEL = @selector(hookSendMessage:);
    LJ_SwizzleSelector([FlutterBasicMessageChannel class], originSEL, swizzleSEL);
    
    originSEL = @selector(sendMessage:reply:);
    swizzleSEL = @selector(hookSendMessage:reply:);
    LJ_SwizzleSelector([FlutterBasicMessageChannel class], originSEL, swizzleSEL);
}

+ (void)hook_setMessageHandler {
   
    SEL originSEL = @selector(setMessageHandler:);
    SEL swizzleSEL = @selector(hookSetMessageHandler:);
    LJ_SwizzleSelector([FlutterBasicMessageChannel class], originSEL, swizzleSEL);
}

- (instancetype)hookInitWithName:(NSString*)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                       codec:(NSObject<FlutterMessageCodec>*)codec {
    FlutterBasicMessageChannel *channel = [self hookInitWithName:name binaryMessenger:messenger codec:codec];
    
    //排除系统通道
    if([name containsString:@"/"]) {
        return channel;
    }
    
    //创建LJWBFlutterMessageChannel对象
    [BKWBFlutterManager.defaultManager registerMessageChannelWithName:name];
    return channel;
}

- (void)hookSendMessage:(id _Nullable)message
{
    [self hookSendMessage:message];
    
    //多播
    NSString *name = [self valueForKey:@"name"];
    if([name containsString:@"/"]) {
         return;
     }
             
    BKWBFlutterMessageChannel *channel = BKWBFlutterManager.defaultManager.messageChannels[name];
    [channel sendMessage:message];
}

- (void)hookSendMessage:(id _Nullable)message reply:(FlutterReply _Nullable)callback {
    
    [self hookSendMessage:message reply:callback];
    
    //多播
    NSString *name = [self valueForKey:@"name"];
    
    if([name containsString:@"/"]) {
        return;
    }

    BKWBFlutterMessageChannel *channel = BKWBFlutterManager.defaultManager.messageChannels[name];
    [channel sendMessage:message reply:callback];
}


- (void)hookSetMessageHandler:(FlutterMessageHandler _Nullable)handler {
    
    [self hookSetMessageHandler:handler];
    
    //桥接
    NSString *name = [self valueForKey:@"name"];
    if([name containsString:@"/"]) {
        return;
    }
    BKWBFlutterMessageChannel *channel = BKWBFlutterManager.defaultManager.messageChannels[name];
    [channel setMessageHandler:handler];
}

@end
