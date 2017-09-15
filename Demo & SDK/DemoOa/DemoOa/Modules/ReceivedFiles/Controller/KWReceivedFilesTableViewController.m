//
//  KWReceivedFilesTableViewController
//  DemoOa
//
//  Created by will on 7/22/15.
//  Copyright (c) 2015 KingSoft Co.,Ltd. All rights reserved.
//

#import "KWReceivedFilesTableViewController.h"
#import "KWFileSystemModel.h"
#import "KWFileViewController.h"

@interface KWReceivedFilesTableViewController ()

@property (nonatomic, strong) NSMutableArray *fileList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@end

@implementation KWReceivedFilesTableViewController

# pragma mark - View load

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFileList];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self updateButtonsToMatchTableState];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateSubview];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void) loadFileList
{
    NSMutableArray *paths = [[NSMutableArray alloc]initWithArray:[KWFileSystemModel getReceivedDocumentPath]];
    KWFileSystemModel *fs = [[KWFileSystemModel alloc] initWithPath:paths];
    self.fileList = [fs getDocumentFileList];
}

#pragma mark - refresh table view

- (void) refreshTableView: (UIRefreshControl *) refreshControl {
    [self updateSubview];
    [refreshControl endRefreshing];
}

- (void) updateSubview {
    [self loadFileList];
    [self.tableView reloadData];
    [self updateButtonsToMatchTableState];
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.tableView.editing) {
        [self previewFileInTableView:tableView withIndexPath:indexPath];
    }
    
    [self updateButtonsToMatchTableState];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self updateButtonsToMatchTableState];
}

- (void) previewFileInTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *fileSelected = [self.fileList objectAtIndex:indexPath.row];
    NSString *filePath = [fileSelected valueForKey:FILE_SYSTEM_MODEL_FILEPATH];
    
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    self.documentInteractionController.delegate = self;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL is_ok = [self.documentInteractionController presentPreviewAnimated:YES];
    if (!is_ok)
        [self.documentInteractionController presentOptionsMenuFromRect:cell.bounds inView:cell animated:YES];
    
    // Make the highlight disappear
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) fileSelectedWithPath: (NSString *) filepath {
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    KWFileViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FileViewController"];
    
    if(filepath.length == 0) {
        return;
    }
    vc._filePath = filepath;
    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *fileToBeDeleted = [self.fileList objectAtIndex:indexPath.row];
        NSString *filepathToBeDeleted = [fileToBeDeleted valueForKey:FILE_SYSTEM_MODEL_FILEPATH];
        [KWFileSystemModel deleteFileWithFilepath:filepathToBeDeleted];
        
        [self.fileList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Button action methods

- (IBAction)editAction:(id)sender {
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelButton:(id)sender {
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)destroyActionComfirm {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    if (deleteSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        NSMutableIndexSet *indicesOfItemsToDelete = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *selectionIndex in selectedRows) {
            NSDictionary *fileToBeDeleted = [self.fileList objectAtIndex: selectionIndex.row];
            [KWFileSystemModel deleteFileWithFilepath: [fileToBeDeleted valueForKey:FILE_SYSTEM_MODEL_FILEPATH]];
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        
        [self.fileList removeObjectsAtIndexes:indicesOfItemsToDelete];
        
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        for (NSDictionary *fileToBeDeleted in self.fileList) {
            [KWFileSystemModel deleteFileWithFilepath:[fileToBeDeleted valueForKey:FILE_SYSTEM_MODEL_FILEPATH]];
        }
        
        [self.fileList removeAllObjects];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)deleteButton:(id)sender {
    NSString *alertTitle = NSLocalizedString(@"Comfirm", @"Comfirm title for comfirmation action");
    NSString *alertMessage;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        alertMessage = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
    }
    else
    {
        alertMessage = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:alertTitle
                                                                      message:alertMessage
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *destroyAction = [UIAlertAction actionWithTitle:okTitle
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self destroyActionComfirm];
                                                          }];
    [alertCtl addAction:destroyAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertCtl addAction:cancelAction];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}

#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState {
    if (self.tableView.editing) {
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        self.navigationItem.leftBarButtonItem = self.deleteButton;
        
        [self updateDeleteButtonTitle];
    }
    else {
        self.navigationItem.rightBarButtonItem = self.editButton;
        self.navigationItem.leftBarButtonItem = nil;

        // set editButton states
        if (self.fileList.count > 0) {
            self.editButton.enabled = YES;
        } else {
            self.editButton.enabled = NO;
        }
    }
}

- (void)updateDeleteButtonTitle {
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = (selectedRows.count == self.fileList.count);
    BOOL noItemsAreSelected = (selectedRows.count == 0);
    
    if (allItemsAreSelected || noItemsAreSelected) {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else {
        NSString *titleFormatString = NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

#pragma mark - UIDocumentInteractionController Delegate

- (UIViewController*) documentInteractionControllerViewControllerForPreview:(nonnull UIDocumentInteractionController *)controller {
    return self;
}

@end
