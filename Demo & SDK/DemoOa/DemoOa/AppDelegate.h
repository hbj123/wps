//
//  AppDelegate.h
//  DemoOa
//
//  Created by tang feng on 14-3-19.
//  Copyright (c) 2014年 宝剑 Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWOfficeApi.h"

@interface AppDelegate : UIResponder<UIApplicationDelegate, KWOfficeApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSDictionary * securityInfo;

@end
