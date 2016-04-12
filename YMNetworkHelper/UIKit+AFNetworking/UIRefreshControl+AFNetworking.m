// UIRefreshControl+AFNetworking.m
//
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIRefreshControl+AFNetworking.h"
#import <objc/runtime.h>

#if TARGET_OS_IOS

#import "AFURLSessionManager.h"

@interface AFRefreshControlNotificationObserver : NSObject

@property (readonly, nonatomic, weak) UIRefreshControl *refreshControl;
- (instancetype)initWithActivityRefreshControl:(UIRefreshControl *)refreshControl;

- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task;

@end

@implementation UIRefreshControl (AFNetworking)

/**
 因为category是运行期决定的，所以当你在此处添加实例变量的话，那么这个类的内存空间就要变了，而类的内存空间是在编译期就确定了。这里你可以添加属性成员，
 但是得自己实现getter和setter方法,可以用objc_getAssociatedObject和objc_setAssociatedObject方法来绑定一个实例变量
 
 */
- (AFRefreshControlNotificationObserver *)af_notificationObserver {
    //使用的是objc_getAssociatedObject和objc_setAssociatedObject方法来绑定一个实例变量
    AFRefreshControlNotificationObserver *notificationObserver = objc_getAssociatedObject(self, @selector(af_notificationObserver));
    if (notificationObserver == nil) {
        notificationObserver = [[AFRefreshControlNotificationObserver alloc] initWithActivityRefreshControl:self];
        objc_setAssociatedObject(self, @selector(af_notificationObserver), notificationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return notificationObserver;
}

- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task {
    [[self af_notificationObserver] setRefreshingWithStateOfTask:task];
}

@end

@implementation AFRefreshControlNotificationObserver

- (instancetype)initWithActivityRefreshControl:(UIRefreshControl *)refreshControl
{
    self = [super init];
    if (self) {
        // 仅仅把refreshControl传过来，后续要调用refreshControl本身的几个方法
        // 所以注意此处refreshControl定义的是weak属性
        _refreshControl = refreshControl;
    }
    return self;
}

- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //1. 先将之前的observe移除
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidSuspendNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidCompleteNotification object:nil];

    if (task) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreceiver-is-weak"
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        // 2 如果当前task状态为NSURLSessionTaskStateRunning，先beginRefreshing，然后添加几个observer:
        if (task.state == NSURLSessionTaskStateRunning) {
            [self.refreshControl beginRefreshing];

            //  AFNetworkingTaskDidResumeNotification（任务继续，所以调用beginRefreshing）
            [notificationCenter addObserver:self selector:@selector(af_beginRefreshing) name:AFNetworkingTaskDidResumeNotification object:task];
            // AFNetworkingTaskDidCompleteNotification（任务完成，所以调用endRefreshing）
            [notificationCenter addObserver:self selector:@selector(af_endRefreshing) name:AFNetworkingTaskDidCompleteNotification object:task];
            // AFNetworkingTaskDidSuspendNotification（任务挂起，所以调用endRefreshing）
            [notificationCenter addObserver:self selector:@selector(af_endRefreshing) name:AFNetworkingTaskDidSuspendNotification object:task];
        } else {
            [self.refreshControl endRefreshing];
        }
#pragma clang diagnostic pop
    }
}

#pragma mark -

- (void)af_beginRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreceiver-is-weak"
        [self.refreshControl beginRefreshing];
#pragma clang diagnostic pop
    });
}

- (void)af_endRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreceiver-is-weak"
        [self.refreshControl endRefreshing];
#pragma clang diagnostic pop
    });
}

#pragma mark -

- (void)dealloc {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidSuspendNotification object:nil];
}

@end

#endif
