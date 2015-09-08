//
//  UexScannerAVFoundationVC.h
//  EUExScanner
//
//  Created by liguofu on 15/9/6.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ZBarSDK.h"

@class EUExScanner;

@interface UexScannerAVFoundationVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZBarReaderDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer *timer;
    BOOL lightOn;
    UIToolbar *toolStatusBar;
    UIToolbar *toolBtnBar;
    UIToolbar  *toolBarBottom;
}
@property (nonatomic, assign) EUExScanner *euexObj;

@property (nonatomic, retain) UIImageView *line;

@property (nonatomic, strong) UIImageView *image;

@property (nonatomic, strong) NSString *retJson;

@property (nonatomic, strong) NSString *scannerTitle;

@property (nonatomic, strong) NSString *scannerTip;

@property (nonatomic, retain) UIImage *lineImg;

@property (nonatomic, strong) UIImage *flashImg;

@property (nonatomic, strong) UIImage *pickBgImg;

@property (nonatomic, strong) UIView *mainOverView;

@property (nonatomic, strong) AVCaptureDevice * device;

@property (nonatomic, strong) UIToolbar *bottomToolBar;

@property (nonatomic, strong) UIBarButtonItem *lightBtn;

@property (nonatomic, strong) UIBarButtonItem *inputBtn;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) UIBarButtonItem *cancelBtn;

@property (nonatomic, strong) NSString *uexJHHCPlist_Path;

@property (nonatomic, strong) AVCaptureDeviceInput *input;

@property (nonatomic, strong) UIBarButtonItem *checkListBtn;

@property (nonatomic, strong) UIBarButtonItem *flexibleSpace;

@property (nonatomic, strong) NSMutableArray *scanner_CodeArr;

@property (strong,nonatomic) AVCaptureMetadataOutput * output;

@property (strong,nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *player;

@property (nonatomic, strong) NSMutableArray *typeArray;

-(id)initWithEuexObj:(EUExScanner *)euexObj_;

@end
