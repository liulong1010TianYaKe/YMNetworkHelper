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
        _shareClient.httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AFHttpNetAPIBaseURLString]];
        
        //开启允许https模式   设置HTTP Client的安全策略为AFSSLPinningModeNone 默认
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        _shareClient.httpSessionManager.securityPolicy = securityPolicy;
    });
    return _shareClient;
}

@end
