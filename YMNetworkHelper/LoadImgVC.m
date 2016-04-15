//
//  LoadImgVC.m
//  YMNetworkHelper
//
//  Created by long on 4/14/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import "LoadImgVC.h"
//#import "UIKit+AFNetworking.h"
#import "AFAutoPurgingImageCache.h"
#import "AFImageDownloader.h"
#import "UIImageView+AFNetworking.h"
@interface LoadImgVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
- (IBAction)btnLoadImage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnImage;


@property (nonatomic, strong) AFAutoPurgingImageCache *cache;

@property (nonatomic, strong) NSURLRequest *pngRequest;
@property (nonatomic, strong) NSURLRequest *jpegRequest;
@property (nonatomic, strong) AFImageDownloader *downloader;



@end


@implementation LoadImgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cache = [[AFAutoPurgingImageCache alloc] initWithMemoryCapacity:100*1024*1024 preferredMemoryCapacity:60*1024*1024];
    
//    self.imgView.image = tempImage; http://img3.imgtn.bdimg.com/it/u=2135676455,8294854&fm=21&gp=0.jpg
    NSURL *url = [NSURL URLWithString:@"http://img3.imgtn.bdimg.com/it/u=2135676455,8294854&fm=21&gp=0.jpg"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSString *additionalIdentifier = @"filter";
    [self.cache imageforRequest:request withAdditionalIdentifier:additionalIdentifier];
    
     UIImage *cachedImage = [self.cache imageforRequest:request withAdditionalIdentifier:additionalIdentifier];
    
    [self testImageLoader];
 
    
}

- (void)testImageLoader{
    self.downloader = [[AFImageDownloader alloc] init];
    [[AFImageDownloader defaultURLCache] removeAllCachedResponses];
    [[[AFImageDownloader defaultInstance] imageCache] removeAllImages];
    NSURL *pngURL = [NSURL URLWithString:@"https://httpbin.org/image/png"];
    self.pngRequest = [NSURLRequest requestWithURL:pngURL];
    NSURL *jpegURL = [NSURL URLWithString:@"https://httpbin.org/image/jpeg"];
    self.jpegRequest = [NSURLRequest requestWithURL:jpegURL];
    
    
    [self.downloader downloadImageForURLRequest:self.pngRequest success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
        self.imgView.image = responseObject;
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
}

- (void)testImageCache{
    self.cache = [[AFAutoPurgingImageCache alloc] initWithMemoryCapacity:100*1024*1024 preferredMemoryCapacity:60*1024*1024];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"logo" ofType:@"png"];
    UIImage *tempImage = [UIImage imageWithContentsOfFile:path];
    //    self.imgView.image = tempImage; http://img3.imgtn.bdimg.com/it/u=2135676455,8294854&fm=21&gp=0.jpg
    
    NSString *identifier = @"logo";
    [self.cache addImage:tempImage withIdentifier:identifier];
    
    self.imgView.image = [self.cache imageWithIdentifier:identifier];
}

- (IBAction)btnLoadImage:(id)sender {
    
    self.imgView.image = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         NSString *URLIdentifier =  self.pngRequest.URL.absoluteString;
      
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"logo" ofType:@"png"];
        UIImage *tempImage = [UIImage imageWithContentsOfFile:path];
        //    self.imgView.image = tempImage; http://img3.imgtn.bdimg.com/it/u=2135676455,8294854&fm=21&gp=0.jpg
        
        NSString *identifier = @"logo";
        [self.cache addImage:tempImage withIdentifier:identifier];
        [self.imgView setImageWithURLRequest:self.pngRequest placeholderImage:[self.cache imageWithIdentifier:identifier] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            self.imgView.image = image;
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            
        }];
        
    });
    
}
@end
