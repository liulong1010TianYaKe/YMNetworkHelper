//
//  NetworkHelp.h
//  YMNetworkHelper
//
//  Created by long on 4/14/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "NetworkResultModel.h"

//主站App的一些标示
#define kAppPlatform  @"4"
#define kAppMarket  @"23"
#define kAppSalt  @"ios123"


typedef enum{
    
    StatusUnknown           = -1, //未知网络
    StatusNotReachable      = 0,    //没有网络
    StatusReachableViaWWAN  = 1,    //手机自带网络
    StatusReachableViaWiFi  = 2     //wifi
    
}NetworkStatus;



@interface YMURLSessionTask : NSObject

@property (strong, nonatomic) NSURLSessionTask *task;
@property (copy, nonatomic) NSString *savePath;  /**< 如果是下载的文件的保存路径 */

- (id)initWithTask:(NSURLSessionTask *)task withDownloadSavePath:(NSString *)savePath;

- (void)clearOperation;    //清空网络请求
+ (void)clearOperation:(YMURLSessionTask *)operation;

@end

@interface NetworkHelp : NSObject

+ (instancetype)shareNetwork;

+ (NSDictionary *)getNetworkParams:(id)dict;


//check网络请求是否正确，是否需要提示
+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict;
+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict errorShowInView:(UIView *)view;
+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict showAlertView:(BOOL)isShow;
//+ (BOOL)checkDataFromNetwork:(NSDictionary *)dict withKyoRefreshControl:(KyoRefreshControl *)kyoRefreshControl;

// Post
- (YMURLSessionTask *)postNetwork:(NSDictionary *)params
                      serverAPIUrl:(NSString *)serverAPIUrl
                   completionBlock:(void (^)(NSDictionary *dict, NetworkResultModel *resultModel))completionBlock
                        errorBlock:(void (^)(NSError *error))errorBlock
                    finishedBlock:(void (^)(NSError *error))finishedBlock;


//upload photo
- (YMURLSessionTask *)uploadNetwork:(NSDictionary *)params
                        serverAPIUrl:(NSString *)serverAPIUrl
                          fileParams:(NSArray *)arrayFile
                        upProgressL:(void (^)(int64_t bytesProgress, int64_t totalBytesProgress))progress
                     completionBlock:(void (^)(NSDictionary *dict, NetworkResultModel *resultModel))completionBlock
                          errorBlock:(void (^)(NSError *error))errorBlock
                       finishedBlock:(void (^)(NSError *error))finishedBlock;

// downfile
- (YMURLSessionTask *)downFileNetwork:(NSString *)url
                                params:(NSDictionary *)params
                            saveToPath:(NSString *)savePath
                        curruntProcess:(void (^)(long long countByte, long long currentByte))process
                       completionBlock:(void (^)(NSDictionary *dict, NetworkResultModel *resultModel))completionBlock
                            errorBlock:(void (^)(NSError *error))errorBlock
                         finishedBlock:(void (^)(NSError *error))finishedBlock;

//cancel downfile and save data
- (void)cancelBySaveResumeData:(YMURLSessionTask *)kyoURLSessionTask;
@end
