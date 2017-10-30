//
//  YTL_Sip.m
//  SecretVoice
//
//  Created by YLT_Alex on 2017/10/25.
//  Copyright © 2017年 QTEC. All rights reserved.
//

#import "YLT_Sip.h"
#import <YLT_BaseLib/YLT_BaseMacro.h>
#import <pjsua.h>
#import <openssl/evp.h>
#import "sip_types.h"
#import <ReactiveObjC/ReactiveObjC.h>

#define THIS_FILE "YLT_Sip.m"

const size_t MAX_SIP_ID_LENGTH = 50;
const size_t MAX_SIP_REG_URI_LENGTH = 50;

static int decrypt_aes(unsigned char* input, unsigned int input_len,
                       unsigned char* output,  unsigned int outbuf_len,
                       unsigned char* key, unsigned char *iv, int padding);

static int encrypt_aes(unsigned char* input, unsigned int input_len,
                       unsigned char* output,  unsigned int outbuf_len,
                       unsigned char* key, unsigned char *iv, int padding);

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);
static void on_call_state(pjsua_call_id call_id, pjsip_event *e);
static void on_call_media_state(pjsua_call_id call_id);
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info);
static void error_exit(const char *title, pj_status_t status);
static void on_call_sdp_created(pjsua_call_id call_id,
                                pjmedia_sdp_session *sdp,
                                pj_pool_t *pool,
                                const pjmedia_sdp_session *rem_sdp);

@interface YLT_Sip () {
    pjsua_acc_id _acc_id;
    pjsua_call_id incoming_call_id;
}

@property (nonatomic, copy) void(^registerCallback)(BOOL success);

@end

@implementation YLT_Sip

static YLT_Sip *sipShareData = nil;
+ (YLT_Sip *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sipShareData = [[self alloc] init];
    });
    return sipShareData;
}

/**
 注册Sip服务
 
 @param server 服务器域名
 @param username 用户名
 @param password 密码
 @param callback 回调
 @return 是否登录成功
 */
- (BOOL)registerServiceOnServer:(NSString *)server
                       username:(NSString *)username
                       password:(NSString *)password
                       callback:(void(^)(BOOL success))callback {
    self.registerCallback = callback;
    pj_status_t status;
    //注册线程
    if (!pj_thread_is_registered()) {
        pj_thread_desc desc;
        pj_thread_t *thread;
        status = pj_thread_register(NULL, desc, &thread);
        if (status != PJ_SUCCESS) {
            YLT_LogError(@"线程注册失败");
        }
    }
    if (self.currentUser.loginState) {
        [self logout];
    }
    status = pjsua_destroy();
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"信息清除失败");
    }
    status = pjsua_create();
    if (status != PJ_SUCCESS) {
        error_exit("pjsua 创建失败", status);
    }
    //初始化 pjsua
    pjsua_config cfg;
    pjsua_config_default(&cfg);
    cfg.cb.on_incoming_call = &on_incoming_call;//电话进来的回调
    cfg.cb.on_call_media_state = &on_call_media_state;//
    cfg.cb.on_call_state = &on_call_state;
    cfg.cb.on_reg_state2 = &on_reg_state2;
    cfg.cb.on_call_sdp_created = &on_call_sdp_created;

    pjsua_logging_config log_cfg;
    pjsua_logging_config_default(&log_cfg);
    log_cfg.console_level = 4;
    
    pjsua_media_config media_cfg;
    pjsua_media_config_default(&media_cfg);
    
    status = pjsua_init(&cfg, &log_cfg, &media_cfg);
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"初始化失败");
        return NO;
    }
    
    //添加 UDP 协议支持
    pjsua_transport_config udp_cfg;
    pjsua_transport_config_default(&udp_cfg);
    udp_cfg.port = 5060;
    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &udp_cfg, NULL);
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"UDP创建失败");
        return NO;
    }
    
    pjsua_transport_config tcp_cfg;
    pjsua_transport_config_default(&tcp_cfg);
    tcp_cfg.port = 5060;
    status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &tcp_cfg, NULL);
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"创建TCP传输失败");
        return NO;
    }
    
    //启动 pjsua
    // 启动pjsua
    status = pjsua_start();
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"启动组件失败");
        return NO;
    }
    //配置账号
    pjsua_acc_config acc_cfg;
    pjsua_acc_config_default(&acc_cfg);
    // Account ID
    char sipId[MAX_SIP_ID_LENGTH];
    acc_cfg.id = pj_str(sipId);
    // Reg URI
    char regUri[MAX_SIP_REG_URI_LENGTH];
    acc_cfg.reg_uri = pj_str(regUri);
    // Account cred info
    acc_cfg.cred_count = 1;
    acc_cfg.cred_info[0].scheme = pj_str("digest");
    acc_cfg.cred_info[0].realm = pj_str("*");
    acc_cfg.cred_info[0].username = pj_str((char *)[username UTF8String]);
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = pj_str((char *)[password UTF8String]);
    status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &_acc_id);
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"添加创建账户失败");
        return NO;
    }
    self.currentUser.username = username;
    self.currentUser.password = password;
    self.currentUser.domain = server;
    [self.currentUser save];
    return YES;
}

