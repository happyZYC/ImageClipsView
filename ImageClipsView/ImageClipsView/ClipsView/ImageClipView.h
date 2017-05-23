//
//  ImageClipView.h
//  图片剪切
//
//  Created by gmtx on 15/5/13.
//  Copyright (c) 2015年 gmtx. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 这是一个剪切图片的view
 使用init……方法后要设置image属性
 属性：image是要剪切的图片
 剪切后的图片通过block（callBack）返回
 */
typedef NS_ENUM(NSInteger, ImageClipType)
{
    ImageClipCircle = 0,
    ImageClipHerizonRect,
    ImageClipVerticalRect
};

@interface ImageClipView : UIView
//需要剪切的图片
@property(nonatomic, strong)UIImage *image;
//剪切图片的样式
@property(nonatomic, assign)ImageClipType clipType;

//默认头像剪切
-(instancetype)initWithFrame:(CGRect)frame andCallBack:(void(^)(UIImage *image))callBack;

-(instancetype)initWithFrame:(CGRect)frame clipeType:(ImageClipType)type andCallBack:(void(^)(UIImage *image))callBack;

@end
