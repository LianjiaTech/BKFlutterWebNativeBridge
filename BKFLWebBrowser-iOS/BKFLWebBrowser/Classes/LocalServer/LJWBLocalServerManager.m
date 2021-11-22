//
//  LJWBLocalServerManager.m
//  LJWebBrowser
//
//  Created by ZhaoXM on 2020/8/11.
//

#import "LJWBLocalServerManager.h"
#import "HTTPServer.h"
#import "LJWBLocalServerEnvConfig.h"
#import <LJPackageManager/LJPackageManager.h>

@interface LJWBLocalServerManager ()
@property (nonatomic, strong) HTTPServer *localServer;
@property (nonatomic, copy)   NSString *port;
@end

static NSString * const kLJWBLocalServerDomain = @"localhost";
@implementation LJWBLocalServerManager

LJTOL_SINGLETON_IMPLEMENTATION(LJWBLocalServerManager, defaultManager)

- (instancetype)init {
	if (self = [super init]) {
		[self setupServer];
	}
	return self;
}

#pragma mark Public Method
- (NSString *)getLocalServerAddress {
	NSString *address = [NSString stringWithFormat:@"http://%@:%@", kLJWBLocalServerDomain, self.port];
	return address;
}

#pragma mark Private Method
- (void)setupServer {
	_localServer = [[HTTPServer alloc] init];
	[_localServer setType:@"_http._tcp."]; //"_https._tcp."
	NSString *docRootPath = [self getDocumentRootPath];
	[_localServer setDocumentRoot:docRootPath];
	//[_localServer setDomain:kLJWBLocalServerDomain];
	NSError *error;
	if ([_localServer start:&error]) {
		self.port = [NSString stringWithFormat:@"%d", [_localServer listeningPort]];
	} else {
		//本地服务器开启失败，上报自定义错误
		NSString *localizedDescription = @"本地服务器开启失败";
		NSString *reason = @"未知原因，无error";
		if (error) {
			localizedDescription = error.localizedDescription;
			reason = error.localizedFailureReason;
		}
		NSError *error = [NSError errorWithDomain:@"ljbc_errorsort_infrastructure"
			code:0
		userInfo:@{@"ljbc_errorkey_info":@{@"localizedDescription":localizedDescription,@"reason":reason},
				   @"ljbc_errorkey_event":@"LocalServer_Setup_Failed",
				   @"ljbc_errorkey_msg":@"本地服务器启动失败",
				   @"ljbc_errorkey_tag":@"LJWebBrowser/LocalServer/setupServer"}];
        
        NSLog(@"%@", error);
		
	}
}

- (NSString *)getDocumentRootPath {

    NSString *destPath = [LJPackageManager sharedInstance].packageRootPath;
	return destPath;
}
@end
