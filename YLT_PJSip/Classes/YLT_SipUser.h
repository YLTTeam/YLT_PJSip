//
//  YLT_SipUser.h
//  SecretVoice
//
//  Created by YLT_Alex on 2017/10/26.
//  Copyright © 2017年 QTEC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YLT_BaseLib/YLT_BaseLib.h>
#import <openssl/evp.h>
#import <pjsua.h>

@interface YLT_SipUser : YLT_BaseModel

/**
 登录状态 是否登录成功
 */
@property (nonatomic, assign) BOOL loginState;

/**
 服务器域名
 */
@property (nonatomic, strong) NSString *domain;

/**
 用户名
 */
@property (nonatomic, strong) NSString *username;

/**
 密码
 */
@property (nonatomic, strong) NSString *password;

/**
 通话的ID
 */
@property (nonatomic, assign) pjsua_acc_id accountId;

/**
 清除用户信息
 */
- (void)clear;

/**
 校验用户信息的有效性

 @return 是否有效 YES:有效 NO:无效
 */
- (BOOL)check;

@end



