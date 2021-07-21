//
//  FFLanguageConfig.h
//  PlayerDemo
//
//  Created by 万材 on 2021/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FFGlobalLanguageType) {
    FFGlobalLanguageSystem = 0,
    FFGlobalLanguageChinese,
    FFGlobalLanguageEnglish,
    FFGlobalLanguageJapanese
};


@interface FFLanguageConfig : NSObject

/**
 用户自定义使用的语言，当传nil时，等同于resetSystemLanguage
 */
@property (class, nonatomic, strong, nullable) NSString *userLanguage;

@property (class, nonatomic, assign) FFGlobalLanguageType languageType;

/**
 重置系统语言
 */
+ (void)resetSystemLanguage;


@end

NS_ASSUME_NONNULL_END
