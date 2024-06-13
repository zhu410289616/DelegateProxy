//
//  CCDDelegateDispatcher.h
//  Pods
//
//  Created by zhuruhong on 2024/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 注册多个代理订阅者

FOUNDATION_EXPORT NSMutableDictionary *CCDDelegateSubscribers(void);
FOUNDATION_EXPORT void CCDDelegateAddSubscriber(NSString *key, id delegate);
FOUNDATION_EXPORT void CCDDelegateRemoveSubscriber(NSString *key, id delegate);

#pragma mark -

@interface CCDDelegateDispatcher : NSObject

/// 代理源数组，按顺序依次分发，有返回值取第一个符合条件的对象
@property (nonatomic, strong, readonly) NSArray *receivers;

- (void)addSubscriber:(id)subscriber;
- (void)removeSubscriber:(id)subscriber;

@end

NS_ASSUME_NONNULL_END
