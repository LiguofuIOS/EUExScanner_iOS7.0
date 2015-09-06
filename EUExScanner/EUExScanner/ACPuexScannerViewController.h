//
//  ViewController.h
//  NewProject
//
//  Created by liguofu on 15/3/4.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//
@class EUExScanner;

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import <AVFoundation/AVFoundation.h>
#import "EUExBaseDefine.h"
#import "JSON.h"

@interface ACPuexScannerViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZBarReaderDelegate,ZBarReaderViewDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    BOOL lightOn;
    ZBarReaderView *readview;
    UIToolbar *toolStatusBar;
    UIToolbar *toolBtnBar;
    UIToolbar  *toolBarBottom;
    
    //EUExScanner *euexObj;
}
@property (nonatomic, retain) UIImageView *line;
@property (nonatomic, retain) UIImageView *image;
@property(nonatomic, assign) EUExScanner *euexObj;
@property (nonatomic, retain) NSString *retJson;

@property (nonatomic, retain) NSString *scannerTitle;
@property (nonatomic, retain) NSString *scannerTip;
@property (nonatomic, retain) UIImage *lineImg;
@property (nonatomic, retain) UIImage *flashImg;
@property (nonatomic, retain) UIImage *pickBgImg;

-(id)initWithEuexObj:(EUExScanner *)euexObj_;
@end
