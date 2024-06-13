//
//  CCDURLSessionProxy.h
//  CCDBucket
//
//  Created by zhuruhong on 2024/6/10.
//

#import "CCDDelegateInterceptor.h"
#import "CCDURLSessionDelegate.h"
#import "CCDDelegateDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCDURLSessionProxy : CCDDelegateInterceptor <CCDURLSessionDelegate>

/// 设置了 session 后，内部会调用调用 finishTasksAndInvalidate 方法释放 proxy 对象；
/// 但是会影响共用 session 的逻辑，在具体 session 初始化的代码段调用更加合适；
@property (nonatomic,   weak) NSURLSession *session;
@property (nonatomic, strong) CCDDelegateDispatcher *dispatcher;

@end

NS_ASSUME_NONNULL_END
