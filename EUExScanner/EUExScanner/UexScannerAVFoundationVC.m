//
//  UexScannerAVFoundationVC.m
//  EUExScanner
//
//  Created by liguofu on 15/9/6.
//  Copyright (c) 2015年 AppCan.can. All rights reserved.
//

#import "UexScannerAVFoundationVC.h"
#import "EUExScanner.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)
#define IS_NSMutableArray(x) ([x isKindOfClass:[NSMutableArray class]] && [x count]>0)
#define TOOLBARH 60
#define TOOLBARBOTTOMH 60
#define READVIEWH 200
#define READVIEWW 200


@interface UexScannerAVFoundationVC ()

@end

@implementation UexScannerAVFoundationVC
@synthesize euexObj;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _typeArray = [NSMutableArray arrayWithCapacity:1];
    [_typeArray addObject:AVCaptureSessionPreset1280x720];//从高到低添加图像质量
    [_typeArray addObject:AVCaptureSessionPreset640x480];
    [_typeArray addObject:AVCaptureSessionPreset352x288];
    
    [self initMainView];
    
    [self setupCaptureSession];
}

-(id)initWithEuexObj:(EUExScanner *)euexObj_{
    euexObj = euexObj_;
    return self;
}

- (void) initMainView {
    
    _mainOverView = [[UIView alloc] initWithFrame:CGRectMake(0, TOOLBARH, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_mainOverView setUserInteractionEnabled:YES];
    [_mainOverView setAutoresizesSubviews:YES];
    
    [_mainOverView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationOfLine) userInfo:nil repeats:YES];
    
    [self.view addSubview:_mainOverView];
}

- (void)setupCaptureSession {
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //AVCaptureSessionPresetLow
    //AVCaptureSessionPresetHigh
    //AVCaptureSessionPresetMedium
    
    if ([_session canAddInput:self.input]) {
        
        [_session addInput:self.input];
        
    } else {
        
        NSInteger selectSize=_typeArray.count;
        
        for (int i = 0; i < selectSize; i++) {//循环判断设备是否支持图片质量
            
            _session.sessionPreset = [_typeArray objectAtIndex:i];
            
            if ([_session canAddInput:_input]) {//如果支持设备对象添加
                
                [_session addInput:_input];
                
                break;
            }
            
        }
        
        [euexObj uexScannerWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT data:@"设备不支持"];
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
        return;
        
        
    }
    
    if ([_session canAddOutput:self.output]) {
        
        [_session addOutput:self.output];
        
    } else {
        
        NSInteger selectSize=_typeArray.count;
        
        for (int i = 0; i < selectSize; i++) {
            
            _session.sessionPreset = [_typeArray objectAtIndex:i];
            
            if ([_session canAddOutput:_output]) {
                
                [_session addOutput:_output];
                break;
            }
            
        }
        [euexObj uexScannerWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT data:@"设备不支持"];
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
        return;
    }
    
//        CGSize size = self.view.bounds.size;
//        CGRect cropRect = CGRectMake(SCREEN_WIDTH/2-READVIEWW/2, SCREEN_HEIGHT/2-60-READVIEWH/2, READVIEWW, READVIEWH);
//        CGFloat p1 = size.height/size.width;
//        CGFloat p2 = 1920./1080.; //使用了1080p的图像输出
//        if (p1 < p2) {
//            CGFloat fixHeight = self.view.bounds.size.width * 1920. / 1080.;
//            CGFloat fixPadding = (fixHeight - size.height)/2;
//            _output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
//                                                cropRect.origin.x/size.width,
//                                                cropRect.size.height/fixHeight,
//                                                cropRect.size.width/size.width);
//        } else {
//            CGFloat fixWidth = self.view.bounds.size.height * 1080. / 1920.;
//            CGFloat fixPadding = (fixWidth - size.width)/2;
//            _output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
//                                                (cropRect.origin.x + fixPadding)/fixWidth,
//                                                cropRect.size.height/size.height,
//                                                cropRect.size.width/fixWidth);
//    
//        }
     _output.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    // 条码类型 AVMetadatatainObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code];
    
    //   self.output.metadataObjectTypes =@[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode] ;
    
   // _output.metadataObjectTypes = _output.availableMetadataObjectTypes;
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.bounds;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [_session startRunning];
    
    [self createScannerUI];
    
}

