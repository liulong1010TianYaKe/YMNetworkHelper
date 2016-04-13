//
//  ViewController.m
//  YMNetworkHelper
//
//  Created by Alen on 16/4/7.
//  Copyright © 2016年 JingKeCompany. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "YMNetworkClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[YMNetworkClient shareNetworkClient] testBaidu];
    
// [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
 简述一下：Multipart是HTTP协议为web表单新增的上传文件的协议，协议文档是rfc1867，它基于HTTP的POST方法，数据同样是放在body上，跟普通POST方法的区别是数据不是key=value形式，key=value形式难以表示文件实体，为此Multipart协议添加了分隔符
 
 --${bound} // 该bound表示pdf的文件名
 Content-Disposition: form-data; name="Filename"
 
 HTTP.pdf
 --${bound} // 该bound表示pdf的文件内容
 Content-Disposition: form-data; name="file000"; filename="HTTP协议详解.pdf"
 Content-Type: application/octet-stream
 
 %PDF-1.5
 file content
 %%EOF
 
 --${bound} // 该bound表示字符串
 Content-Disposition: form-data; name="Upload"
 
 Submit Query
 --${bound}—// 表示body结束了
 
 */
- (void)testAFNMulipart{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"postURLString" parameters:@{@"Filename":@"HTTP.pdf"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        [formData appendPartWithFileData:[pdf文件具体内容(NSData *)]
//                                    name:@"file000"
//                                fileName:@"HTTP协议详解.pdf"
//                                mimeType:@"application/octet-stream"];
//        [formData appendPartWithFormData:[@"Submit Query" dataUsingEncoding:NSUTF8StringEncoding]
//                                    name:@"Upload"];
    }  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



@end
