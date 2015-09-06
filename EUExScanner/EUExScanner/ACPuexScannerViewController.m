//
//  ViewController.m
//  NewProject
//
//  Created by liguofu on 15/3/4.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//


#import "ACPuexScannerViewController.h"
#import "EUExScanner.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HIGH  ([UIScreen mainScreen].bounds.size.height)
#define TOOLBARH 60
#define TOOLBARBOTTOMH 60
#define READVIEWH 240
#define READVIEWW 240


@interface ACPuexScannerViewController ()

@end

@implementation ACPuexScannerViewController
@synthesize euexObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithEuexObj:(EUExScanner *)euexObj_{
    euexObj = euexObj_;
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self setCamera];
}

- (void)setCamera  {
    if (readview) {
        return;
    }
    
    readview = [ZBarReaderView new];
    //自定义大小
    readview.frame = CGRectMake(0, TOOLBARH, SCREEN_WIDTH, SCREEN_HIGH-TOOLBARH-TOOLBARBOTTOMH);
    
    //处理模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSimulator
        = [[ZBarCameraSimulator alloc]initWithViewController:self];
        cameraSimulator.readerView = readview;
    }
    
    [self createScannerUI];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    readview.torchMode = 0;
   //readview.scanCrop = CGRectMake(SCREEN_WIDTH/2-READVIEWW/2, SCREEN_HIGH/2-60-READVIEWH/2, READVIEWW, READVIEWH);
    // 设置代理
    readview.readerDelegate = self;
    
    //二维码/条形码识别设置
    ZBarImageScanner *scanner = readview.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    //启动，必须启动后，手机摄影头拍摄的即时图像菜可以显示在readview上
    [readview start];
}

- (void)createScannerUI {
    
    _image = [[UIImageView alloc] initWithImage:self.pickBgImg?self.pickBgImg:[UIImage imageNamed:@"uexScanner/pick_bg.png"]];
    _image.frame = CGRectMake(SCREEN_WIDTH/2-READVIEWW/2, SCREEN_HIGH/2-60-READVIEWH/2, READVIEWW, READVIEWH);
    [readview addSubview:_image];
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, READVIEWW-20, 2)];
    _line.image = self.lineImg?self.lineImg:[UIImage imageNamed:@"uexScanner/line.png"];
    [_image addSubview:_line];
    
    toolStatusBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 20)];
    [toolStatusBar setBarStyle:UIBarStyleBlack];
    
    if (ABOVEiOS7) {
        
        toolBtnBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,20, SCREEN_WIDTH,TOOLBARH-20)];
        
    }else{
        
        toolBtnBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,TOOLBARH)];
        
    }
    
    [toolBtnBar setBarStyle:UIBarStyleBlack];
    
    toolBarBottom = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HIGH-TOOLBARBOTTOMH, SCREEN_WIDTH, TOOLBARBOTTOMH)];
    [toolBarBottom setBarStyle:UIBarStyleBlack];
    
    if (ABOVEiOS7) {
        [toolStatusBar setTintColor:[UIColor whiteColor]];
        [toolBtnBar setTintColor:[UIColor whiteColor]];
        [toolBarBottom setTintColor:[UIColor whiteColor]];
    }
    //闪光灯
    // NSString * lightImgStr = [[NSBundle mainBundle] pathForResource:@"uexScanner/ocr_flash-off" ofType:@"png"];
    
    UIBarButtonItem *lightBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"uexScanner/ocr_flash-off"] style:UIBarButtonItemStylePlain target:self action:@selector(lightBtnClick:)];
    
    //调取相册
    //    NSString * pictureImgStr = [[NSBundle mainBundle] pathForResource:@"uexScanner/ocr_albums" ofType:@"png"];
    
    UIBarButtonItem *picture = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"uexScanner/ocr_albums"] style:UIBarButtonItemStylePlain target:self action:@selector(photoClick:)];
    
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //取消按钮
    // NSString *cancelBtnImgStr = [[NSBundle mainBundle] pathForResource:@"uexScanner/ocrBack" ofType:@"png"];
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"uexScanner/ocrBack"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClick:)];
    
    
    //  UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClick:)];
    
    //    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
    //                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClick:)];
    
    //标题头
    NSString *titleStr = self.scannerTitle?self.scannerTitle:@"扫一扫";
    UIBarButtonItem *titleLabel = [[UIBarButtonItem alloc] initWithTitle:titleStr
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:NULL];
    
    [toolBtnBar setItems:[NSArray arrayWithObjects:cancelBtn, flexibleSpace, titleLabel, flexibleSpace, nil]];
    
    [toolBarBottom setItems:[NSArray arrayWithObjects:lightBtn, flexibleSpace, picture, nil]];
    [self.view addSubview:toolStatusBar];
    [self.view addSubview:toolBarBottom];
    [self.view addSubview:toolBtnBar];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-READVIEWH/2, SCREEN_HIGH/2+READVIEWH/2-TOOLBARH+20, READVIEWW, 40)];
    label.text = self.scannerTip?self.scannerTip: @"对准二维码/条形码,即可自动扫描";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    [label sizeToFit];
    [label setBackgroundColor:[UIColor clearColor]];
    
    [self addAnimations];
    [self createBgView];
    [readview addSubview:label];
    //将其照相机拍摄视图添加到要显示的视图上
    [self.view addSubview:readview];
}

