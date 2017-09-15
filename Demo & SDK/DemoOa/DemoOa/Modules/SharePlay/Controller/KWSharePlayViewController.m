//
//  KWSharePlayViewController
//  DemoOa
//
//  Created by will on 7/19/15.
//  Copyright (c) 2015 KingSoft Co.,Ltd. All rights reserved.
//

#import "KWSharePlayViewController.h"
#import "KWOfficeApi.h"
#import "NSData+KWAES.h"
#import "AppDelegate.h"

@interface KWSharePlayViewController ()

@end

@implementation KWSharePlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)securityInfo{
    UIApplication *app= [UIApplication sharedApplication];
    AppDelegate *delegate = (AppDelegate *)app.delegate;
    
    return delegate.securityInfo;
}

- (IBAction)startWpsSharePlay:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"pptTest" ofType:@"ppt"];
    NSData *originalData = [NSData dataWithContentsOfFile:path];
    if (originalData == nil)
        return;
    
    NSData * data;
    
    if ([[[self securityInfo] objectForKey:KWOfficeSecurityTypeKey] integerValue] == KWOfficeSecurityTypeAES256){
        NSString * securityKey = [[self securityInfo] objectForKey:KWOfficeSecurityKey];
        data = [originalData KWAES256EncryptWithKey:[securityKey dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        data = originalData;
    }
    
    NSError *error = nil;
    //如果data为加密的数据 securityInfo需要相应的加密类型和密钥 如果数据未加密 securityInfo设nil
    BOOL isOk = [[KWOfficeApi sharedInstance] startSharePlay:data
                                                securityInfo:[self securityInfo]
                                                withFileName:path.lastPathComponent
                                                  serverHost:@"cloudservice6.kingsoft-office-service.com:8082"
                                                    callback:nil
                                                    delegate:[UIApplication sharedApplication].delegate
                                                       error:&error];
    if (isOk) {
        NSLog(@"进入wps app");
    } else {
        NSLog(@"进入wps app 失败 %@", error);
    }
}

- (IBAction)joinWpsSharePlay:(id)sender {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接入共享播放" message:@"Please input access code:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

//- (IBAction)closeWpsSharePlay:(id)sender {
//
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"关闭共享播放" message:@"Please input access code:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert show];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *accessCode = [[alertView textFieldAtIndex:0] text];
    NSLog(@"accesscode======>%@", accessCode);
    
    if ([alertView.title isEqualToString:@"接入共享播放"]){
        [self joinWpsSharePlayWithAccessCode:accessCode];
    }
}

- (void) joinWpsSharePlayWithAccessCode: (NSString *) accessCode {
    if (!accessCode) {
        accessCode = @"123456789";
    }
    NSError *error = nil;
    BOOL isOk = [[KWOfficeApi sharedInstance] joinSharePlay:accessCode
                                                 serverHost:@"cloudservice6.kingsoft-office-service.com:8082"
                                                   callback:nil
                                                   delegate:[UIApplication sharedApplication].delegate
                                                      error:&error];
    if (isOk) {
        NSLog(@"进入wps app");
    } else {
        NSLog(@"进入wps app 失败 %@", error);
    }
}

//- (void)closeWpsSharePlayWithAccessCode: (NSString *) accessCode {
//    if (!accessCode) {
//        accessCode = @"123456789";
//    }
//    NSError *error = nil;
//    BOOL isOk = [[KWOfficeApi sharedInstance] closeSharePlayWithCallback:nil
//                                                                delegate:[UIApplication sharedApplication].delegate
//                                                                   error:&error];
//    if (isOk) {
//        NSLog(@"进入wps app");
//    } else {
//        NSLog(@"进入wps app 失败 %@", error);
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

