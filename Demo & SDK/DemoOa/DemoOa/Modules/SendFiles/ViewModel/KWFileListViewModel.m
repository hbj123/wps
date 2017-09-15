//
//  KWFileListViewModel
//  DemoOa
//
//  Created by 宝剑 on 16/2/29.
//  Copyright © 2016年 KingSoft Co.,Ltd. All rights reserved.
//

#import "KWFileListViewModel.h"

@implementation KWFileListViewModel


+ (NSDictionary<NSString*,NSString*>*)configFilePolicyWithFileType:(KWFileType)fileType
{
    //公共权限
    NSDictionary *publicPolicy =  @{@"public.document.watermark":@"0",
                                    @"public.shell.backup": @"0",
                                    @"public.document.share":@"1",
                                    @"public.document.print":@"1",
                                    @"public.document.sendMail":@"0",
                                    @"public.document.exportPDF":@"1",
                                    @"public.document.saveAs":@"1",
                                    @"public.document.localization":@"0",
                                    @"public.document.editEnable":@"1",
                                    @"public.document.openInEditMode":@"1",
                                    @"public.document.handwritingInk":@"1",
                                    @"public.document.wirelessProjection":@"1",
                                    @"public.document.dictionary":@"1"};
    
    NSMutableDictionary *policy = [[NSMutableDictionary alloc]initWithDictionary:publicPolicy copyItems:YES];
    
    switch (fileType) {
        case KWFileTypeWord:
        {
            [policy setObject:@"1" forKey:@"wps.shell.editmode.toolbar.mark"];
            [policy setObject:@"1" forKey:@"wps.shell.editmode.toolbar.markEnable"];
            [policy setObject:@"1" forKey:@"wps.shell.editmode.toolbar.revision"];
            [policy setObject:@"1" forKey:@"wps.shell.editmode.toolbar.revisionEnable"];
            [policy setObject:@"1" forKey:@"wps.shell.readmode.toolbar.revision"];
            [policy setObject:@"1" forKey:@"wps.shell.readmode.addCommentEnable"];
            [policy setObject:@"1" forKey:@"wps.shell.readmode.copyEnable"];
            [policy setObject:@"Glider" forKey:@"wps.document.revision.username"];
        }
            break;
        case KWFileTypeET:
        {
            [policy setObject:@"1" forKey:@"et.document.copyEnable"];
        }
            break;
        case KWFileTypePPT:
        {
            [policy setObject:@"1" forKey:@"ppt.document.toollist.sharePlay"];
            [policy setObject:@"1" forKey:@"ppt.document.toollist.wirelessProjection"];
        }
            break;
        case KWFileTypePDF:
        {
            [policy setObject:@"1" forKey:@"pdf.document.copyEnable"];
            [policy setObject:@"1" forKey:@"pdf.document.extractAndMerge"];
        }
            break;
        default:
            break;
    }
    
    return policy;
}

//模拟控制权限
+ (NSDictionary<NSString*,NSString*>*)configControllerModelFilePolicyWithFileType:(KWFileType)fileType
{
    //公共权限
    NSDictionary *publicPolicy =  @{@"public.document.watermark":@"1",
                                    @"public.shell.backup": @"0",
                                    @"public.document.share":@"0",
                                    @"public.document.print":@"0",
                                    @"public.document.sendMail":@"0",
                                    @"public.document.exportPDF":@"0",
                                    @"public.document.saveAs":@"0",
                                    @"public.document.localization":@"0",
                                    @"public.document.editEnable":@"0",
                                    @"public.document.openInEditMode":@"0",
                                    @"public.document.handwritingInk":@"0",
                                    @"public.document.wirelessProjection":@"0"};
    
    NSMutableDictionary *policy = [[NSMutableDictionary alloc]initWithDictionary:publicPolicy copyItems:YES];
    
    switch (fileType) {
        case KWFileTypeWord:
        {
            [policy setObject:@"0" forKey:@"wps.shell.editmode.toolbar.mark"];
            [policy setObject:@"0" forKey:@"wps.shell.editmode.toolbar.markEnable"];
            [policy setObject:@"0" forKey:@"wps.shell.editmode.toolbar.revision"];
            [policy setObject:@"0" forKey:@"wps.shell.editmode.toolbar.revisionEnable"];
            [policy setObject:@"0" forKey:@"wps.shell.readmode.toolbar.revision"];
            [policy setObject:@"0" forKey:@"wps.shell.readmode.addCommentEnable"];
            [policy setObject:@"0" forKey:@"wps.shell.readmode.copyEnable"];
            [policy setObject:@"Glider" forKey:@"wps.document.revision.username"];
        }
            break;
        case KWFileTypeET:
        {
            [policy setObject:@"0" forKey:@"et.document.copyEnable"];
        }
            break;
        case KWFileTypePPT:
        {
            [policy setObject:@"1" forKey:@"ppt.document.toollist.sharePlay"];
            [policy setObject:@"0" forKey:@"ppt.document.toollist.wirelessProjection"];
        }
            break;
        case KWFileTypePDF:
        {
            [policy setObject:@"0" forKey:@"pdf.document.copyEnable"];
            [policy setObject:@"0" forKey:@"pdf.document.extractAndMerge"];
        }
            break;
        default:
            break;
    }
    return policy;
}
@end