- (void)createScannerUI {
    
    _image = [[UIImageView alloc] initWithImage:self.pickBgImg?self.pickBgImg:[UIImage imageNamed:@"uexScanner/pick_bg.png"]];
    _image.frame = CGRectMake(SCREEN_WIDTH/2-READVIEWW/2, SCREEN_HEIGHT/2-60-READVIEWH/2, READVIEWW, READVIEWH);
    [_mainOverView addSubview:_image];
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, READVIEWW-20, 2)];
    _line.image = self.lineImg?self.lineImg:[UIImage imageNamed:@"uexScanner/line.png"];
    [_image addSubview:_line];
    
    toolStatusBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 20)];
    [toolStatusBar setBarStyle:UIBarStyleBlack];
    
    if (ABOVEiOS7) {
        
        toolBtnBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,20, SCREEN_WIDTH,TOOLBARH-20)];
        
    } else {
        
        toolBtnBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,TOOLBARH)];
        
    }
    
    [toolBtnBar setBarStyle:UIBarStyleBlack];
    
    toolBarBottom = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-TOOLBARBOTTOMH, SCREEN_WIDTH, TOOLBARBOTTOMH)];
    
    [toolBarBottom setBarStyle:UIBarStyleBlack];
    
    if (ABOVEiOS7) {
        
        [toolStatusBar setTintColor:[UIColor whiteColor]];
        [toolBtnBar setTintColor:[UIColor whiteColor]];
        [toolBarBottom setTintColor:[UIColor whiteColor]];
        
    }
    //闪光灯
    
    UIBarButtonItem *lightBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"uexScanner/ocr_flash-off"] style:UIBarButtonItemStylePlain target:self action:@selector(lightBtnClick)];
    
    //调取相册
    
    UIBarButtonItem *picture = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"uexScanner/ocr_albums"] style:UIBarButtonItemStylePlain target:self action:@selector(photoClick)];
    
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //取消按钮
    // NSString *cancelBtnImgStr = [[NSBundle mainBundle] pathForResource:@"uexScanner/ocrBack" ofType:@"png"];
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"uexScanner/ocrBack"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClick)];
    
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-READVIEWH/2, SCREEN_HEIGHT/2+READVIEWH/2-TOOLBARH+20, READVIEWW, 40)];
    
    label.text = self.scannerTip?self.scannerTip: @"对准二维码,即可扫描";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
   // [label sizeToFit];
    [label setBackgroundColor:[UIColor clearColor]];
    
    [self addAnimations];
    [self createBgView];
    [_mainOverView addSubview:label];
    
}

-(void)createBgView {
    
    UIView *view1 =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT/2-60-READVIEWH/2)];
    view1.backgroundColor = [UIColor blackColor];
    view1.alpha = 0.7;
    [_mainOverView addSubview:view1];
    UIView *view2 =[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2+READVIEWH/2-60, SCREEN_WIDTH, SCREEN_HEIGHT-120)];
    view2.backgroundColor = [UIColor blackColor];
    view2.alpha = 0.7;
    [_mainOverView addSubview:view2];
    UIView *view3 =[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2-60-READVIEWH/2, SCREEN_WIDTH/2-READVIEWH/2, READVIEWH)];
    view3.backgroundColor = [UIColor blackColor];
    view3.alpha = 0.7;
    [_mainOverView addSubview:view3];
    
    UIView *view4 =[[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2+READVIEWH/2, SCREEN_HEIGHT/2-60-READVIEWH/2, SCREEN_WIDTH/2-READVIEWH/2, READVIEWH)];
    view4.backgroundColor = [UIColor blackColor];
    view4.alpha = 0.7;
    [_mainOverView addSubview:view4];
}

