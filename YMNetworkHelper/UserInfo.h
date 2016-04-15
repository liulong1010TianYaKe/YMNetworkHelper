//
//  UserInfo.h
//  MainApp
//
//  Created by Kyo on 19/8/15.
//  Copyright (c) 2015 hzins. All rights reserved.
//

#import "BasicsUserInfo.h"


@interface UserInfo : BasicsUserInfo

@property (nonatomic, strong) NSString *session;  //用户登录后得到的seesion
@property (nonatomic, strong) NSString *loginName; //－－－新用户这里存得其实是手机号
@property (nonatomic, strong) NSString *loginPassWord;  //用户登录输入的密码
@property (nonatomic, assign) BOOL authEmail;
@property (nonatomic, assign) BOOL authMobile;
@property (nonatomic, strong) NSString * mobile;
@property (nonatomic, assign) NSInteger bigRegisteredSource;
@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * createTime;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * fullName;
@property (nonatomic, strong) NSObject * iP;
@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) NSInteger isActive;
@property (nonatomic, assign) BOOL isLock;
@property (nonatomic, strong) NSString * lastLoginTime;
@property (nonatomic, assign) NSInteger loginCount;

@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) NSString * previousTime;
@property (nonatomic, assign) NSInteger registeredSource;
@property (nonatomic, strong) NSString * registeredSourceKey;
@property (nonatomic, assign) NSInteger safeLevel;
@property (nonatomic, strong) NSObject * saltKey;
@property (nonatomic, strong) NSString * weiXinRegisteredSourceKey;



+ (UserInfo *)sharedUserInfo;
- (BOOL)isLogined;  //是否已经登录
- (void)logout; //退出登录
- (BOOL)isBindingUserPhone; //是否绑定了手机号
- (BOOL)isBindingUserMail;  // 是否绑定了邮箱

@end
