//
//  CYXImagePickerManager.h
//  ImagePicker
//
//  Created by 薛权 on 17/1/4.
//  Copyright © 2017年 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <TZImagePickerController/TZImagePickerController.h>

typedef NS_ENUM( NSInteger, CYXImagePickerType) {
    CYXImagePickerTypePickImage,
    CYXImagePickerTypeTakePhoto,
};

@interface CYXImagePickerManager : NSObject

@property (nonatomic, strong, readonly) TZImagePickerController *pickerController;
//默认图片来源sourceType为PhotoLibrary,默认图片可编辑(得到的将是一张系统编辑后的图片)
@property (nonatomic, strong, readonly) UIImagePickerController *takePhotoController;

+ (instancetype)sharedPickerManager;

- (void)showImagePickerWithType:(CYXImagePickerType)type fromVC:(UIViewController *)vc imageCount:(NSUInteger)imageCnt allowEditSingleImage:(BOOL)isAllowEdit didFinishBlk:(void (^)(NSArray<UIImage *> *imgs))didFinishBlk didCancelBlk:(void (^)(void))didCancelBlk;

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
