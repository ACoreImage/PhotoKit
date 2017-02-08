//
//  TJLImagePickerController.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/12.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLImagePickerController.h"
#import "TJLAlbumsViewController.h"
#import "TJLGridViewController.h"
#import <Photos/Photos.h>

@interface TJLImagePickerController ()

@property (strong, nonatomic) NSMutableArray *imageArray;

/**
 获取图片数组成功后的回调
 */
@property (nonatomic, strong) TJLPicPickerSuccessedHanlder successedHandler;

@end

@implementation TJLImagePickerController

static TJLImagePickerController *helper;

+ (instancetype) sharedInstance {
    @synchronized (self) {
        if (!helper){
            helper = [[self alloc] init];
        }
    }
    return helper;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized (self) {
        if (!helper) {
            helper = [super allocWithZone:zone];
            return helper;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotification];
}

#pragma mark --- notification

- (void)registerNotification {
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(notificationAction:) name:@"assetsArray" object:nil];
}

- (void)notificationAction:(NSNotification *)notification {
    [self.imageArray removeAllObjects];
    NSDictionary *dict = notification.userInfo;
    NSMutableArray *assetsArray = [dict objectForKey:@"assetsArray"];
    
    __weak typeof(self) weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    for (PHAsset *asset in assetsArray) {
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [weakSelf.imageArray addObject:result];
        }];
    }
    
    if (self.successedHandler) {
        self.successedHandler(self.imageArray);
    }
}

#pragma mark --- 获取相册照片的方法

- (void)showPickerInController:(UIViewController *)vc successBlock:(TJLPicPickerSuccessedHanlder)succeedHandler {
    
    self.successedHandler = succeedHandler;
    
    [vc.navigationController presentViewController:self animated:YES completion:nil];
    [self setupNavigationController];
    
//    //检查是否有访问权限
//    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
//        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//            if (status == PHAuthorizationStatusAuthorized) {
//                
//                self.successedHandler = succeedHandler;
//                
//                [vc.navigationController presentViewController:self animated:YES completion:nil];
//                [self setupNavigationController];
//                
//            } else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该应用没有访问相册的权限，您可以在设置中修改该配置" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }];
//    } else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
//        self.successedHandler = succeedHandler;
//        
//        [vc.navigationController presentViewController:self animated:YES completion:nil];
//        [self setupNavigationController];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该应用没有访问相册的权限，您可以在设置中修改该配置" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}

- (void)setupNavigationController {
    TJLAlbumsViewController *albumsViewController = [[TJLAlbumsViewController alloc] init];
    TJLGridViewController *gridViewController = [[TJLGridViewController alloc] init];
    [self setViewControllers:@[albumsViewController, gridViewController]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- get

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

@end
