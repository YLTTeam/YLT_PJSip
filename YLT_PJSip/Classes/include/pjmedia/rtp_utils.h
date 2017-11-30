#ifndef __PJMEDIA_UTILS_H__
#define __PJMEDIA_UTILS_H__

#include "pjmedia/tiny_aes.h"
#include <pjmedia/types.h>

#ifdef OS_MAC
#include <openssl/evp.h>
#endif

#define RTP_HEADER_BYTE 12
#define RTP_PACK_BYTE 32
#define KEY_LENGTH 16
#define CHG_INTERVAL 50

#ifdef __cplusplus 
extern "C" {
#endif
int pjmedia_key_clear();
int pjmedia_set_key(unsigned char* keybuf, unsigned int buflen);
int deal_send(void *input, int data_len, int head_len);
int deal_receive(void *input, int data_len, int head_len);
#ifdef __cplusplus
}
#endif

#endif //__PJMEDIA_UTILS_H__ ends