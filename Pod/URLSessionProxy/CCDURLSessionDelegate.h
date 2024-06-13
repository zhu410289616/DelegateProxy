//
//  CCDURLSessionDelegate.h
//  CCDBucket
//
//  Created by 十年之前 on 2024/6/5.
//

#import <Foundation/Foundation.h>

#if __has_include(<CCDBucket/CCDLogger.h>)
#import <CCDBucket/CCDLogger.h>

#define URLSessionProxyLog 1

#endif

NS_ASSUME_NONNULL_BEGIN

@protocol CCDURLSessionDelegate <NSURLSessionDataDelegate>

- (void)request:(NSURLRequest *)request completionWith:(NSURLResponse *)rsp data:(NSData *)data error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
