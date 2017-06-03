//
//  SComposePhotosView.h
//
//  Created by Mory on 16/3/12.
//  Copyright © 2016年 MCWonders. All rights reserved.
//


#import "MKComposePhotosView.h"

@implementation MKComposePhotosView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setImage:(UIImage *)image
{
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor =[UIColor grayColor].CGColor;
    imageView.image = image;
    imageView.tag = self.index;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCategory:)]];
    
    [self addSubview:imageView];
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.frame = CGRectMake(imageView.frame.size.width - 15, 0, 15, 15);
    [btnDelete setImage:[UIImage imageNamed:@"common_del_circle"] forState:UIControlStateNormal];
    btnDelete.tag = self.index;
    [btnDelete addTarget:self
                  action:@selector(deletePhotoItem:)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDelete];

}

///删除图片的代理方法
-(void)deletePhotoItem:(UIButton *)sender{

    if ([self.delegate respondsToSelector:@selector(MKComposePhotosView:didSelectDeleBtnAtIndex:)]) {
        [self.delegate MKComposePhotosView:self didSelectDeleBtnAtIndex:sender.tag];
    }
}


///浏览图片的代理方法
-(void)clickCategory:(UITapGestureRecognizer *)gestureRecognizer{

//    追溯图片属性
    UIView *viewClicked = [gestureRecognizer view];
    NSLog(@"点击了第%lu个",(unsigned long)viewClicked.tag);
    
    if ([self.delegate respondsToSelector:@selector(MKComposePhotosView:didSelectImageAtIndex:)]) {
        [self.delegate MKComposePhotosView:self didSelectImageAtIndex:viewClicked.tag];
    }
    
    
}

@end
