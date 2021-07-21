#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FFCacheConfig.h"
#import "FFCacheManager.h"
#import "FFCacheModel.h"
#import "FFCacheNormalTool.h"
#import "FFLanguageConfig.h"
#import "NSBundle+Language.h"

FOUNDATION_EXPORT double NormalToolVersionNumber;
FOUNDATION_EXPORT const unsigned char NormalToolVersionString[];

