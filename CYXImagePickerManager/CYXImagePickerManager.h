//
//  CYXImagePickerManager.h
//  ImagePicker
//
//  Created by 薛权 on 17/1/4.
//  Copyright © 2017年 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZImagePickerController.h"
#import <Photos/Photos.h>

@interface CYXImagePickerManager : NSObject

@property (nonatomic, strong, readonly) TZImagePickerController *pickerController;
//默认图片来源sourceType为PhotoLibrary,默认图片可编辑(得到的将是一张系统编辑后的图片)
@property (nonatomic, strong, readonly) UIImagePickerController *takePhotoController;

//从相册取图片
@property (nonatomic, copy) void(^didFinishPickingImages)(TZImagePickerController *pickerController, NSArray *images);
@property (nonatomic, copy) void(^didCancelPickingImages)(TZImagePickerController *pickerController);

//拍照
@property (nonatomic, copy) void(^didFinishTakePhoto)(UIImagePickerController *takePhotoController, UIImage *image);
@property (nonatomic, copy) void(^didCancelTakePhoto)(UIImagePickerController *takePhotoController);

+ (instancetype)sharedPickerManager;

// 便捷使用方法,无需考虑是拍照还是从相册选择.
- (void)showImagePickerSheetWithTitle:(NSString *)title fromVC:(UIViewController *)vc imageCount:(NSUInteger)imageCnt allowEditSingleImg:(BOOL)allowEditSingleImg completion:(void(^)(NSArray<UIImage *> *imgs))completionBlk;

// 相机是否可用
+ (BOOL)isCameraAvailable;
// 前置摄像头是否可用
+ (BOOL)isFrontCameraAvailable;
// 后置摄像头是否可用
+ (BOOL)isRearCameraAvailable;
// 相机授权状态
+ (AVAuthorizationStatus)cameraAuthStatus;

// 相册授权状态
+ (PHAuthorizationStatus)photoLibraryAuthStatus;

// 跳转到系统"设置"app
+ (void)guideToOpenAuth;


@end
