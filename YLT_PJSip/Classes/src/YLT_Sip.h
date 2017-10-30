//
//  YTL_Sip.h
//  SecretVoice
//
//  Created by YLT_Alex on 2017/10/25.
//  Copyright © 2017年 QTEC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLT_SipUser.h"
#import "YLT_SipSession.h"

@interface YLT_Sip : NSObject
/**
 当前用户
 */
@property (nonatomic, strong) YLT_SipUser *currentUser;

/**
 当前会话
 */
@property (nonatomic, strong) YLT_SipSession *currentSession;
/**
 是否静音
 */
@property (nonatomic, assign) BOOL mute;

+ (YLT_Sip *)sharedInstance;

/**
 注册Sip服务

 @param server 服务器域名
 @param username 用户名
 @param password 密码
 @param callback 回调
 @return 是否登录成功
 */
- (BOOL)registerServiceOnServer:(NSString *)server username:(NSString *)username password:(NSString *)password callback:(void(^)(BOOL success))callback;

/**
 自动登录
 */
- (void)autoLogin;

/**
 退出登录

 @return 是否退出成功
 */
- (BOOL)logout;

/**
 拨打电话

 @param destURI 目标URI
 */
- (void)makeCallTo:(NSString *)destURI;

/**
 应答
 */
- (void)answerCall;

/**
 挂断
 */
- (void)endCall;

/**
 保持活跃
 */
- (void)keepAlive;

@end
