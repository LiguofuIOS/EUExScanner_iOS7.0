//
//  EUExScanner.h
//  EUExScanner
//
//  Created by liguofu on 15/3/17.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EUExBase.h"
#import "EUtility.h"
#import "ACPuexScannerViewController.h"
#import "JSON.h"
#import "UexScannerAVFoundationVC.h"

#define UEX_JKCODE						  @"code"
#define UEX_JKTYPE						  @"type"
#define ABOVEiOS7  ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedDescending )

@interface EUExScanner : EUExBase {
    
}

@property (nonatomic, assign)UIStatusBarStyle initialStatusBarStyle;

@property (nonatomic, strong) NSMutableDictionary *jsonDict;

@property (nonatomic, strong) UexScannerAVFoundationVC *scannerAVFoudationVC;

@property (nonatomic, strong) ACPuexScannerViewController *scannerVC;

-(void)uexScannerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString *)inData;

@end
