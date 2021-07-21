//
//  FFCacheNormalTool.h
//  BtnDemo
//
//  Created by 万材 on 2021/7/16.
//  Copyright © 2021 万材. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFCacheConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface FFCacheNormalTool : NSObject

/// 获取当前缓存类型下的key数组
+ (NSMutableArray *)getDataStructureKeyArrayWithDataDic:(NSDictionary *)dataDic type:(FFCacheType)cacheType;
/// 新增缓存key
+ (void)insertDataStructureKeyWithDataDic:(NSMutableDictionary *)dataDic dataArr:(NSArray *)dataArr type:(FFCacheType)cacheType;

@end

NS_ASSUME_NONNULL_END
