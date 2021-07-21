//
//  FFCacheModel.h
//  BlackHole
//
//  Created by 万材 on 2021/7/15.
//  Copyright © 2021 冯振伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFCacheConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFCacheModel : NSObject

/// 名字-key
@property (nonatomic,   copy) NSString *name;
/// 缓存路径
@property (nonatomic,   copy) NSString *path;
/// 缓存类型
@property (nonatomic, assign) FFCacheType cacheType;
/// 失效周期, 默认60s
@property (nonatomic, assign) NSInteger invalidTime;
/// 是否允许定时器本地任务清理, 默认清理 - YES
@property (nonatomic, assign) BOOL isNeedRefresh;
/// 是否允许本地清理, 默认清理 YES
@property (nonatomic, assign) BOOL isCanClear;
/// 业务结果
@property (nonatomic, strong) NSDictionary *data;


@end

NS_ASSUME_NONNULL_END
