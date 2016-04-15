//
//  YMUtil.m
//  YMNetworkHelper
//
//  Created by long on 4/14/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import "YMUtil.h"
#import "SSKeychain.h"
#import "NSString+Convert.h"

@implementation YMUtil


#pragma mark -----------------------
#pragma mark - Stands User Default

+ (void)addUserDefault:(NSString *)key value:(id)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeUserDefault:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getUserDefaultValue:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}


#pragma mark ----------------------
#pragma mark - Device and App

//获取当前应用的app store中的版本号
+ (NSString *)getAppstoreVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return [infoDic objectForKey:@"CFBundleShortVersionString"];
}

//获取唯一标识udid
+ (NSString *)getAppKeyChar
{
    NSString *openUDID = [YMUtil getUserDefaultValue:kUserDefaultKey_KeyChar];
    if (!openUDID) {
        
        
        [YMUtil addUserDefault:kUserDefaultKey_KeyChar value:openUDID];
    }
    
    static NSString *keyChar;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        keyChar = [YMUtil getUserDefaultValue:kUserDefaultKey_KeyChar];
        if (!keyChar) { //如果没有记录在userdefault里面,则从keychar获取
            keyChar = [SSKeychain passwordForService:@"com.keeds.KidBook"account:@"uuid"];
            
            if (keyChar == nil || [keyChar isEqualToString:@""]) {  //如果keychar没有，则创建
                CFUUIDRef uuid = CFUUIDCreate(NULL);
                assert(uuid != NULL);
                CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
                keyChar = [NSString stringWithFormat:@"%@", uuidStr];
                [SSKeychain setPassword: keyChar
                             forService:@"com.keeds.KidBook"account:@"uuid"];
            }
            
            //把keychar转换成10进制字符串
            NSArray *arraySplit = [keyChar componentsSeparatedByString:@"-"];
            if (arraySplit.count > 0) {
                NSString *decimalKeyChar = @"";
                for (NSString *hex in arraySplit) {
                    decimalKeyChar = [decimalKeyChar stringByAppendingString:[hex changeToDecimalFromHex]];
                }
                NSLog(@"打印出拼接后的十进制字符串:%@",decimalKeyChar);
                keyChar = decimalKeyChar;
            }
            
            [YMUtil addUserDefault:kUserDefaultKey_KeyChar value:keyChar];
        }
    });
    
    return keyChar;
}
@end