- (void)addAnimations {
    
    UIImageView *imageUp = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-READVIEWH/2, SCREEN_HEIGHT/2-60-READVIEWH/2, READVIEWW, READVIEWH/2)];
    imageUp.image =[UIImage imageNamed:@"uexScanner/up"];
    [_mainOverView addSubview:imageUp];
    
    UIImageView *imageDown = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-READVIEWH/2, SCREEN_HEIGHT/2-60, READVIEWW, READVIEWH/2)];
    imageDown.image =[UIImage imageNamed:@"uexScanner/down"];
    [_mainOverView addSubview:imageDown];
    
    //up
    CABasicAnimation *translationUp = [CABasicAnimation animationWithKeyPath:@"position"];
    translationUp.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    translationUp.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, -SCREEN_HEIGHT)];
    translationUp.duration =0.5;
    translationUp.repeatCount = 1;
    translationUp.fillMode = kCAFillModeForwards;
    translationUp.removedOnCompletion = NO;
    //down
    CABasicAnimation *translationDown = [CABasicAnimation animationWithKeyPath:@"position"];
    translationDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translationDown.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT)];
    translationDown.duration = 0.5;
    translationDown.fillMode = kCAFillModeForwards;
    translationDown.removedOnCompletion = NO;
    [imageUp.layer addAnimation:translationUp forKey:nil];
    [imageDown.layer addAnimation:translationDown forKey:nil];
    
}


- (void)lightBtnClick {
    
    if (lightOn) {
        //关闭闪光灯
        [self turnOffFlash];
        lightOn = NO;
        
    } else {
        
        [self turnOnFlash];
        lightOn = YES;
   
    }

}

- (void)cancelBtnClick {
    
    if (lightOn) {
        lightOn = NO;
    }
    [self stopCamera];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

-(void)animationOfLine
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

- (void)stopCamera {
    
    if (_session.isRunning) {
        
        [_session stopRunning];
        _session = nil;
        [_player removeFromSuperlayer];
    } else {
        
        //
    }
    
}

- (void)photoClick {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
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

- (void)turnOffFlash {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (void)turnOnFlash {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSLog(@"appcan-->EUExScanner-->UexSCannerAVFoundationVC.m-->captureOutput");
    
    //    _line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, READVIEWW-20, 2)];
    //    num = 0;
    //    upOrdown = NO;
    NSString *resultCodeString = nil;
    NSString *resultType = nil;
    NSString *subString = @"org.iso.";
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        
        if (metadataObject) {
            
            if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]||[[metadataObject type] isEqualToString:AVMetadataObjectTypeCode128Code]) {
                
                resultType = [NSString stringWithFormat:@"%@", metadataObject.type];
                
                resultCodeString = [NSString stringWithFormat:@"%@", [metadataObject stringValue]];
            }
            
        }
        
        NSRange range = [resultType rangeOfString:subString];
        
        if (range.location != NSNotFound) {
            
            resultType = [resultType substringFromIndex:range.length];
        }
        
    }
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (resultCodeString) {
        
        NSString * resultCode = [EUtility transferredString:[resultCodeString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [resultDict setObject:resultCode forKey:UEX_JKCODE];
        
    } else {
        
        [resultDict setObject:@"" forKey:UEX_JKCODE];
        
    }
    
    if (resultType) {
        
        [resultDict setObject:resultType forKey:UEX_JKTYPE];
        
    }else {
        
        [resultDict setObject:@"" forKey:UEX_JKTYPE];
        
    }
    
    NSString *retJson = [resultDict JSONFragment];
    NSLog(@"appcan--ACPuexJHHCViewController--readerView==>didOutputSampleBuffer==>result== %@",retJson);
    
    //[euexObj uexScannerWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_JSON data:retJson];
    
    [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:retJson waitUntilDone:NO];
    
}

- (void)reportScanResult:(NSString *)retJson {
    
    [self cancelBtnClick];

    [euexObj uexScannerWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_JSON data:retJson];

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
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
        
    } else {
        
        [resultDict setObject:@"" forKey:UEX_JKCODE];
        
    }
    
    if (resultType) {
        
        [resultDict setObject:resultType forKey:UEX_JKTYPE];
        
    } else {
        
        [resultDict setObject:@"" forKey:UEX_JKTYPE];
        
    }
    
    self.retJson = [resultDict JSONFragment];
    
    [self performSelector:@selector(selectPic:) withObject:image afterDelay:0.2];
    
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
    [self cancelBtnClick];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
