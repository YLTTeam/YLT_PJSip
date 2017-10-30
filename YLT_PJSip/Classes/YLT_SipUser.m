//
//  YLT_SipUser.m
//  SecretVoice
//
//  Created by YLT_Alex on 2017/10/26.
//  Copyright © 2017年 QTEC. All rights reserved.
//

#import "YLT_SipUser.h"
#import <YLT_BaseLib/YLT_BaseLib.h>

@implementation YLT_SipUser

/**
 清除用户信息
 */
- (void)clear {
    self.loginState = NO;
    self.username = @"";
    self.domain = @"";
    self.password = @"";
    self.accountId = 0;
}

/**
 校验用户信息的有效性
 
 @return 是否有效 YES:有效 NO:无效
 */
- (BOOL)check {
    return (self.username.YLT_CheckString && self.domain.YLT_CheckString && self.password.YLT_CheckString);
}

@end





