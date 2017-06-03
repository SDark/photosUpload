//
//  ViewController.m
//  相机混合选择上传
//
//  Created by Mory on 16/3/19.
//  Copyright © 2016年 Mory. All rights reserved.
//

#import "ViewController.h"
#import "MKComposePhotosView.h"
#import "MKMessagePhotoView.h"
#import "SDImageCache.h"

#define KWIDTH [UIScreen mainScreen].bounds.size.width
@interface ViewController ()<MKMessagePhotoViewDelegate>
@property (nonatomic, strong) MKMessagePhotoView *photosView;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"上传" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(uploadImageWithData) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setTitleColor:[UIColor  blueColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    
    ///如果有导航栏的话一定要添加，不然你试试
    self.edgesForExtendedLayout = NO;
    
    [self setUpPhotosView];
}


#pragma mark -相册视图
-(void)setUpPhotosView
{
    if (!self.photosView)
    {
        //设置图片展示区域
        self.photosView = [[MKMessagePhotoView alloc]initWithFrame:CGRectMake(0,230,KWIDTH, 100)];
        [self.view addSubview:self.photosView];
        self.photosView.backgroundColor = [UIColor lightGrayColor];
        self.photosView.delegate = self;
    }
    
}

//实现代理方法，相册
-(void)addPicker:(UIImagePickerController *)picker{
    
    [self presentViewController:picker animated:YES completion:nil];
}

//相机📷
-(void)addUIImagePicker:(UIImagePickerController *)picker{
    
    [self presentViewController:picker animated:YES completion:nil];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
}

//上传图片的通知事件
-(void)uploadImageWithData{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadImageWithData" object:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
