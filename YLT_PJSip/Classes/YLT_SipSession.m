//
//  YLT_SipSession.m
//  SecretVoice
//
//  Created by YLT_Alex on 2017/10/26.
//  Copyright © 2017年 QTEC. All rights reserved.
//

#import "YLT_SipSession.h"

@implementation YLT_SipSession

/**
 清除数据
 */
- (void)clear {
    self.answer = NO;
    self.sessionType = SIP_SESSION_TYPE_NONE;
    self.contactId = @"";
    self.accountID = 0;
    self.name = @"";
    self.company = @"";
    self.section = @"";
    self.extra = @"";
    self.number = @"";
    self.key = @"";
    self.duration = 0;
}

@end