-(void)createBgView {
    
    UIView *view1 =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HIGH/2-60-READVIEWH/2)];
    view1.backgroundColor = [UIColor blackColor];
    view1.alpha = 0.7;
    [readview addSubview:view1];
    UIView *view2 =[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HIGH/2+READVIEWH/2-60, SCREEN_WIDTH, SCREEN_HIGH-120)];
    view2.backgroundColor = [UIColor blackColor];
    view2.alpha = 0.7;
    [readview addSubview:view2];
    UIView *view3 =[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HIGH/2-60-READVIEWH/2, SCREEN_WIDTH/2-READVIEWH/2, READVIEWH)];
    view3.backgroundColor = [UIColor blackColor];
    view3.alpha = 0.7;
    [readview addSubview:view3];
    
    UIView *view4 =[[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2+READVIEWH/2, SCREEN_HIGH/2-60-READVIEWH/2, SCREEN_WIDTH/2-READVIEWH/2, READVIEWH)];
    view4.backgroundColor = [UIColor blackColor];
    view4.alpha = 0.7;
    [readview addSubview:view4];
}

- (void)addAnimations {
    UIImageView *imageUp = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-READVIEWH/2, SCREEN_HIGH/2-60-READVIEWH/2, READVIEWW, READVIEWH/2)];
    imageUp.image =[UIImage imageNamed:@"uexScanner/up"];
    [readview addSubview:imageUp];
    
    UIImageView *imageDown = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-READVIEWH/2, SCREEN_HIGH/2-60, READVIEWW, READVIEWH/2)];
    imageDown.image =[UIImage imageNamed:@"uexScanner/down"];
    [readview addSubview:imageDown];
    
    //up
    CABasicAnimation *translationUp = [CABasicAnimation animationWithKeyPath:@"position"];
    translationUp.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    translationUp.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, -100)];
    translationUp.duration =0.5;
    translationUp.repeatCount = 1;
    translationUp.fillMode = kCAFillModeForwards;
    translationUp.removedOnCompletion = NO;
    //down
    CABasicAnimation *translationDown = [CABasicAnimation animationWithKeyPath:@"position"];
    translationDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translationDown.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HIGH)];
    translationDown.duration = 0.5;
    translationDown.fillMode = kCAFillModeForwards;
    translationDown.removedOnCompletion = NO;
    [imageUp.layer addAnimation:translationUp forKey:nil];
    [imageDown.layer addAnimation:translationDown forKey:nil];
}

