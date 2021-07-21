//
//  NSBundle+Language.h
//  GlobalizationDemo
//
//  Created by ma qi on 2020/8/20.
//  Copyright © 2020 ma qi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Language)

+ (BOOL)isChineseLanguage;
+ (NSString *)currentLanguage;

@end

NS_ASSUME_NONNULL_END
