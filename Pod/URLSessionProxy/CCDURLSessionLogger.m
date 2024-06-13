//
//  CCDURLSessionLogger.m
//  CCDBucket
//
//  Created by 十年之前 on 2024/6/5.
//

#import "CCDURLSessionLogger.h"

@implementation CCDURLSessionLogger

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#ifdef URLSessionProxyLog
- (void)dealloc
{
    DDLogDebug(@"[Logger] dealloc:%p:%@", self, self.class);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        DDLogDebug(@"[Logger] init:%p:%@", self, self.class);
    }
    return self;
}

#pragma mark - CCDURLSessionDelegate

- (void)request:(NSURLRequest *)request completionWith:(NSURLResponse *)rsp data:(NSData *)data error:(NSError *)error
{
    DDLogInfo(@"[Logger] completion:%p:%@:%@", self, request.HTTPMethod, request.URL.absoluteString);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    NSURLRequest *request = task.originalRequest;
    DDLogInfo(@"[Logger] finished:%p:%@:%@", self, request.HTTPMethod, request.URL.absoluteString);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSURLRequest *request = dataTask.originalRequest;
    DDLogDebug(@"[Logger] received:%p:%@:%@:%@", self, request.HTTPMethod, request.URL.absoluteString, data);
}
#endif

@end
