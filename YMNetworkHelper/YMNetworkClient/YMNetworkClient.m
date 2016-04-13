//
//  YMNetworkClient.m
//  YMNetworkHelper
//
//  Created by long on 4/12/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import "YMNetworkClient.h"
#import "AFNetworking.h"
static NSString *const AFHttpNetAPIBaseURLString = @"http:www.hzins.com/";
@interface YMNetworkClient ()
@property (nonatomic, strong) AFHTTPSessionManager* httpSessionManager;
@property (nonatomic, strong)  AFURLSessionManager * urlSessionManager;
@end

@implementation YMNetworkClient



+ (instancetype)shareNetworkClient{
    
    static YMNetworkClient *_shareClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareClient = [[YMNetworkClient alloc] init];
        
         // 初始化HTTP Client的base url，此处为@"https://api.app.net/"
//        _shareClient.httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AFHttpNetAPIBaseURLString]];
        _shareClient.httpSessionManager = [AFHTTPSessionManager manager];
        
        //开启允许https模式   设置HTTP Client的安全策略为AFSSLPinningModeNone 默认
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        _shareClient.httpSessionManager.securityPolicy = securityPolicy;
    });
    return _shareClient;
}

- (void)testBaidu{
    NSURL *url = [NSURL URLWithString:@"http://www.hzins.com"];
//   [[self.httpSessionManager.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//       
//       if (error) {
//           NSLog(@"%@",error);
//           return;
//       }
//        NSLog(@"%@", response);
//   }] resume];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
//    self.httpSessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
//    [self.httpSessionManager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
//        return NSURLSessionResponseAllow;
//    }];
    
    [[self.httpSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
         NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        (Byte *)[responseObject bytes]
         userInfo[AFNetworkingTaskDidCompleteResponseSerializerKey] = self.httpSessionManager.responseSerializer;
               if (error) {
                   NSLog(@"%@",error);
                   return;
               }
        
                NSLog(@"%@", response);
    }] resume];
    

}

@end
