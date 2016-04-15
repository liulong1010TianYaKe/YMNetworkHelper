//
//  LoginVC.m
//  YMNetworkHelper
//
//  Created by long on 4/15/16.
//  Copyright © 2016 JingKeCompany. All rights reserved.
//

#import "LoginVC.h"



@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPwd;

@property (strong, nonatomic) YMURLSessionTask *loginOperation;

@end
@implementation LoginVC


- (IBAction)btnLogin:(id)sender {
    [self networkloginWithLoginName:self.textFieldName.text andPassWord:self.textFieldPwd.text];
}


#pragma mark ---------------------
#pragma mark - Methods

-(void)networkloginWithLoginName:(NSString *)name andPassWord:(NSString *)passWord {
    NSDictionary *dict = @{@"AppId":kAppPlatform,
                           @"loginName":name,
                           @"password":passWord};
    
    [YMURLSessionTask clearOperation:self.loginOperation];

    
    self.loginOperation = [[NetworkHelp shareNetwork] postNetwork:[NetworkHelp getNetworkParams:dict] serverAPIUrl:@"http://api.m.hzins.com/Home/Login" completionBlock:^(NSDictionary *dict, NetworkResultModel *resultModel) {
//        if ([NetworkSessionHelp checkDataFromNetwork:dict errorShowInView:self.view]) {
//            [UserInfo sharedUserInfo].session = resultModel.Data[@"Session"];
//            [[UserInfo sharedUserInfo] setKeyValues:resultModel.Data[@"UserInfo"]];
//            [UserInfo sharedUserInfo].realLoginName = name;
//            [UserInfo sharedUserInfo].loginPassWord = passWord;
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_LoginSuccess object:nil];
//            
//            if (self.loginSucessBlock) {
//                [self dismissViewControllerAnimated:YES completion:^{
//                    [KyoUtil rootViewController].loginNavigationViewController = nil;
//                    self.loginSucessBlock();
//                }];
//            } else {
//                [self btnBackTouchIn:nil];
//            }
//        } else {
//            self.errorPWCount++;
//        }
    } errorBlock:^(NSError *error) {
//        [self showMessageHUD:kTipsNetworkError withTimeInterval:kShowMessageTime];
    } finishedBlock:^(NSError *error) {
//        [self hideLoadingHUD];
    }];
}
@end
