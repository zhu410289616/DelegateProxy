//
//  CCDURLSessionProxy.m
//  CCDBucket
//
//  Created by zhuruhong on 2024/6/10.
//

#import "CCDURLSessionProxy.h"
#import <objc/message.h>

@implementation CCDURLSessionProxy

#ifdef URLSessionProxyLog
- (void)dealloc
{
    DDLogDebug(@"[Proxy] dealloc:%p:%@", self, self.class);
}

- (instancetype)initWithOriginal:(id)original accepter:(id)accepter
{
    self = [super initWithOriginal:original accepter:accepter];
    if (self) {
        DDLogDebug(@"[Proxy] init:%p:%@", self, self.class);
    }
    return self;
}
#endif

#pragma mark - CCDURLSessionDelegate

- (void)request:(NSURLRequest *)request completionWith:(NSURLResponse *)rsp data:(NSData *)data error:(NSError *)error
{
    if ([self originalRespondsToSelector:_cmd]) {
        [self.original request:request completionWith:rsp data:data error:error];
    }
    if ([self accepterRespondsToSelector:_cmd]) {
        [self.accepter request:request completionWith:rsp data:data error:error];
    }
    /// 通过调用 finishTasksAndInvalidate 方法释放 proxy 对象；
    /// 但是会影响共用 session 的逻辑，在具体 session 初始化的代码段调用更加合适；
    !self.session ?: [self.session finishTasksAndInvalidate];
    
#ifdef URLSessionProxyLog
    DDLogDebug(@"[Proxy] completion:%p:%@:%@", self, request.HTTPMethod, request.URL.absoluteString);
#endif
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if ([self originalRespondsToSelector:_cmd]) {
        [self.original URLSession:session task:task didCompleteWithError:error];
    }
    if ([self accepterRespondsToSelector:_cmd]) {
        [self.accepter URLSession:session task:task didCompleteWithError:error];
    }
    /// 通过调用 finishTasksAndInvalidate 方法释放 proxy 对象；
    /// 但是会影响共用 session 的逻辑，在具体 session 初始化的代码段调用更加合适；
    !self.session ?: [self.session finishTasksAndInvalidate];
    
#ifdef URLSessionProxyLog
    NSURLRequest *request = task.originalRequest;
    DDLogDebug(@"[Proxy] finished:%p:%@:%@", self, request.HTTPMethod, request.URL.absoluteString);
#endif
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if ([self originalRespondsToSelector:_cmd]) {
//        [self.original URLSession:session dataTask:dataTask didReceiveData:data];
        ((void (*)(id, SEL, NSURLSession*, NSURLSessionDataTask*, NSData*))objc_msgSend)(self.original, _cmd, session, dataTask, data);
    }
    if ([self accepterRespondsToSelector:_cmd]) {
//        [self.accepter URLSession:session dataTask:dataTask didReceiveData:data];
        ((void (*)(id, SEL, NSURLSession*, NSURLSessionDataTask*, NSData*))objc_msgSend)(self.accepter, _cmd, session, dataTask, data);
    }
    
#ifdef URLSessionProxyLog
    NSURLRequest *request = dataTask.originalRequest;
    DDLogDebug(@"[Proxy] received:%p:%@:%@:%@", self, request.HTTPMethod, request.URL.absoluteString, data);
#endif
}

@end
