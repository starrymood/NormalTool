//
//  FFCacheConfig.h
//  BlackHole
//
//  Created by 万材 on 2021/7/15.
//  Copyright © 2021 冯振伟. All rights reserved.
//

#ifndef FFCacheConfig_h
#define FFCacheConfig_h

/// 缓存类型
typedef NS_ENUM(NSInteger, FFCacheType){
    /// 全局缓存
    FFCacheGlobalType = 0,
    /// 用户缓存
    FFCacheUserMsgType,
    /// 直播间缓存
    FFCacheLiveRoomType
};

/// Caches下缓存路径名称
static NSString *const ff_PathSpace = @"App";
/// Caches/App-全局缓存文件夹名称
static NSString *const globalPath  = @"GlobalPath";
/// Caches/App-用户缓存文件夹名称
static NSString *const userMsgPath = @"UserMsgPath";
/// Caches/App-房间缓存文件夹名称
static NSString *const liveRoomPath= @"LiveRoomPath";

/// 默认内存缓存的名称
static NSString *const ff_DefaultCachePathName = @"AppCache";
/// 默认缓存一天
static NSInteger const defaultCacheMaxCacheAge = 60*60*24;

#endif /* FFCacheConfig_h */