/**
 自动登录
 */
- (void)autoLogin {
    [self.currentSession clear];
    self.currentUser.loginState = NO;
    if ([self.currentUser read] && self.currentUser.check) {//读取上次登录的用户数据
        self.currentUser.loginState = NO;
        @weakify(self);
        [self registerServiceOnServer:self.currentUser.domain username:self.currentUser.username password:self.currentUser.password callback:^(BOOL success) {
            @strongify(self);
            self.currentUser.loginState = YES;
        }];
    }
}

/**
 退出登录
 */
- (BOOL)logout {
    if (pjsua_acc_is_valid(_acc_id)) {
        pj_status_t status = pjsua_acc_del(_acc_id);
        if (status != PJ_SUCCESS) {
            error_exit("退出失败", status);
            return NO;
        }
        return YES;
    }
    return YES;
}

/**
 拨打电话
 
 @param destURI 目标URI
 */
- (void)makeCallTo:(NSString *)destURI {
    pj_str_t uri = pj_str((char *)[destURI UTF8String]);
    pj_status_t status = pjsua_call_make_call(_acc_id, &uri, 0, NULL, NULL, NULL);
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"呼叫失败");
    }
}

/**
 应答
 */
- (void)answerCall {
    pj_status_t status = pjsua_call_answer(incoming_call_id, 200, NULL, NULL);
    if (status != PJ_SUCCESS) {
        YLT_LogError(@"应答失败");
    }
}

/**
 挂断
 */
- (void)endCall {
    pjsua_call_hangup_all();
}

/**
 保持活跃
 */
- (void)keepAlive {
    if (!pj_thread_is_registered()) {
        static pj_thread_desc desc;
        static pj_thread_t *thread;
        pj_thread_register("PJ_MAIN_THREAD", desc, &thread);
    }
    pj_thread_sleep(5000);
}

#pragma mark - lazy
- (YLT_SipUser *)currentUser {
    if (!_currentUser) {
        _currentUser = [[YLT_SipUser alloc] init];
    }
    return _currentUser;
}

- (YLT_SipSession *)currentSession {
    if (!_currentSession) {
        _currentSession = [[YLT_SipSession alloc] init];
    }
    return _currentSession;
}

- (void)setMute:(BOOL)mute {
    if (mute) {//设置静音
        _mute = ((pjsua_conf_adjust_rx_level(0, 1) == PJ_SUCCESS) && (pjsua_conf_adjust_tx_level(0, 0) == PJ_SUCCESS));
    } else {
        _mute = !((pjsua_conf_adjust_rx_level(0, 1) == PJ_SUCCESS) && (pjsua_conf_adjust_tx_level(0, 1) == PJ_SUCCESS));
    }
}

@end

#pragma mark - c method
/* 解密数据 */
static int decrypt_aes(unsigned char* input, unsigned int input_len,
                       unsigned char* output,  unsigned int outbuf_len,
                       unsigned char* key, unsigned char *iv, int padding) {
    int outlen, finallen, ret;
    EVP_CIPHER_CTX ctx;
    EVP_CIPHER_CTX_init(&ctx);
    EVP_DecryptInit(&ctx, EVP_aes_128_cbc(), key, iv);
    if (padding == 0)
        EVP_CIPHER_CTX_set_padding(&ctx, padding);
    if (!(ret = EVP_DecryptUpdate(&ctx, output, &outlen, input, input_len))) {
        return 0;
    }
    if (!(ret = EVP_DecryptFinal(&ctx, output + outlen, &finallen))) {
        return 0;
    }
    EVP_CIPHER_CTX_cleanup(&ctx);
    return outlen + finallen;
}

/* 加密数据 */
static int encrypt_aes(unsigned char* input, unsigned int input_len,
                       unsigned char* output,  unsigned int outbuf_len,
                       unsigned char* key, unsigned char *iv, int padding) {
    int outlen, finallen;
    EVP_CIPHER_CTX ctx;
    EVP_CIPHER_CTX_init(&ctx);
    EVP_EncryptInit(&ctx, EVP_aes_128_cbc(), key, iv);
    if (padding == 0)
        EVP_CIPHER_CTX_set_padding(&ctx, padding);
    if (!EVP_EncryptUpdate(&ctx, output, &outlen, input, input_len)) {
        return 0;
    }
    if (!EVP_EncryptFinal(&ctx, output + outlen, &finallen)) {
        return 0;
    }
    EVP_CIPHER_CTX_cleanup(&ctx);
    return outlen + finallen;
}

