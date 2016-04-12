//
//  YMNetworkHelperUITests.m
//  YMNetworkHelperUITests
//
//  Created by long on 4/12/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface YMNetworkHelperUITests : XCTestCase

@end

@implementation YMNetworkHelperUITests

//方法用于在测试前设置好要测试的方法
- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}
//tearDown则是在测试后将设置好的要测试的方法拆卸掉。
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//testExample顾名思义就是一个示例
//- (void)testExample {
//    XCTFail(@"No implemetaion for \%s\",__PRETTY_FUNCTION__);
//}



@end
