//
//  MKMessagePhotoView.h
//
//  Created by Mory on 16/3/12.
//  Copyright © 2016年 MCWonders. All rights reserved.
//


#import "MKMessagePhotoView.h"


#define MaxItemCount 9
#define ItemWidth 100
#define ItemHeight 100

//图片路径
#define  ImagePath  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Documents"]
#define KWIDTH [UIScreen mainScreen].bounds.size.width

@interface MKMessagePhotoView ()

/**
 *  这是背景滚动视图
 */
@property (nonatomic,strong) UIScrollView  *photoScrollView;
@property (nonatomic,strong) MKComposePhotosView *photoItem;
@property (nonatomic,strong) NSMutableArray *array;//展示图片数
@property (nonatomic,strong) NSMutableArray *imgsArr;//沙盒中图片数
@property (nonatomic,strong) NSMutableArray *imagePath;//图片不同的路径

@end
static int k = 10000;//分别提供不同的图片名称
@implementation MKMessagePhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup{

    
    ///注册通知,用以接收上传通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadImageWithData) name:@"uploadImageWithData" object:nil];
    
    _photoScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KWIDTH, 100)];
    _array = [NSMutableArray arrayWithCapacity:0];
    _imgsArr = [NSMutableArray arrayWithCapacity:0];
    _imagePath = [NSMutableArray arrayWithCapacity:0];
    [self addSubview:_photoScrollView];
    
    [self initlizerScrollView:_array];
}

///调用布局
-(void)initlizerScrollView:(NSArray *)imgList{

    ///移除之前添加的图片缩略图
    [self.photoScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(int i=0;i<imgList.count;i++){

        _photoItem = [[MKComposePhotosView alloc]initWithFrame:CGRectMake(5+ i * (ItemWidth + 5 ), 0, ItemWidth, ItemHeight)];
        _photoItem.delegate = self;
        _photoItem.index = i;
        _photoItem.image = (UIImage *)[imgList objectAtIndex:i];
        [self.photoScrollView addSubview:_photoItem];
        
    }
    if(imgList.count<MaxItemCount){
        
        UIImageView *addPhotos =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addImage.jpg"]];
        [addPhotos setFrame:CGRectMake(5 + (ItemWidth + 5) * imgList.count, 0, 100, 100)];
        [addPhotos setUserInteractionEnabled:YES];
        
        [addPhotos addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAddPhotos:)]];
        
        [self.photoScrollView addSubview:addPhotos];
    }
    
    NSLog(@"self.frame.origin.y是:%f",self.frame.size.height);
    NSInteger count = MIN(imgList.count +1, MaxItemCount);
    NSLog(@"图片总数量：%ld",_array.count);
        

    [self.photoScrollView setContentSize:CGSizeMake(5 + (ItemWidth + 5)*count, 0)];
    
}

///浏览图片的代理方法
-(void)clickAddPhotos:(UITapGestureRecognizer *)gestureRecognizer{
    //在这里呼出下方菜单按钮项
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"打开照相机",@"从手机相册获取", nil];

    [myActionSheet showInView:self.window];
    
}

//下拉菜单的点击响应事件
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == myActionSheet.cancelButtonIndex){
        NSLog(@"取消");
    }
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
        case 1:
            [self localPhoto];
            break;
        default:
            break;
    }
}

//开始拍照
-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
       
        [self.delegate addUIImagePicker:picker];
    
    }else{
        NSLog(@"模拟机中无法打开照相机,请在真机中使用");
    }
}


#pragma mark - ImagePicker delegate
//相机照完后点击use  后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image =[info objectForKey:UIImagePickerControllerOriginalImage];
    [_array addObject:image];

    [self initlizerScrollView:_array];

}

//打开相册，可以多选
-(void)localPhoto{
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc]init];
    
    picker.maximumNumberOfSelection = 10;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
//    picker.assetsFilter = [ALAssetsFilter allVideos];
    picker.showEmptyGroups = NO;
    picker.delegate = self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,NSDictionary *bindings){
        
        ///如果是视频的话，时长要大于 “自己定” 秒。
        if ([[(ALAsset *)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset *)evaluatedObject valueForProperty:ALAssetPropertyDuration]doubleValue];
           
            return duration > 0;   // 《-------- this 自己定
            
        }else{
            return  YES;
        }
    }];
    
    [self.delegate addPicker:picker];
    
    
}

/**
 * 得到选中的图片
 */
#pragma mark - ZYQAssetPickerController Delegate

