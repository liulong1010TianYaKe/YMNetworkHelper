//
//  NetworkHelp.m
//  YMNetworkHelper
//
//  Created by long on 4/14/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import "NetworkHelp.h"
#import "YMUtil.h"
#import "NSDate+Convert.h"
#import "NSString+MD5.h"
#import "MBProgressHUD+Kyo.h"
#import "NSProgress+KyoDownload.h"



@implementation YMURLSessionTask

#pragma mark --------------------
#pragma mark - CycLife

- (id)initWithTask:(NSURLSessionTask *)task withDownloadSavePath:(NSString *)savePath{
    self = [super init];
    
    if (self) {
        self.task = task;
        self.savePath = savePath;
    }
    
    return self;
}

#pragma mark --------------------
#pragma mark - Methods

//清空网络请求
- (void)clearOperation {
    if (self && self.task) {
        if ([self.task respondsToSelector:@selector(cancelByProducingResumeData:)]) {
            [[NetworkHelp shareNetwork] cancelBySaveResumeData:self];
        } else {
            [self.task cancel];
        }
    }
}

+ (void)clearOperation:(YMURLSessionTask *)operation {
    if (operation && operation.task) {
        if ([operation.task respondsToSelector:@selector(cancelByProducingResumeData:)]) {
            [[NetworkHelp shareNetwork] cancelBySaveResumeData:operation];
        } else {
            [operation.task cancel];
        }
    }
    
    operation = nil;
}

@end


@interface NetworkHelp (){
    NSMutableDictionary *_dictProgress;
}

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

- (void)insertDownloadUrl:(NSString *)url withProgress:(NSProgress *)progress withCurrentProcess:(void (^)(long long countByte, long long currentByte))currentProcess; //存储下载需要的progress
- (void)deleteDownloadProgress:(NSString *)url; //删除下载需要的progress

+ (void)thePopUpDialogSecurityTips:(NSString *)tip;    //多点登录被破下线提示
+ (void)reLoginWithTips:(NSString *)msg;    /**< 需要重新登录被迫下线提示（大多数是session过期） */

- (void)loginSuccessNotification:(NSNotification *)notification;
@end

@implementation NetworkHelp

#pragma mark -------------------
#pragma mark - CycLife
+ (instancetype)shareNetwork{
    
    static NetworkHelp *_shareNetwork;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareNetwork = [[NetworkHelp alloc] init];
        _shareNetwork.httpSessionManager = [AFHTTPSessionManager manager];

        _shareNetwork.httpSessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        _shareNetwork.httpSessionManager.requestSerializer.timeoutInterval=10;
        _shareNetwork.httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                  @"text/html",
                                                                                  @"text/json",
                                                                                  @"text/plain",
                                                                                  @"text/javascript",
                                                                                  @"text/xml",
                                                                                  @"image/*"]];
        
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        _shareNetwork.httpSessionManager.securityPolicy = securityPolicy;
    });
    
    return _shareNetwork;
}

#pragma mark --------------------
#pragma mark - Params

+ (NSDictionary *)getNetworkParams:(id)dict{
    
    if (!dict || dict == [NSNull null]) {
        dict = [NSMutableDictionary dictionary];
    }
    
    if (![dict isKindOfClass:[NSMutableDictionary class]] && ![dict isKindOfClass:[NSString class]]) {
        dict = [dict mutableCopy];
    }
    
    
    //统计参数
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        [dict setObject:[YMUtil getAppstoreVersion] forKey:@"VersionStr"];
        [dict setObject:[YMUtil getAppKeyChar] forKey:@"IDCode"];
    }
    

    //把字典拼接成JSON字符串
    NSString *args = @"{}";
    if (dict != nil && [dict isKindOfClass:[NSMutableDictionary class]]) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *tempArgs = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        args = tempArgs;
    } else if (dict && [dict isKindOfClass:[NSString class]]) {
        args = dict;
    }
    
    //添加公共参数
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    [dictParams setObject:kAppPlatform forKey:@"appType"];
    [dictParams setObject:[[NSDate date] strLongDate] forKey:@"timestamp"];
    [dictParams setObject:[UserInfo sharedUserInfo].session ? : @"12345" forKey:@"session"];
    [dictParams setObject:args forKey:@"args"];
    
    
    //对字典中的key进行排序，并拼接串
    NSString *strEncryption = @"";
    NSArray *keys = [[dictParams allKeys]sortedArrayUsingSelector:@selector(compare:)];
    for(NSInteger i = 0;i < dictParams.allKeys.count; i++) {
        NSString *strFromat = [NSString stringWithFormat:@"%@%@",keys[i],[dictParams valueForKey:keys[i]]];
        strEncryption = [strEncryption stringByAppendingString:strFromat];
    }
    
    //对拼接后得到的串进行加密处理
    strEncryption = [[[kAppSalt stringByAppendingString:strEncryption] md5] uppercaseString];
    [dictParams setObject:strEncryption forKey:@"sign"];
    
    return dictParams;
}
#pragma mark --------------------
#pragma mark - Check