/* 注册状态改变的回调 */
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info) {
    switch (info->cbparam->code) {
        case 200://注册成功
            [YLT_Sip sharedInstance].currentUser.loginState = YES;
            [YLT_Sip sharedInstance].registerCallback(YES);
            break;
        case 401://注册失败
            [YLT_Sip sharedInstance].currentUser.loginState = NO;
            [YLT_Sip sharedInstance].registerCallback(NO);
            break;
        default:
            break;
    }
}

/* 收到呼入电话的回调 */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
                             pjsip_rx_data *rdata) {
    pjsua_call_info ci;
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    pjsua_call_get_info(call_id, &ci);
    PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!",
              (int)ci.remote_info.slen,
              ci.remote_info.ptr));
    if ([YLT_Sip sharedInstance].currentSession.accountID == 0) {
        [YLT_Sip sharedInstance].currentSession.accountID = call_id;
    } else {//当前通话处理占线状态
        YLT_LogWarn(@"当前电话处于占线状态");
        return;
    }
    
    NSString *temp = [NSString stringWithUTF8String:ci.remote_info.ptr];
    NSRange range  = [temp rangeOfString:@":"];
    NSRange range2 = [temp rangeOfString:@"@"];
    NSString *name = [temp substringWithRange:NSMakeRange(range.location + 1, range2.location-range.location-1)];
#warning alex
//    [[Tour_DialingView sharedDialingView] initWithDialType:1 withName:name];
//    [[Tour_DialingView sharedDialingView] incoming];
//    [[Tour_DialingView sharedDialingView] show];
}

/* 呼出状态改变的回调 */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
    pjsua_call_info ci;
    PJ_UNUSED_ARG(e);
    pjsua_call_get_info(call_id, &ci);
    if (ci.state == PJSIP_INV_STATE_INCOMING) {
        [YLT_Sip sharedInstance].currentSession.sessionType = YES;
    }
    if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
        [YLT_Sip sharedInstance].currentSession.answer = YES;
//        [[Tour_DialingView sharedDialingView] calling];
    }
    if ([YLT_Sip sharedInstance].currentSession.state == PJSIP_INV_STATE_CALLING && ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        YLT_LogWarn(@"呼叫失败！");
    }
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        //保存通话记录并重制最新通话记录的数据
        if ([YLT_Sip sharedInstance].currentSession.state != PJSIP_INV_STATE_DISCONNECTED) {
            [[YLT_Sip sharedInstance].currentSession save];
        }
        [[YLT_Sip sharedInstance].currentSession clear];
//        [[Tour_DialingView sharedDialingView] remove];
    }
    [YLT_Sip sharedInstance].currentSession.state = ci.state;
}

/* 会话时media状态改变的回调 */
static void on_call_media_state(pjsua_call_id call_id) {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
        YLT_LogWarn(@"会话成功，创建语音设备连接");
    }
}

/* 输出错误信息 */
static void error_exit(const char *title, pj_status_t status) {
    pjsua_perror(THIS_FILE, title, status);
    pjsua_destroy();
    exit(1);
}

char *keys = "0102030405060708";
/* SDP包创建时候的回调 */
static void on_call_sdp_created(pjsua_call_id call_id,
                                pjmedia_sdp_session *sdp,
                                pj_pool_t *pool,
                                const pjmedia_sdp_session *rem_sdp) {
    /**
     * 远程里面有数据      说明是接收方     接收方解密
     * 远程里面没有数据    说明是发送方     发送方加密数据
     **/
    if (rem_sdp) {//接收方  下面接收加密密钥索引
        for (int i = 0; i < rem_sdp->media_count; i++) {
            pjmedia_sdp_media *media = *(rem_sdp->media+i);
            pj_str_t k = {"k", 1};
            pjmedia_sdp_attr *key = pjmedia_sdp_attr_find(media->attr_count, media->attr, &k, NULL);
            for (int i = 0; i < key->value.slen; i++) {
                printf("%c", *(key->value.ptr+i));
            }
        }
        NSInteger keyIndex = 0;//获取到索引  将索引保存起来  等到需要解密的时候使用
        pjmedia_set_key(keys, 1);
    } else {//发送方  下面传输加密密钥索引
        //获取到需要使用的加密密钥的索引  然后放到 0807060504030201 字段部分 进行传输
        for (int i = 0; i < sdp->media_count; i++) {
            pjmedia_sdp_media *media = *(sdp->media+i);
            pj_str_t value = {"0807060504030201", 16};//索引值
            pjmedia_sdp_attr* key = pjmedia_sdp_attr_create(pool, "k", &value);
            pjmedia_sdp_media_add_attr(media, key);
        }
        pjmedia_set_key(keys, 1*16);
    }
}





