//
//  NSBundle+Language.m
//  GlobalizationDemo
//
//  Created by ma qi on 2020/8/20.
//  Copyright © 2020 ma qi. All rights reserved.
//

#import "NSBundle+Language.h"
#import "FFLanguageConfig.h"
#import <objc/runtime.h>

@implementation NSBundle (Language)

+ (void)load {
    NSLog(@">>>currentLanguage:%@", [self currentLanguage]);
    Method ori = class_getInstanceMethod(self, @selector(localizedStringForKey:value:table:));
    Method cur = class_getInstanceMethod(self, @selector(mq_localizedStringForKey:value:table:));
    method_exchangeImplementations(ori, cur);
}

- (NSString *)mq_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSBundle currentLanguage] ofType:@"lproj"];
    if (path.length > 0) {
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        return [bundle mq_localizedStringForKey:key value:value table:tableName];
    }
    return [self mq_localizedStringForKey:key value:value table:tableName];
}


+ (BOOL)isChineseLanguage {
    NSString *currentLanguage = [self currentLanguage];
    return [currentLanguage hasPrefix:@"zh-Hans"];
}

+ (NSString *)currentLanguage {
    return [FFLanguageConfig userLanguage] ? : [NSLocale preferredLanguages].firstObject;
}

@end
