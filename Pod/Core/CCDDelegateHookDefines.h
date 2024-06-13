//
//  CCDDelegateHookDefines.h
//  CCDBucket
//
//  Created by 十年之前 on 2024/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Hook delegate 方法
FOUNDATION_EXPORT void CCD_Hook_Delegate_Method(Class originalClass, SEL originalSel, Class replaceClass, SEL replaceSel, SEL noneSel);
/// Hook 方法
FOUNDATION_EXPORT void CCD_Hook_Method(Class originalClass, SEL originalSel, Class replaceClass, SEL replaceSel, BOOL isHookClassMethod);


@interface CCDDelegateHookDefines : NSObject

@end

NS_ASSUME_NONNULL_END
