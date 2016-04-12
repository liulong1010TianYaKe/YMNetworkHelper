//
//  AFTestCase.m
//  YMNetworkHelper
//
//  Created by long on 4/12/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import "AFTestCase.h"
NSString * const AFNetworkingTestsBaseURLString = @"https://httpbin.org/";

// http://www.cocoachina.com/cms/wap.php?action=article&id=10052 xcode 6 异步测试
@implementation AFTestCase
- (void)setUp {
    [super setUp];
    self.networkTimeout = 20.0;
}

- (void)tearDown {
    [super tearDown];
}
- (NSURL *)baseURL {
    return [NSURL URLWithString:AFNetworkingTestsBaseURLString];
}
- (void)waitForExpectationsWithCommonTimeoutUsingHandler:(XCWaitCompletionHandler)handler{
    [self waitForExpectationsWithTimeout:self.networkTimeout handler:handler];
}
@end
