//
//  CCDDelegateInterceptor.h
//  Pods
//
//  Created by zhuruhong on 2024/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCDDelegateInterceptor<CCDDelegateType> : NSObject

@property (nonatomic, strong, readonly) CCDDelegateType mySelf;
/// 代理源
@property (nonatomic, weak, readonly) id original;
/// 拦截者
@property (nonatomic, weak, readonly) id accepter;

- (instancetype)initWithOriginal:(CCDDelegateType)original accepter:(nullable id)accepter;
- (instancetype)initWithOriginal:(CCDDelegateType)original;

- (bool)originalRespondsToSelector:(SEL)aSelector;
- (bool)accepterRespondsToSelector:(SEL)aSelector;

@end

NS_ASSUME_NONNULL_END
