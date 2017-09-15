//
//  KWFileViewController
//  TestWpsApp
//
//  Created by tang feng on 14-3-6.
//  Copyright (c) 2014年 Zhuhai TF Tech Co.,Ltd. All rights reserved.
//

#import "KWFileViewController.h"

@interface KWFileViewController ()

@end

@implementation KWFileViewController
@synthesize _fileView;
@synthesize _fileData;
@synthesize _filePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _fileView.scalesPageToFit = YES;
    NSURL* url = [NSURL URLWithString:[_filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _fileView.scalesPageToFit = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_fileView loadRequest:request];

    _navigationBar.topItem.title = [_filePath lastPathComponent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)returnBtnEvent:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
