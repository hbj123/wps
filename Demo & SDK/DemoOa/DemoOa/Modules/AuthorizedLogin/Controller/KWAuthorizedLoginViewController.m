//
//  KWAuthorizedLoginViewController
//  DemoOa
//
//  Created by will on 8/10/15.
//  Copyright © 2015 宝剑 Co.,Ltd. All rights reserved.
//

#import "KWAuthorizedLoginViewController.h"
#import "KWOfficeApi.h"
//#import <KingsoftOfficeAuthSDK.h>
//#import <KWAuthSession.h>

#define IS_REQUEST_TEST_BEST_URL 1

@interface KWAuthorizedLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *logLabel;

@end

@implementation KWAuthorizedLoginViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [KingsoftOfficeAuthSDK registerInternalAppWithKey:@"0x9e737286"];
////    [KingsoftOfficeAuthSDK setInternalAppTestMode];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLog:) name:@"Logtext" object:nil];
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)webAuthAction:(id)sender {
//    [KingsoftOfficeAuthSDK registerApp:@"0" withSecret:@"45266E5D5531E67A261F50A3D2700F93"];
//    [KingsoftOfficeAuthSDK webAuthWithResult:^(KingsoftOfficeAuthStatus status, NSError *error) {
//        
//    }];
}

- (IBAction)showAuthInfo:(id)sender {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Session" message:[NSString stringWithFormat:@"%@",[KWAuthSession sharedManager].sessionInfo] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
//    [alertView show];
}

- (IBAction)authForWPS:(id)sender {
//    [KingsoftOfficeAuthSDK registerApp:@"0" withSecret:@"45266E5D5531E67A261F50A3D2700F93"];
//    [KingsoftOfficeAuthSDK ssoAuthWithResult:^(KingsoftOfficeAuthStatus status, NSError *error) {
//        
//    }];
}
- (IBAction)getUserInfoAction:(id)sender {
//    [KingsoftOfficeAuthSDK getUserInfoWithResult:^(KWAuthUser *authUser, NSError *error) {
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User" message:authUser.userid delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
//        [alertView show];
//    }];
}



- (void)showLog:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    NSString *log = [info objectForKey:@"Log"];
    log = [log stringByAppendingString:@"\n"];
    _logLabel.text = [_logLabel.text stringByAppendingString:log];
}

@end
