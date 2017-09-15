//
//  KWFileSystemModel
//  TableTest
//
//  Created by will on 7/21/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWFileSystemModel : NSObject

#define FILE_SYSTEM_MODEL_FILENAME @"fileName"
#define FILE_SYSTEM_MODEL_FILEPATH @"filePath"
#define FILE_SYSTEM_MODEL_FILE_CREATION_DATE @"fileCreationDate"

#define SUPPORTED_PPT_PPTX_FILE_FORMAT   @"ppt pptm pptx pot potx pps ppsx dps dpt ppt pot pps dps dpt dpss"

#define SUPPORTED_DOC_FILE_FORMAT   @"wps wpt doc docx dot dotx docm txt rtf wpss"

#define SUPPORTED_PDF_FILE_FORMAT  @"pdf"

#define SUPPORTED_EXCEL_FILE_FORMAT @"xlsx xlsm xls xlt xltx et ett csv ets"

#define SUPPORTED_FILE_FORMAT @"ppt pptm pptx pot potx pps ppsx dps dpt ppt pot pps dps dpt wps wpt doc docx dot dotx docm txt rtf pdf xlsx xlsm xls xlt xltx et ett csv wpss ets dpss"

@property (strong) NSMutableArray *path;

- (instancetype) initWithPath:(NSMutableArray *)path;

- (NSMutableArray *) getDocumentFileList;


+ (NSMutableArray *) getDocumentPath;
+ (NSArray *) getReceivedDocumentPath;
+ (void) deleteFileWithFilepath: (NSString *) filepath;

+ (BOOL) isDocFileWithFilename: (NSString *) filename;
+ (BOOL) isPPTFileWithFilename: (NSString *) filename;
+ (BOOL) isExcelFileWithFilename: (NSString *) filename;
+ (BOOL) isPDFFileWithFilename: (NSString *) filename;

@end
