//
//  CCDDelegateDispatcher.m
//  Pods
//
//  Created by zhuruhong on 2024/6/10.
//

#import "CCDDelegateDispatcher.h"
#import <pthread/pthread.h>

#pragma mark - 注册多个代理订阅者

NSMutableDictionary *CCDDelegateSubscribers(void)
{
    static NSMutableDictionary *delegates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegates = @{}.mutableCopy;
    });
    return delegates;
}

void CCDDelegateAddSubscriber(NSString *key, id delegate)
{
    if (key.length == 0 || !delegate) {
        return;
    }
    NSMutableDictionary *subDic = CCDDelegateSubscribers()[key];
    if (!subDic) {
        subDic = @{}.mutableCopy;
        CCDDelegateSubscribers()[key] = subDic;
    }
    NSString *subKey = [NSString stringWithFormat:@"%p", delegate];
    subDic[subKey] = delegate;
}

void CCDDelegateRemoveSubscriber(NSString *key, id delegate)
{
    if (key.length == 0 || !delegate) {
        return;
    }
    NSMutableDictionary *subDic = CCDDelegateSubscribers()[key];
    !subDic ?: [subDic removeObjectForKey:delegate];
}

#pragma mark -

@interface CCDDelegateDispatcher ()
{
    pthread_rwlock_t _subscriber_rwlock;
}

@property (nonatomic, strong) NSHashTable *subscribers;

@end

@implementation CCDDelegateDispatcher

- (void)dealloc
{
    pthread_rwlock_destroy(&_subscriber_rwlock);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_rwlock_init(&_subscriber_rwlock, NULL);
//        _subscribers = [NSHashTable weakObjectsHashTable];
        _subscribers = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (void)addSubscriber:(id)subscriber
{
    pthread_rwlock_wrlock(&_subscriber_rwlock);
    !subscriber ?: [self.subscribers addObject:subscriber];
    pthread_rwlock_unlock(&_subscriber_rwlock);
}

- (void)removeSubscriber:(id)subscriber
{
    pthread_rwlock_wrlock(&_subscriber_rwlock);
    !subscriber ?: [self.subscribers removeObject:subscriber];
    pthread_rwlock_unlock(&_subscriber_rwlock);
}

#pragma mark -

- (NSArray *)receivers
{
    pthread_rwlock_rdlock(&_subscriber_rwlock);
    NSArray *receivers = [self.subscribers allObjects];
    pthread_rwlock_unlock(&_subscriber_rwlock);
    return receivers;
}

#pragma mark -

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    for (id receiver in self.receivers) {
        if ([receiver respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for (id receiver in self.receivers) {
        if ([receiver respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:receiver];
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        for (id receiver in self.receivers) {
            signature = [receiver methodSignatureForSelector:aSelector];
            if (signature) {
                break;
            }
        }
    }
    return signature;
}

@end
