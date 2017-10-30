//
//  YLT_SipSession.h
//  SecretVoice
//
//  Created by YLT_Alex on 2017/10/26.
//  Copyright © 2017年 QTEC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pjsua.h>
#import <YLT_BaseLib/YLT_BaseLib.h>

typedef NS_ENUM(NSUInteger, SipSessionType) {
    SIP_SESSION_TYPE_CALL = 100,//拨打方
    SIP_SESSION_TYPE_ANSWER,//接收方
    SIP_SESSION_TYPE_NONE,//未知状态
};

/**
 当前会话对象
 */
@interface YLT_SipSession : YLT_BaseModel

/**
 通讯录的对象ID
 */
@property (nonatomic, strong) NSString *contactId;

/**
 通话ID
 */
@property (nonatomic, assign) pjsua_acc_id accountID;

/**
 会话名字
 */
@property (nonatomic, strong) NSString *name;

/**
 会话的公司
 */
@property (nonatomic, strong) NSString *company;

/**
 会话的部门
 */
@property (nonatomic, strong) NSString *section;

/**
 会话的备注
 */
@property (nonatomic, strong) NSString *extra;

/**
 会话的号码
 */
@property (nonatomic, strong) NSString *number;

/**
 呼出还是呼入
 */
@property (nonatomic, assign) SipSessionType sessionType;

/**
 是否接听
 */
@property (nonatomic, assign) BOOL answer;

/**
 会话的加密的key
 */
@property (nonatomic, strong) NSString *key;

/**
 通话的时间
 */
@property (nonatomic, assign) NSUInteger duration;

/**
 记录上一次的通话状态变化
 */
@property (nonatomic, assign) NSInteger state;

/**
 清除数据
 */
- (void)clear;

@end
