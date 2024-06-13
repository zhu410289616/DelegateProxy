//
//  CCDDelegateDispatcher.m
//  Pods
//
//  Created by zhuruhong on 2024/6/10.
//

#import "CCDDelegateDispatcher.h"
#import <pthread/pthread.h>

#pragma mark - 注册多个代理订阅者

NSHashTable *CCDDelegateSubscribers(void)
{
    static NSHashTable *delegates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegates = [NSHashTable weakObjectsHashTable];
    });
    return delegates;
}

void CCDDelegateAddSubscriber(id delegate)
{
    !delegate ?: [CCDDelegateSubscribers() addObject:delegate];
}

void CCDDelegateRemoveSubscriber(id delegate)
{
    !delegate ?: [CCDDelegateSubscribers() removeObject:delegate];
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
