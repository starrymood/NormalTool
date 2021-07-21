//
//  FFLanguageConfig.m
//  PlayerDemo
//
//  Created by 万材 on 2021/7/20.
//

#import "FFLanguageConfig.h"

static NSString *const FFUserLanguageKey = @"FFUserLanguageKey";
#define STANDARD_USER_DEFAULT  [NSUserDefaults standardUserDefaults]

@implementation FFLanguageConfig

@dynamic languageType;

+ (void)setUserLanguage:(NSString *)userLanguage {
    //跟随手机系统
    if (userLanguage.length == 0) {
        [self resetSystemLanguage];
        return;
    }
    //用户自定义
    [STANDARD_USER_DEFAULT setValue:userLanguage forKey:FFUserLanguageKey];
    [STANDARD_USER_DEFAULT setValue:@[userLanguage] forKey:@"AppleLanguages"];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (void)setLanguageType:(FFGlobalLanguageType)languageType {
    
    NSString *lanCode = nil;

    switch (languageType) {
        case FFGlobalLanguageSystem:
            lanCode = nil;
            break;
        case FFGlobalLanguageChinese:
            lanCode = @"zh-Hans";    //中文简体
            break;
        case FFGlobalLanguageEnglish:
            lanCode = @"en";        // 英文
            break;
        case FFGlobalLanguageJapanese:
            lanCode = @"ja";        // 日文
            break;
    }
    if (lanCode.length == 0) {
        [self resetSystemLanguage];
        return;
    }
    //用户自定义
    [STANDARD_USER_DEFAULT setValue:lanCode forKey:FFUserLanguageKey];
    [STANDARD_USER_DEFAULT setValue:@[lanCode] forKey:@"AppleLanguages"];
    [STANDARD_USER_DEFAULT synchronize];
}


+ (NSString *)userLanguage {
    return [STANDARD_USER_DEFAULT valueForKey:FFUserLanguageKey];
}

//** 重置系统语言 */
+ (void)resetSystemLanguage {
    [STANDARD_USER_DEFAULT removeObjectForKey:FFUserLanguageKey];
    [STANDARD_USER_DEFAULT setValue:nil forKey:@"AppleLanguages"];
    [STANDARD_USER_DEFAULT synchronize];
}


@end
