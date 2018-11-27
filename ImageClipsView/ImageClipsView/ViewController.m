//
//  ViewController.m
//  ImageClipsView
//
//  Created by 赵永昌 on 2017/5/23.
//  Copyright © 2017年 chengzhen. All rights reserved.
//

#import "ViewController.h"
#import "ImageClipView.h"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"cesi");
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    imageV.image = [UIImage imageNamed:@"test2"];
    imageV.center = self.view.center;
    imageV.layer.masksToBounds = YES;
    imageV.layer.cornerRadius = 60;
    imageV.userInteractionEnabled = YES;
    [self.view addSubview:imageV];
    self.imageView = imageV;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [imageV addGestureRecognizer:tap];
    
}
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *imagePick = [[UIImagePickerController alloc]init];
        imagePick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePick.delegate = self;
        [self presentViewController:imagePick animated:YES completion:^{
            
        }];
        
    }];
    UIAlertAction *photeAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }else{
            NSLog(@"请用真机拍照");
        }
        
        
    }];
    [controller addAction:cancleAction];
    [controller addAction:albumAction];
    [controller addAction:photeAction];
    [self presentViewController:controller animated:YES completion:nil];
    
}
#pragma mark 图片选择
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    ImageClipView *clipView = [[ImageClipView alloc]initWithFrame:[UIScreen mainScreen].bounds clipeType:ImageClipCircle andCallBack:^(UIImage *image) {
        
        self.imageView.image = image;
        
    }];
    clipView.image = originalImage;
    [self.view addSubview:clipView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
