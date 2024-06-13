//
//  NSURLSession+CCDProxy.m
//  CCDBucket
//
//  Created by 十年之前 on 2024/6/2.
//

#import "NSURLSession+CCDProxy.h"
#import "CCDDelegateHookDefines.h"
#import "CCDDelegateDispatcher.h"
#import "CCDURLSessionLogger.h"
#import "CCDURLSessionProxy.h"

@implementation NSURLSession (CCDProxy)

+ (void)load
{
    Class cls = [self class];
    CCD_Hook_Method(cls, @selector(sessionWithConfiguration:delegate:delegateQueue:), cls, @selector(hook_sessionWithConfiguration:delegate:delegateQueue:), YES);
    CCD_Hook_Method(cls, @selector(dataTaskWithRequest:completionHandler:), cls, @selector(hook_dataTaskWithRequest:completionHandler:), NO);
}

+ (NSURLSession *)hook_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue: (NSOperationQueue *)queue
{
    //TODO: 增加外部 receivers 的注册逻辑
    CCDDelegateDispatcher *dispatcher = [[CCDDelegateDispatcher alloc] init];
    !delegate ?: [dispatcher addSubscriber:delegate];
    [dispatcher addSubscriber:[CCDURLSessionLogger sharedInstance]];
    
    CCDURLSessionProxy *proxy = [[CCDURLSessionProxy alloc] initWithOriginal:delegate accepter:dispatcher];
    proxy.dispatcher = dispatcher;
    
    NSURLSession *session = [self hook_sessionWithConfiguration:configuration delegate:proxy delegateQueue:queue];
    /// 共享 session 存在资源被释放问题不能调用 finishTasksAndInvalidate 来释放 proxy；
    /// 独立 session 可以通过调用 finishTasksAndInvalidate 来释放 proxy；
    //TODO: 调整 session 处理方法
//    proxy.session = session;
    DDLogDebug(@"[Proxy] hook_sessionWithConfiguration");
    return session;
}

- (NSURLSessionDataTask *)hook_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (completionHandler) {
            completionHandler(data,response,error);
        }
        //TODO: 做自己的处理
        id<CCDURLSessionDelegate> delegateProxy = nil;
        if ([strongSelf.delegate conformsToProtocol:@protocol(CCDURLSessionDelegate)]) {
            delegateProxy = (id<CCDURLSessionDelegate>)strongSelf.delegate;
        }
        [delegateProxy request:request completionWith:response data:data error:error];
        DDLogDebug(@"[Proxy] hook_dataTaskWithRequest completionHandler");
    };
    
    DDLogDebug(@"[Proxy] hook_dataTaskWithRequest");
    return [self hook_dataTaskWithRequest:request completionHandler:completion];
}

@end
