//
//  CYXImagePickerManager.m
//  ImagePicker
//
//  Created by 薛权 on 17/1/4.
//  Copyright © 2017年 Katsuma Tanaka. All rights reserved.
//

#import "CYXImagePickerManager.h"
#import <XQSheet.h>

static CYXImagePickerManager *pickerManager;

@interface CYXImagePickerManager ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) TZImagePickerController *pickerController;
@property (nonatomic, strong) UIImagePickerController *takePhotoController;

@end

@implementation CYXImagePickerManager

+ (instancetype)sharedPickerManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pickerManager = [[[self class] alloc] init];
    });
    
    return pickerManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pickerManager = [super allocWithZone:zone];
    });
    return pickerManager;
}

- (TZImagePickerController *)pickerController
{
    if (_pickerController == nil) {
        TZImagePickerController *pickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:nil];
        pickerController.barItemTextFont = [UIFont systemFontOfSize:15];
        pickerController.allowPickingVideo = NO;
        pickerController.allowTakePicture = NO;
        __weak typeof(self) weakSelf = self;
        __weak typeof(pickerController) weakPickerController = pickerController;
        [pickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            if (weakSelf.didFinishPickingImages) {
                weakSelf.didFinishPickingImages(weakPickerController, photos);
            }
            [weakSelf reset];
        }];
        [pickerController setImagePickerControllerDidCancelHandle:^{
            if (weakSelf.didCancelPickingImages) {
                weakSelf.didCancelPickingImages(weakPickerController);
            }
            [weakSelf reset];
        }];
        _pickerController = pickerController;
    }
    
    return _pickerController;
}

- (UIImagePickerController *)takePhotoController
{
    if (_takePhotoController == nil) {
        UIImagePickerController *takePhotoController = [[UIImagePickerController alloc] init];
        takePhotoController.delegate = pickerManager;
        takePhotoController.view.backgroundColor = [UIColor whiteColor];
        takePhotoController.allowsEditing = YES; //默认可编辑
        takePhotoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //默认图片来源为PhotoLibrary
        _takePhotoController = takePhotoController;
    }
    return _takePhotoController;
}

- (void)showImagePickerSheetWithTitle:(NSString *)title fromVC:(UIViewController *)vc imageCount:(NSUInteger)imageCnt allowEditSingleImg:(BOOL)allowEditSingleImg completion:(void (^)(NSArray<UIImage *> *))completionBlk
{
    XQSheet *sheet = [XQSheet sheetWithType:XQSheetTypeSelect title:title subTitle:nil cancelButtonTitle:@"取消"];
    [sheet addBtnWithTitle:@"从手机相册选择" configHandler:nil actionHandler:^(UIButton *button, NSString *buttonTitle, NSInteger buttonIndex) {
        // 权限判断
        PHAuthorizationStatus authStatus = [[self class] photoLibraryAuthStatus];
        if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
            [self showGuideAuthAlertWithMessage:@"应用未获得授权访问相册，是否前往设置打开？" fromVC:vc];
            return ; //第一次使用时未决定,系统会自动弹出.
        }
        
        if (imageCnt == 1 && allowEditSingleImg) { //调用系统的照片选择
            self.takePhotoController.allowsEditing = allowEditSingleImg;
            self.takePhotoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.didFinishTakePhoto = ^(UIImagePickerController *takePhotoController, UIImage *image){
                [takePhotoController dismissViewControllerAnimated:YES completion:^{
                    if (completionBlk) completionBlk(@[image]);
                }];
            };
            self.didCancelTakePhoto = ^(UIImagePickerController *takePhotoController){
                [takePhotoController dismissViewControllerAnimated:YES completion:nil];
            };
            [vc presentViewController:self.takePhotoController animated:YES completion:nil];
        } else {
            self.pickerController.maxImagesCount = imageCnt;
            self.didFinishPickingImages = ^(TZImagePickerController *pickerController, NSArray *images){
                if (completionBlk) completionBlk(images);
            };
            self.didCancelPickingImages = ^(TZImagePickerController *pickerController){
                [pickerController dismissViewControllerAnimated:YES completion:nil];
            };
            [vc presentViewController:pickerManager.pickerController animated:YES completion:nil];
        }
    }];
    [sheet addBtnWithTitle:@"拍一张" configHandler:nil actionHandler:^(UIButton *button, NSString *buttonTitle, NSInteger buttonIndex) {
        // 判断设备是否支持拍照
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"当前设备暂不支持拍照" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [vc presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        // 权限判断
        AVAuthorizationStatus authStatus = [[self class] cameraAuthStatus];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self showGuideAuthAlertWithMessage:@"应用未获得授权使用摄像头，是否前往设置打开？" fromVC:vc];
            return ; //第一次使用时未决定,系统会自动弹出.
        }
        
        // 拍照
        self.takePhotoController.allowsEditing = allowEditSingleImg;
        self.takePhotoController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerManager.didFinishTakePhoto = ^(UIImagePickerController *takePhotoController, UIImage *image){
            [takePhotoController dismissViewControllerAnimated:YES completion:^{
                if (completionBlk) completionBlk(@[image]);
            }];
        };
        self.didCancelTakePhoto = ^(UIImagePickerController *takePhotoController){
            [takePhotoController dismissViewControllerAnimated:YES completion:nil];
        };
        [vc presentViewController:self.takePhotoController animated:YES completion:nil];
    }];
    
    [sheet showSheet];
}

- (void)showGuideAuthAlertWithMessage:(NSString *)msg fromVC:(UIViewController *)vc
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[self class] guideToOpenAuth];
    }];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [vc presentViewController:alertController animated:YES completion:nil];
}

- (void)reset
{
    self.pickerController = nil;
    self.takePhotoController = nil;
    
    self.didFinishPickingImages = nil;
    self.didCancelPickingImages = nil;
    
    self.didFinishTakePhoto = nil;
    self.didCancelTakePhoto = nil;
}

// 相机是否可用
+ (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前置摄像头是否可用
+ (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后置摄像头是否可用
+ (BOOL)isRearCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

// 相机授权状态
+ (AVAuthorizationStatus)cameraAuthStatus
{
    AVAuthorizationStatus authorizedStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authorizedStatus;
}

// 相册授权状态
+ (PHAuthorizationStatus)photoLibraryAuthStatus
{
    PHAuthorizationStatus authorizedStatus = [PHPhotoLibrary authorizationStatus];
    return authorizedStatus;
}

+ (void)guideToOpenAuth
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.didFinishTakePhoto) {
        NSString *imgKey = self.takePhotoController.allowsEditing?UIImagePickerControllerEditedImage:UIImagePickerControllerOriginalImage;
        UIImage *image = [info objectForKey:imgKey];
        self.didFinishTakePhoto(picker, image);
    }
    
    [self reset];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.didCancelTakePhoto) {
        self.didCancelTakePhoto(picker);
    }
    
    [self reset];
}

@end
