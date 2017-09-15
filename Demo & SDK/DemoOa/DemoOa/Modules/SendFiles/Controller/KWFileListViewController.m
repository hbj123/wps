//
//  KWFileListViewController
//  TableTest
//
//  Created by will on 7/21/15.
//  Copyright (c) 2015 宝剑. All rights reserved.
//

#import "KWFileListViewController.h"
#import "KWFileSystemModel.h"
#import "KWOfficeApi.h"
#import "NSData+KWAES.h"
#import "KWFileListViewModel.h"
#import "AppDelegate.h"

//模拟控制权限
static BOOL _isControllerModel = NO;

@interface KWFileListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSDictionary * securityInfo;

@end

@implementation KWFileListViewController

# pragma mark - View load

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwitch *modeSwitch = [[UISwitch alloc]init];
    [modeSwitch addTarget:self action:@selector(switchMode:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:modeSwitch];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    label.text = @"权限管控";
    label.textAlignment = NSTextAlignmentRight;
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithCustomView:label];
    [self.navigationItem setRightBarButtonItems:@[item,item1]];
    
    [self loadFileList];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)switchMode:(UISwitch*)sender{
    _isControllerModel = sender.on;
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateSubview];
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (void) loadFileList {
    KWFileSystemModel *fs = [[KWFileSystemModel alloc] initWithPath:[KWFileSystemModel getDocumentPath]];
    self.fileList = [fs getDocumentFileList];
}

- (NSDictionary *)securityInfo{
    
    //获取加密配置
    UIApplication *app= [UIApplication sharedApplication];
    AppDelegate *delegate = (AppDelegate *)app.delegate;
    return delegate.securityInfo;
}
#pragma mark - refresh control

- (void) refreshTableView: (UIRefreshControl *) refreshControl {
    [self updateSubview];
    [refreshControl endRefreshing];
}

#pragma mark - update Subview

- (void) updateSubview {
    [self loadFileList];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"File Cell" forIndexPath:indexPath];
    
    NSMutableDictionary *currentFile = [self.fileList objectAtIndex:indexPath.row];
    NSString *filename = [currentFile valueForKey:FILE_SYSTEM_MODEL_FILENAME];
    cell.textLabel.text = filename;
    NSDate *fileCreationDate = [currentFile valueForKey:FILE_SYSTEM_MODEL_FILE_CREATION_DATE];
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:fileCreationDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    cell.imageView.image = [self cellImageWithFileName:filename];

    return cell;
}

- (UIImage *) cellImageWithFileName: (NSString *) filename {
    NSString *extension = [filename pathExtension];
    UIImage *cellImage = nil;
    [KWFileSystemModel isDocFileWithFilename:extension];
    if ([KWFileSystemModel isDocFileWithFilename:extension]) {
        cellImage = [UIImage imageNamed:@"doc_image"];
    } else if ([KWFileSystemModel isPPTFileWithFilename:extension]) {
        cellImage = [UIImage imageNamed:@"ppt_image"];
    } else if ([KWFileSystemModel isExcelFileWithFilename:extension]) {
        cellImage = [UIImage imageNamed:@"xls_image"];
    } else if ([KWFileSystemModel isPDFFileWithFilename:extension]) {
        cellImage = [UIImage imageNamed:@"pdf_image"];
    }
    return cellImage;
}

#pragma mark - Table View Delegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return 60;
    }
    return 44;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *fileSelected = [self.fileList objectAtIndex:indexPath.row];
    NSString *filePath = [fileSelected valueForKey:FILE_SYSTEM_MODEL_FILEPATH];
    
    [self fileSelectedWithPath:filePath];
    
    // Make the highlight disappear
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) fileSelectedWithPath: (NSString *) filepath {
    NSString *extension = [filepath pathExtension];
    if ([KWFileSystemModel isDocFileWithFilename:extension]) {
        
        [self runWpsFileWithPath:filepath fileType:KWFileTypeWord];
        
    } else if ([KWFileSystemModel isPPTFileWithFilename:extension]) {
        
        [self runWpsFileWithPath:filepath fileType:KWFileTypePPT];
        
    } else if ([KWFileSystemModel isExcelFileWithFilename:extension]) {
        
        [self runWpsFileWithPath:filepath fileType:KWFileTypeET];
        
    } else if ([KWFileSystemModel isPDFFileWithFilename:extension]) {
        
        [self runWpsFileWithPath:filepath fileType:KWFileTypePDF];
        
    }
}

- (void) runWpsFileWithPath: (NSString *) filepath fileType:(KWFileType)fileType{
 
    NSData *originalData = [NSData dataWithContentsOfFile:filepath options:NSDataReadingMappedIfSafe error:nil];
    
    if (originalData == nil)
        return;
    
    NSDictionary *policy = [KWFileListViewModel configFilePolicyWithFileType:fileType];
   
    NSData * data;
    
    if ([[self.securityInfo objectForKey:KWOfficeSecurityTypeKey] integerValue] == KWOfficeSecurityTypeAES256){
        
        //根据本地设置，加密文档数据
        NSString * securityKey = [self.securityInfo objectForKey:KWOfficeSecurityKey];
        data = [originalData KWAES256EncryptWithKey:[securityKey dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        data = originalData;
    }
    
    if (_isControllerModel) {
        //模拟比对不同权限的效果
        policy = [KWFileListViewModel configControllerModelFilePolicyWithFileType:fileType];
    }
    
    NSError *error = nil;
    
    //如果data为加密的数据 securityInfo需要相应的加密类型和密钥 如果数据未加密 securityInfo设nil
    BOOL isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                              withFileName:filepath.lastPathComponent
                                                  callback:nil
                                                  delegate:[[UIApplication sharedApplication] delegate]
                                                    policy:policy
                                              securityInfo:self.securityInfo
                                                     error:&error];
    if (isOk) {
        NSLog(@"进入wps app");
    } else {
        NSLog(@"进入wps app 失败 %@", error);
    }
}

@end