-(void)cancelBtnClick:(id)sender{
    
    [timer invalidate];
    [readview removeFromSuperview];
    [toolBarBottom removeFromSuperview];
    [toolStatusBar removeFromSuperview];
    [readview stop];
    readview = nil;
    toolStatusBar = nil;
    toolBarBottom = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    if (lightOn) {
        lightOn = NO;
    }
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(10, 10+2*num, READVIEWW-20, 2);
        if (2*num == READVIEWH-20) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(10, 10+2*num, READVIEWW-20, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

-(void)photoClick:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
    
}
- (void)viewWillAppear:(BOOL)animated {
    
    NSNumber *statusBarHidden = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarHidden"];
    if ([statusBarHidden boolValue] == YES) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:euexObj.initialStatusBarStyle];
    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [picker removeFromParentViewController];
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //初始化
    ZBarReaderController * read = [ZBarReaderController new];
    //设置代理
    read.readerDelegate = self;
    CGImageRef cgImageRef = image.CGImage;
    ZBarSymbol * symbol = nil;
    id <NSFastEnumeration> results = [read scanImage:cgImageRef];
    for (symbol in results)
    {
        break;
    }
    NSString *resultCode = nil;
    NSString *resultType = nil;
    if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding]) {
        //解决中文乱码问题
        resultCode = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        
    }else{
        
        resultCode = symbol.data;
        
    }
    resultType = symbol.typeName;
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:5];
    if (resultCode) {
        [resultDict setObject:resultCode forKey:UEX_JKCODE];
    }else {
        [resultDict setObject:@"" forKey:UEX_JKCODE];
    }
    if (resultType) {
        [resultDict setObject:resultType forKey:UEX_JKTYPE];
    }else {
        [resultDict setObject:@"" forKey:UEX_JKTYPE];
    }
    self.retJson = [resultDict JSONFragment];
    [self performSelector:@selector(selectPic:) withObject:image afterDelay:0.2];
    ///NSLog(@"相册获取----%@",resultCode);
}

-(void)selectPic:(UIImage*)image {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, READVIEWW, READVIEWH);
    [_image addSubview:imageView];
    [euexObj uexScannerWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_JSON data:self.retJson];
    [self performSelector:@selector(detect:) withObject:nil afterDelay:0.5];
}

- (void)detect:(id)sender {
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, READVIEWW-20, 2)];
    num = 0;
    upOrdown = NO;
    [self cancelBtnClick:nil];
}

-(void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image {
    
    [self cancelBtnClick:nil];
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, READVIEWW-20, 2)];
    num = 0;
    upOrdown = NO;
    
    ZBarSymbol *symbol = nil;
    NSString *resultCode = nil;
    NSString *resultType = nil;
    
    for (symbol in symbols)
        break;
    resultCode = symbol.data;
    resultType = symbol.typeName;
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:5];
    if (resultCode) {
        [resultDict setObject:resultCode forKey:UEX_JKCODE];
    }else {
        [resultDict setObject:@"" forKey:UEX_JKCODE];
    }
    if (resultType) {
        [resultDict setObject:resultType forKey:UEX_JKTYPE];
    }else {
        [resultDict setObject:@"" forKey:UEX_JKTYPE];
    }
    NSString *retJson = [resultDict JSONFragment];
    [euexObj uexScannerWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_JSON data:retJson];
}

-(void)lightBtnClick:(id)sender{
    
    if (lightOn) {
        //关闭闪光灯
        [self turnOffFlash];
        lightOn = NO;
    } else {
        [self turnOnFlash];
        lightOn = YES;
    }
}

-(void)turnOffFlash{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

-(void)turnOnFlash{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation

{
    
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    
}

- (BOOL)shouldAutorotate

{
    
    return NO;
    
}

- (NSUInteger)supportedInterfaceOrientations

{
    
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
