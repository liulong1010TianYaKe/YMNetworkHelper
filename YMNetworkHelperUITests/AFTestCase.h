//
//  AFTestCase.h
//  YMNetworkHelper
//
//  Created by long on 4/12/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
@interface AFTestCase : XCTestCase
@property (nonatomic, strong,readonly) NSURL *baseURL;
@property (nonatomic, assign) NSTimeInterval networkTimeout;

- (void)waitForExpectationsWithCommonTimeoutUsingHandler:(XCWaitCompletionHandler)handler;
@end
