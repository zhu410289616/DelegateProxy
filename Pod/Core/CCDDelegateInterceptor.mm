//
//  CCDDelegateInterceptor.m
//  Pods
//
//  Created by zhuruhong on 2024/6/10.
//

#import "CCDDelegateInterceptor.h"
#include <map>
#include <string>

typedef std::map<std::string, bool> CCDDIResponds;

@interface CCDDelegateInterceptor ()
{
    CCDDIResponds original_responds;
    CCDDIResponds accepter_responds;
    CCDDIResponds super_responds;
    __weak id _original;
    __weak id _accepter;
}

@end

@implementation CCDDelegateInterceptor

- (void)dealloc
{
    original_responds.clear();
    accepter_responds.clear();
    super_responds.clear();
}

- (instancetype)initWithOriginal:(id)original accepter:(id)accepter
{
    if (self = [super init]) {
        _original = original;
        _accepter = accepter ?: self;
    }
    return self;
}

- (instancetype)initWithOriginal:(id)original
{
    return [self initWithOriginal:original accepter:nil];
}

static bool CCDRespondsToSelector(CCDDIResponds &responds_map, id obj, SEL aSelector)
{
    if (obj == nil) { return false; }
    
    bool b = false;
    std::string sel_name = sel_getName(aSelector);
    if (responds_map.find(sel_name) == responds_map.end()) {
        b = [obj respondsToSelector:aSelector];
        responds_map.insert(std::make_pair(sel_name, b));
    } else {
        b = responds_map.at(sel_name);
    }
    return b;
}

- (bool)superRespondsToSelector:(SEL)aSelector
{
    bool b = false;
    std::string sel_name = sel_getName(aSelector);
    if (super_responds.find(sel_name) == super_responds.end()) {
        b = [super respondsToSelector:aSelector];
        super_responds.insert(std::make_pair(sel_name, b));
    } else {
        b = super_responds.at(sel_name);
    }
    return b;
}

- (bool)originalRespondsToSelector:(SEL)aSelector
{
    return CCDRespondsToSelector(original_responds, _original, aSelector);
}

- (bool)accepterRespondsToSelector:(SEL)aSelector
{
    if (_accepter == self) {
        return [self superRespondsToSelector:aSelector];
    }
    return CCDRespondsToSelector(accepter_responds, _accepter, aSelector);
}

#pragma mark - getter & setter

- (id)mySelf
{
    return self;
}

- (id)original
{
    return _original;
}

- (id)accepter
{
    return _accepter;
}

#pragma mark -

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self accepterRespondsToSelector:aSelector]) {
        return YES;
    }
    if ([self originalRespondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self accepterRespondsToSelector:aSelector]) {
        return _accepter;
    }
    if ([self originalRespondsToSelector:aSelector]) {
        return _original;
    }
    return nil;
}

#pragma mark -

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [self.original methodSignatureForSelector:aSelector];
    }
    if (!signature) {
        signature = [self.accepter methodSignatureForSelector:aSelector];
    }
    return [[self class] instanceMethodSignatureForSelector:@selector(nothingMethod)];
}

- (void)nothingMethod
{
#ifdef DEBUG
    NSLog(@"nothingMethod");
#endif
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = [anInvocation selector];
    if ([self.original respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.original];
    }
    if ([self.accepter respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.accepter];
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
#ifdef DEBUG
    NSLog(@"not found selector [%@]", NSStringFromSelector(aSelector));
#endif
}

@end
