//
//  LJWBHttpConnection.m
//  LJWebBrowser
//
//  Created by ZhaoXM on 2020/8/13.
//

#import "LJWBHttpConnection.h"

@implementation LJWBHttpConnection
- (BOOL)isSecureServer {
	return YES;
}

- (NSArray *)sslIdentityAndCertificates
{
    SecIdentityRef identityRef = NULL;
    SecCertificateRef certificateRef = NULL;
    SecTrustRef trustRef = NULL;

    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(PKCS12Data);
    CFStringRef password = CFSTR("H0meL1nk");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);

    OSStatus securityError = errSecSuccess;
    securityError =  SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        identityRef = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        trustRef = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)securityError);
        return nil;
    }

    SecIdentityCopyCertificate(identityRef, &certificateRef);
    NSArray *result = [[NSArray alloc] initWithObjects:(id)CFBridgingRelease(identityRef),   (id)CFBridgingRelease(certificateRef), nil];

    return result;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    // do something
    return [super httpResponseForMethod:method URI:path];
}
@end
