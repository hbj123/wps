//
//  KWFileViewController
//  TestWpsApp
//
//  Created by tang feng on 14-3-6.
//  Copyright (c) 2014年 Zhuhai TF Tech Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWFileViewController : UIViewController
{
    
}
@property(nonatomic,retain)IBOutlet UIWebView *_fileView;
@property(nonatomic,retain)NSData *_fileData;
@property(nonatomic,retain)NSString *_filePath;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

-(IBAction)returnBtnEvent:(id)sender;
@end
