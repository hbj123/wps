
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (KWAES)

/**
 *  加密数据
 *
 *  @param key  密钥
 *  @return     密文数据
 */
- (NSData *) KWAES256EncryptWithKey:(NSData *)key;

/**
 *  解密数据
 *
 *  @param key  密钥
 *  @return     明文数据
 */
- (NSData *) KWAES256DecryptWithKey:(NSData *)key;

@end
