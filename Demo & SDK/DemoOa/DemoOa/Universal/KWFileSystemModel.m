//
//  KWFileSystemModel
//  TableTest
//
//  Created by will on 7/21/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

#import "KWFileSystemModel.h"

@implementation KWFileSystemModel
- (instancetype) initWithPath:(NSMutableArray *)path {
    self = [super init];
    if (self) {
        _path = path;
    }
    return self;
}

+(BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

- (NSMutableArray *) getDocumentFileList {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // return results
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    for (NSString *directory in self.path) {
        
        NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
//        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:directory];
        
        for (NSString *filename in tmplist) {
            NSString *filepath = [directory stringByAppendingPathComponent:filename];
            if ([self isDocument:filepath]) {
                NSMutableDictionary *fileDict = [[NSMutableDictionary alloc] init];
                NSError *attributesRetrievalError = nil;
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:filepath error:&attributesRetrievalError];
                
                NSString *realFilename = [filename lastPathComponent];
                [fileDict setObject:realFilename forKey:FILE_SYSTEM_MODEL_FILENAME];
                [fileDict setObject:filepath forKey:FILE_SYSTEM_MODEL_FILEPATH];
                [fileDict setObject:[attributes fileCreationDate] forKey:FILE_SYSTEM_MODEL_FILE_CREATION_DATE];
                [fileList addObject:fileDict];
//                NSLog(@"%@", [attributes fileCreationDate]);
            }
        }
    }
    
    [fileList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *first = [(NSMutableDictionary *) obj1 valueForKey:FILE_SYSTEM_MODEL_FILE_CREATION_DATE];
        NSDate *second = [(NSMutableDictionary *) obj2 valueForKey:FILE_SYSTEM_MODEL_FILE_CREATION_DATE];
        return [second compare:first];
    }];
   
    return fileList;
}


- (BOOL) isDocument:(NSString *)filepath {
    NSArray *formatList = [SUPPORTED_FILE_FORMAT componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *extension = [filepath pathExtension];
    for (NSString *formatName in formatList) {
        if ([extension isEqualToString:formatName])
            return YES;
    }
    return NO;
    
//    NSArray *extensions = [NSArray arrayWithObjects:@"doc", @"docx", @"xls", @"xlsx", @"ppt", @"pptx", @"pdf", nil];
//    for (NSString *extension in extensions) {
//        if ([extension isEqualToString:[filepath pathExtension]])
//            return YES;
//    }
//    return NO;
}

+ (NSMutableArray *) getDocumentPath {
    NSString *docPaths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSMutableArray *paths = [NSMutableArray array];
    [paths addObject:[[NSBundle mainBundle] resourcePath]];
    [paths addObject:docPaths];
    
    return paths;
}

+ (NSArray *) getReceivedDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"doc"];
    return [NSArray arrayWithObject:path];
}

+ (void) deleteFileWithFilepath: (NSString *) filepath {
//    NSLog(@"Remove file at path: %@", filepath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:NULL];
}

+ (BOOL) isDocFileWithFilename:(NSString *)filename {
    return [self isFormatTypeMatchWithFormat:SUPPORTED_DOC_FILE_FORMAT withFilename:filename];
}

+ (BOOL) isExcelFileWithFilename:(NSString *)filename {
    return [self isFormatTypeMatchWithFormat:SUPPORTED_EXCEL_FILE_FORMAT withFilename:filename];
}

+ (BOOL) isPDFFileWithFilename:(NSString *)filename {
    return [self isFormatTypeMatchWithFormat:SUPPORTED_PDF_FILE_FORMAT withFilename:filename];
}

+ (BOOL) isPPTFileWithFilename:(NSString *)filename {
    return [self isFormatTypeMatchWithFormat:SUPPORTED_PPT_PPTX_FILE_FORMAT withFilename:filename];
}

+ (BOOL) isFormatTypeMatchWithFormat: (NSString *) format withFilename:(NSString *) filename {
    NSArray *formatList = [format componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString *formatName in formatList) {
        if ([filename isEqualToString:formatName])
            return YES;
    }
    return NO;
}

@end
