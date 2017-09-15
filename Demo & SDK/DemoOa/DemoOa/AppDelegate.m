//
//  AppDelegate.m
//  DemoOa
//
//  Created by tang feng on 14-3-19.
//  Copyright (c) 2014年 宝剑 Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"
//#import <KingsoftOfficeAuthSDK.h>
#import "KWOfficeApi.h"
#import "NSData+KWAES.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    /// @note 注册App
    [KWOfficeApi registerApp:@"78530E3D71A93B61CDD292808343C19C"];
    
    /// @note 打开调试模式
    [KWOfficeApi setDebugMode:YES];
    /// @note 设置通信端口号，默认9616
    [KWOfficeApi setPort:3121];
    /// @note 设置水印参数，同时还要配置开启水印的权限
    [KWOfficeApi setWatermarkText:@"Kingsoft" colorWithRed:218 green:218 blue:218 alpha:1.0 type:KWOfficeWatermarkTypeCompact];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[KWOfficeApi sharedInstance] setApplicationDidEnterBackground:application];//必须使用
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//兼容9.0以上的模拟器，不加这个回调模拟器无法拖拽第三方打开
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0)
{
    return [self application:app
                     openURL:url
           sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

//重新拉起OA
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    /**
     *  重新拉起OA做相应的配置（SDK 1.9新增）
     */
    if ([KWOfficeApi handleOpenURL:url sourceApplication:sourceApplication annotation:annotation]){
        
        //这里设置的delegate需要和调用sendFileData时所设置的delegate一致
        [[KWOfficeApi sharedInstance] resetKWOfficeApiServiceWithDelegate:self];
        return true;
    }
    
//    if ([KingsoftOfficeAuthSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation]){
//        return true;
//    }
    
    return YES;
}

#pragma mark - property

- (NSDictionary *)securityInfo{
    if (!_securityInfo){
        
        //256位(32字节)加密KEY
        _securityInfo = @{KWOfficeSecurityTypeKey:@(KWOfficeSecurityTypeAES256),
                          KWOfficeSecurityKey:@"8213F24ABFAF6DNH212FBA700511D88F"};
    }
    return _securityInfo;
}

#pragma mark - KWOfficeApi delegate
//wps回传文件数据
-(void)KWOfficeApiDidReceiveData:(NSDictionary *)dict{
    
    //解析file数据
    NSData *fileData = [dict objectForKey:@"Body"];
    
    // 如果发送给WPS的是密文数据，则回传的也是密文数据，明文数据可忽略此步骤
    if ([[self.securityInfo objectForKey:KWOfficeSecurityTypeKey] integerValue] == KWOfficeSecurityTypeAES256){
        NSString * secureKey = [self.securityInfo objectForKey:KWOfficeSecurityKey];
        fileData = [fileData KWAES256DecryptWithKey:[secureKey dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString *bjStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
    NSLog(@"wps回传文件长度=============>%@",@(fileData.length));
    
    //将file data 写入本地
    NSString *strDocPath = [[NSString alloc] initWithString:[self getDocPath]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager createDirectoryAtPath:strDocPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString *strTime = [formatter stringFromDate:[NSDate date]];
    
    NSString *keyContent = [dict objectForKey:@"FileType"];
    NSString *fileType = [NSString stringWithFormat:@".%@",keyContent];
    
    NSString *strName = [strTime stringByAppendingString:fileType];
    [self writeFile:[strDocPath stringByAppendingPathComponent:strName] writeData:fileData];
    
    //存储文件路径
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",strDocPath,strName];
    [[NSUserDefaults standardUserDefaults] setObject:filePath forKey:@"KWFilePath"];
}

//wps编辑完成返回 结束与WPS链接
- (void)KWOfficeApiDidFinished{
    NSLog(@"=====> wps编辑完成返回 结束与WPS链接");
}

//wps退出后台
- (void)KWOfficeApiDidAbort{
    NSLog(@"wps编辑结束，并退出后台");
}
//断开链接
- (void)KWOfficeApiDidCloseWithError:(NSError*)error{
    NSLog(@"=====> 错误 与 wps 断开链接 %@",error);
}

//共享播放
-(void)KWOfficeApiDidReceiveShareString:(NSString *)string{
    NSLog(@"KWOfficeApiDidReceiveShareString : %@", string);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"共享播放" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)KWOfficeApiStartSharePlayDidSuccessWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost{
    NSLog(@"KWOfficeApiStartSharePlayDidSuccessWithAccessCode - accessCode : %@, serverHost : %@", accessCode, serverHost);
}
- (void)KWOfficeApiStartSharePlayDidFailWithErrorMessage:(NSString *)errorMessage{
    NSLog(@"KWOfficeApiStartSharePlayDidFailWithErrorMessage - errorMessage : %@", errorMessage);
}
- (void)KWOfficeApiJoinSharePlayDidSuccess{
    NSLog(@"KWOfficeApiJoinSharePlayDidSuccess");
}
- (void)KWOfficeApiJoinSharePlayDidFailWithErrorMessage:(NSString *)errorMessage{
    NSLog(@"KWOfficeApiJoinSharePlayDidFailWithErrorMessage - errorMessage : %@", errorMessage);
}

#pragma mark - 写本地文件
-(NSString *)getDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//doc路径
-(NSString *)getDocPath{
    return[[self getDocumentPath] stringByAppendingPathComponent:@"doc"];
}

//nsdata转文件
-(BOOL)writeFile:(NSString *)path writeData:(NSData *)data{
    BOOL isSuccess=[data writeToFile:path atomically:NO];
    return isSuccess;
}

- (void)exitOA{
    NSLog(@"Exit OA!");
    exit(0);
}

@end
