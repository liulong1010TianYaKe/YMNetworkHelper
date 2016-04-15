//
//  YMUtil.h
//  YMNetworkHelper
//
//  Created by long on 4/14/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

//UserDefault
#define kUserDefaultKey_CFBundleShortVersionString  @"kUserDefaultKey_CFBundleShortVersionString"   //版本号
#define kUserDefaultKey_KeyChar @"kUserDefaultKey_KeyChar"  //唯一标示


@interface YMUtil : NSObject


// Stand User Default
+ (void)addUserDefault:(NSString *)key value:(id)value;
+ (void)removeUserDefault:(NSString *)key;
+ (id)getUserDefaultValue:(NSString *)key;

// Push
+ (BOOL)currentPushSwitch;  //得到当前是否开启了推送
+ (void)changePushSwitch:(BOOL)isOpen;  //改变推送是否开启

//设备和应用
+ (NSString *)getAppstoreVersion; //获取当前应用的app store中的版本号
+ (NSString *)getAppKeyChar;   //获取唯一标识udid
@end
