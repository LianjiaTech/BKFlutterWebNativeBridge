//
//  ViewController.m
//  Runner
//
//  Created by Solo on 2021/7/21.
//

#import "ViewController.h"
#import "GeneratedPluginRegistrant.h"

#import <Flutter/Flutter.h>

#import "WebViewController.h"
#import <BKFLWebBrowser/BKWBFlutter2WebManager.h>
#import <BKFLWebBrowser/BKWebBrowser.h>
#import <BKFLWebBrowser/BKWBBridgeManager.h>
#import <BKFLWebBrowser/BKWBFlutterManager.h>

@interface ViewController ()

@property (nonatomic, strong) FlutterEngine *engine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.engine = [[FlutterEngine alloc] initWithName:@"beikeshareengine_123"];
    [self.engine runWithEntrypoint:nil];
    
    [GeneratedPluginRegistrant registerWithRegistry:self.engine];
}

-(void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}

- (IBAction)goToFlutter:(id)sender {
        
    FlutterViewController *flutterVC = [[FlutterViewController alloc] initWithEngine:self.engine nibName:nil bundle:nil];
    [flutterVC setInitialRoute:@"/"];
    
    [self.navigationController pushViewController:flutterVC animated:YES];
}

- (IBAction)pushVC:(id)sender {
    
    WebViewController *vc = [[WebViewController alloc] init];
    vc.webView = [[BKWBFlutter2WebManager sharedInstance] createWebViewPackageHost:@"http://localhost" url:@"web/#/"];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
