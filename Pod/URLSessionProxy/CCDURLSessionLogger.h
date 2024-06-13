//
//  CCDURLSessionLogger.h
//  CCDBucket
//
//  Created by 十年之前 on 2024/6/5.
//

#import <Foundation/Foundation.h>
#import "CCDURLSessionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCDURLSessionLogger : NSObject <CCDURLSessionDelegate>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