+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict
{
    return [NetworkHelp checkDataFromNetwork:dict showAlertView:YES];
}

+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict errorShowInView:(UIView *)view
{
    @try {
        id result = (dict && [dict isKindOfClass:[NSDictionary class]]) ? [dict objectForKey:kNetworkKeyState] : nil;
        if (result && result != [NSNull null] && [result intValue] == 0) {
            return YES;
        }else{
            id errorMsg = [dict objectForKey:kNetworkKeyMsg];
            if (!errorMsg || errorMsg == [NSNull null]) {
                errorMsg = @"操作失败，请稍后重试.";
            }
            
            [MBProgressHUD showMessageHUD:errorMsg withTimeInterval:kShowMessageTime inView:view];
            
            return NO;
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    
}

+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict showAlertView:(BOOL)isShow
{
    id result = (dict && [dict isKindOfClass:[NSDictionary class]]) ? [dict objectForKey:kNetworkKeyState] : nil;
    if (result && result != [NSNull null] && [result intValue] == 0) {
        return YES;
    }else{
        if (isShow) {
            id errorMsg = [dict objectForKey:kNetworkKeyMsg];
            if (!errorMsg || errorMsg == [NSNull null]) {
                errorMsg = @"操作失败，请稍后重试.";
            }
            
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alertView show];
        }
        return NO;
    }
}

//+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict withKyoRefreshControl:(KyoRefreshControl *)kyoRefreshControl {
//    kyoRefreshControl.errorMsg = kKyoRefreshControlErrorMsgDefault;
//    kyoRefreshControl.errorState = nil;
//    id result = (dict && [dict isKindOfClass:[NSDictionary class]]) ? [dict objectForKey:kNetworkKeyState] : nil;
//    if (result && result != [NSNull null] && [result intValue] == 0) {
//        return YES;
//    }else{
//        id errorMsg = [dict objectForKey:kNetworkKeyMsg];
//        if (!errorMsg || errorMsg == [NSNull null]) {
//            errorMsg = @"操作失败，请稍后重试.";
//        }
//        kyoRefreshControl.errorMsg = errorMsg;
//        kyoRefreshControl.errorState = [dict objectForKey:kNetworkKeyState] ? [[dict objectForKey:kNetworkKeyState] stringValue] : nil;
//        
//        return NO;
//    }
//}
#pragma mark --------------------
#pragma mark - Network
//Post
- (YMURLSessionTask *)postNetwork:(NSDictionary *)params serverAPIUrl:(NSString *)serverAPIUrl completionBlock:(void (^)(NSDictionary *, NetworkResultModel *))completionBlock errorBlock:(void (^)(NSError *))errorBlock finishedBlock:(void (^)(NSError *))finishedBlock {
    

    NSURLSessionDataTask * urlSessionDataTask = [[NetworkHelp shareNetwork].httpSessionManager POST:serverAPIUrl parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%lld",uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject );
        NetworkResultModel *result = nil;
        @try {
            result = [[NetworkResultModel alloc] init];
        } @catch (NSException *exception) {
            result = [[NetworkResultModel alloc] init];
        } @finally {
            completionBlock(responseObject, result);
            finishedBlock(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock && error.code != NSURLErrorCancelled) { //有出错block且出错原因不是cancel，则调用
            errorBlock(error);
        }
        finishedBlock(error);
    }];
    
    YMURLSessionTask *task = [[YMURLSessionTask alloc] initWithTask:urlSessionDataTask withDownloadSavePath:nil];
    return task;
}



- (YMURLSessionTask *)uploadNetwork:(NSDictionary *)params serverAPIUrl:(NSString *)serverAPIUrl fileParams:(NSArray *)arrayFile upProgressL:(void (^)(int64_t, int64_t))progress completionBlock:(void (^)(NSDictionary *, NetworkResultModel *))completionBlock errorBlock:(void (^)(NSError *))errorBlock finishedBlock:(void (^)(NSError *))finishedBlock{
        NSURLSessionDataTask * urlSessionDataTask = [[NetworkHelp shareNetwork].httpSessionManager POST:serverAPIUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
//            //压缩图片
//            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
//            
//            NSString *imageFileName = filename;
//            if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
//                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                formatter.dateFormat = @"yyyyMMddHHmmss";
//                NSString *str = [formatter stringFromDate:[NSDate date]];
//                imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
//            }
//            
//            // 上传图片，以文件流的格式
//            [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
            
            
            for (NSDictionary *fileDict in arrayFile) {
                for (NSString *key in fileDict.allKeys) {
                    id value = [fileDict objectForKey:key];
                    [formData appendPartWithFileData:value name:key fileName:@"image.png" mimeType:@"application/octet-stream"];
                }
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
            if (progress) {
                progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    
    YMURLSessionTask *task = [[YMURLSessionTask alloc] initWithTask:urlSessionDataTask withDownloadSavePath:nil];
    return task;
}

- (YMURLSessionTask *)downFileNetwork:(NSString *)url params:(NSDictionary *)params saveToPath:(NSString *)savePath curruntProcess:(void (^)(long long, long long))process completionBlock:(void (^)(NSDictionary *, NetworkResultModel *))completionBlock errorBlock:(void (^)(NSError *))errorBlock finishedBlock:(void (^)(NSError *))finishedBlock{
    
    [self deleteDownloadProgress:url];
    NSProgress *progressByte = nil;
    
    // 获得临时文件的路径
    NSString  *tempDoucment = NSTemporaryDirectory();
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSRange lastCharRange = [savePath rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
    NSString *tempFilePath = [NSString stringWithFormat:@"%@%@.temp",
                              tempDoucment,
                              [savePath substringFromIndex:lastCharRange.location + 1]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
     if ([fileManager fileExistsAtPath:tempFilePath]) {
//        KyoLog(@"继续下载");
//        NSData *resumeData = [NSData dataWithContentsOfFile:tempFilePath];
//        [[NetworkHelp shareNetwork].httpSessionManager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
//            
//        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//            
//        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//            
//        }];
     }
    return nil;
}

#pragma mark -------------------
#pragma mark - Methods
//存储下载需要的progress
- (void)insertDownloadUrl:(NSString *)url withProgress:(NSProgress *)progress withCurrentProcess:(void (^)(long long countByte, long long currentByte))currentProcess {
    _dictProgress = _dictProgress ? _dictProgress : [NSMutableDictionary dictionary];
    if (progress) {
        progress.kyo_url = url;
        progress.kyo_progressBlock = currentProcess;
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        [_dictProgress setObject:progress forKey:url];
    }
}

//删除下载需要的progress
- (void)deleteDownloadProgress:(NSString *)url {
    _dictProgress = _dictProgress ? _dictProgress : [NSMutableDictionary dictionary];
    if ([_dictProgress objectForKey:url]) {
        NSProgress *progressByte = [_dictProgress objectForKey:url];
        [progressByte removeObserver:self forKeyPath:@"fractionCompleted"];
        progressByte.kyo_progressBlock = nil;
        [_dictProgress removeObjectForKey:url];
        progressByte = nil;
    }
}
#pragma mark --------------------
#pragma mark - UITableViewDelegate, UITableViewSourceData

#pragma mark ------------------
#pragma mark - KyoRefreshControlDelegate

#pragma mark --------------------
#pragma mark - NSNotification

#pragma mark --------------------
#pragma mark - KVO/KVC

@end
