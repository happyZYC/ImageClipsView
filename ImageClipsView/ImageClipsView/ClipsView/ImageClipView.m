//
//  ImageClipView.m
//  图片剪切
//
//  Created by gmtx on 15/5/13.
//  Copyright (c) 2015年 gmtx. All rights reserved.
//

#import "ImageClipView.h"

#define IPHONE4     ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)


@interface ImageClipView()<UIGestureRecognizerDelegate>
@property(nonatomic, strong)UIView *operateView;            //操作图像的view
@property(nonatomic, strong)UIImageView *imageView;         //加载图片
@property(nonatomic, strong)UIView *headerView;             //用于剪切图像
@property(nonatomic, copy)void(^callBack)(UIImage *image);  //
@property(nonatomic, assign)CGRect imageViewFrame;          //imageView的初始值
@end
@implementation ImageClipView

-(instancetype)initWithFrame:(CGRect)frame andCallBack:(void(^)(UIImage *image))callBack
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.callBack = callBack;
        self.clipType = ImageClipCircle;
        [self initUI];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame clipeType:(ImageClipType)type andCallBack:(void(^)(UIImage *image))callBack
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.callBack = callBack;
        self.clipType = type;
        [self initUI];
    }
    return self;
}

#pragma mark 初始化控件
-(void)initUI
{
    //操作图片的view
    UIView *operateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    operateView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height/ 2);
    operateView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    operateView.layer.masksToBounds = YES;
    [self addSubview:operateView];
    self.operateView = operateView;
    [self addGR:operateView];
    //头像
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 225, 225)];
    switch (self.clipType) {
        case ImageClipCircle:
            
            break;
        case ImageClipHerizonRect:
        {
            CGFloat width = self.bounds.size.width;
            CGRect frame = headerView.frame;
            frame.size.width = width;
            frame.size.height = frame.size.width * 0.8;
            headerView.frame = frame;
        }
            
            break;
        case ImageClipVerticalRect:
        {
            CGFloat width = self.bounds.size.width;
            CGRect frame = headerView.frame;
            frame.size.width = width * (IPHONE4 ? 0.8 : 0.85);
            frame.size.height = frame.size.width * 1.5;
            headerView.frame = frame;
        }
            
            break;
            
        default:
            break;
    }
    headerView.center = CGPointMake(operateView.bounds.size.width / 2, operateView.bounds.size.height / 2);
    self.headerView = headerView;
    [operateView addSubview:headerView];
    //imageView
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:headerView.bounds];
    self.imageView = imageView;
    imageView.userInteractionEnabled = YES;
    [headerView addSubview:imageView];
    self.imageViewFrame = imageView.frame;
    //覆盖在operateView上得镂空的view
    UIView *coverView = [[UIView alloc]initWithFrame:operateView.bounds];
    coverView.layer.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:coverView.bounds];
    switch (self.clipType) {
        case ImageClipCircle:
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(coverView.bounds.size.width / 2, coverView.bounds.size.height / 2) radius:225.0 / 2 startAngle:0 endAngle:2*M_PI clockwise:NO]];
            break;
        case ImageClipHerizonRect:
            [path appendPath:[[UIBezierPath bezierPathWithRect:headerView.frame] bezierPathByReversingPath]];
            break;
        case ImageClipVerticalRect:
            [path appendPath:[[UIBezierPath bezierPathWithRect:headerView.frame] bezierPathByReversingPath]];
            break;
            
        default:
            break;
    }

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    coverView.layer.mask = shapeLayer;
    [operateView addSubview:coverView];
    
    [self addCancelAndCertainButton];
}
#pragma mark 添加取消确定按钮
-(void)addCancelAndCertainButton
{
    //取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(10, self.bounds.size.height - (IPHONE4 ? 45 : 50), 50, 30);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(cancelbuttonAction) forControlEvents:UIControlEventTouchUpInside];
    //确定按钮
    UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commitButton.frame = CGRectMake(self.bounds.size.width - 60, self.bounds.size.height - (IPHONE4 ? 45 : 50), 50, 30);
    [commitButton setTitle:@"确定" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    commitButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:commitButton];
    [commitButton addTarget:self action:@selector(commitButton) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark 取消
-(void)cancelbuttonAction
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1.0;
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.frame = self.imageViewFrame;
    }];
}
#pragma mark 设置imageView中的image
-(void)setImage:(UIImage *)image
{
    _image = image;
    CGPoint center = self.imageView.center;
    CGSize imageSize = image.size;
    //图片和屏幕等宽
    CGRect frame = self.imageView.frame;
    frame.size.width = self.bounds.size.width;
    frame.size.height = self.bounds.size.width * imageSize.height / imageSize.width;
    self.imageView.frame = frame;
    self.imageView.center = center;
    self.imageView.image = image;
}
#pragma mark 添加手势
-(void)addGR:(UIView *)view
{
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    UIRotationGestureRecognizer *rotationGR = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationAction:)];
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
    [view addGestureRecognizer:panGR];
    [view addGestureRecognizer:rotationGR];
    [view addGestureRecognizer:pinchGR];
    rotationGR.delegate = self;
}
#pragma mark pan
-(void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint distance = [pan translationInView:self.operateView];
    self.imageView.center = CGPointMake(self.imageView.center.x + distance.x, self.imageView.center.y + distance.y);
    [pan setTranslation:CGPointZero inView:self.operateView];
}
#pragma mark rotation
-(void)rotationAction:(UIRotationGestureRecognizer *)rotation
{
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, rotation.rotation);
    rotation.rotation = 0.0;
}
#pragma mark pinch
-(void)pinchAction:(UIPinchGestureRecognizer *)pinch
{
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1.0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark 确定
-(void)commitButton
{
    self.headerView.backgroundColor = [UIColor lightGrayColor];
    self.callBack([self getImageFromView:self.headerView]);
    self.headerView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1.0;
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.frame = self.imageViewFrame;
    }];
}
#pragma mark 从myView中取图片
-(UIImage *)getImageFromView:(UIView *)view
{
    //创建一个画布
    UIGraphicsBeginImageContext(view.bounds.size);
    //把控件内容渲染到画布中
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //把图片从画布中取出
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束
    UIGraphicsEndImageContext();
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