-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    [self.scrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
   
    ///自己可以看看图片属性
//    NSLog(@"assets is %lu",(unsigned long)assets.count);
//    NSLog(@"你是什么类型的%@",assets);
    
    if (_array.count + assets.count > 9) {
        NSLog(@"图片数量超过9张，目前多出%lu张",(_array.count + assets.count -9));
        return;
    }

   
    for (int i =0; i< assets.count; i++) {
        
        ALAsset *asset = assets[i];
        ///获取到相册图片
        UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        [_array addObject:tempImg];
        
    }
    
    //重新布局
    [self initlizerScrollView:_array];
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}


/// 上传时将原始图片转化为NSData数据,写入沙盒

- (void)uploadImageWithData{
    

    /// 创建存放原始图的文件夹--->Documents
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //上传之前删除之前缓存的文件夹
    [fileManager removeItemAtPath:ImagePath error:nil];
    //再创建文件夹📂
    [fileManager createDirectoryAtPath:ImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    for (UIImage *image in _array) {
        
        k++;
        //压缩图片方法 ,还是按照自己的需求来，至于尺寸，你们自己弄吧，也挺简单的
        NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
        
        ///获取沙盒目录，图片名我用双拼打的 O(∩_∩)O~
        filePath=[ImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"ilqmmkytgl%d.png",k]];
        [imageData writeToFile:filePath atomically:NO];
        NSLog(@"写入沙盒\n%@",filePath);
        
        //按自己的需求保存图片路径和名称
        [_imgsArr addObject:[NSString stringWithFormat:@"image%d.png",k]];
        [_imagePath addObject:filePath];
        
    }
    
    
    
    //存起来
    NSUserDefaults *imgPath = [NSUserDefaults standardUserDefaults];
    [imgPath setObject:_imagePath forKey:@"imagePath"];
    [imgPath setObject:_imgsArr forKey:@"imageName"];
    [imgPath synchronize];
    
    
    ///上传完成，清空数组
    
    [_array removeAllObjects];
    [_imagePath removeAllObjects];
    [_imgsArr removeAllObjects];
    
    [self initlizerScrollView:_array];
    
    
    //上传后删除之前缓存的文件夹
//    [fileManager removeItemAtPath:ImagePath error:nil];
    
    NSLog(@"\n\n   上传成功。 \n\n");
    
}


#pragma mark - MKComposePhotosViewDelegate

///删除已选中图片并从新写入沙盒
-(void)MKComposePhotosView:(MKComposePhotosView *)MKComposePhotosView didSelectDeleBtnAtIndex:(NSInteger)Index{
    
    [_array removeObjectAtIndex:Index];
    
    [self initlizerScrollView:_array];
   
    ///先删除原来数组的路径和名称，防止多次添加存储

    NSLog(@"删除了第%ld张",(long)Index);

}

///图片浏览的 delegate 方法
-(void)MKComposePhotosView:(MKComposePhotosView *)MKComposePhotosView didSelectImageAtIndex:(NSInteger)Index{
    
    [XLPhotoBrowser showPhotoBrowserWithImages:_array currentImageIndex:Index];
    
}


#pragma mark - 上传操作 自己按需求来吧





////////////暂时隐藏上传
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        NSURL * URL = [NSURL URLWithString:@""];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:@"" forHTTPHeaderField:@""];
//        AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] init];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//        [request addValue:[NSString stringWithFormat:@"image%d.png",k] forHTTPHeaderField:@"imageName"];

//        NSData *imageData = [NSData dataWithContentsOfFile:图片路径];
//        //进行上传操作
//        NSURLSessionUploadTask *upLoadTask = [manager uploadTaskWithRequest:request fromData:imageData progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
//                                              {
//                                                  if (error) {
//
//                                                      [MBProgressHUD showError:@"请求失败"];
//                                                  }else{
//
//                                                      NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//
//                                                      NSLog(@"请求完成的结果是:%@",dic);
//                                                      //用户默认设置
//                                                      NSUserDefaults *imgLinkDefault = [NSUserDefaults standardUserDefaults];
//                                                      NSArray *aa = [[NSArray alloc] init];
//                                                      aa = [imgLinkDefault objectForKey:@"imgLink"];
//                                                      [aa arrayByAddingObject:[dic objectForKey:@"attachmentPath"]];
//                                                      [imgLinkDefault setObject:aa forKey:@"aa"];
//                                                      [imgLinkDefault synchronize];
//
//                                                  }
//                                              }];
//
//        //开始上传操作
//        [upLoadTask resume];
//    });






@end
