//
//  FFCacheManager.h
//  BlackHole
//
//  Created by 万材 on 2019/9/27.
//  Copyright © 2019 FF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFCacheConfig.h"
#import "FFCacheModel.h"


NS_ASSUME_NONNULL_BEGIN

/// 缓存是否存储成功的Block
typedef void(^FFCacheIsSuccessBlock)(BOOL isSuccess);
/// 得到缓存的Block
typedef void(^FFCacheValueBlock)(NSData * _Nullable data,NSString * _Nullable filePath);
/// 缓存完成的后续操作Block
typedef void(^FFCacheCompletedBlock)(void);

@interface FFCacheManager : NSObject

/// 单例
+ (instancetype)shareInstance;


/**
 * 必须设置缓存类型
 * 根据不同的类型获取不同的硬盘缓存地址
 */
@property (nonatomic, assign) FFCacheType cacheType;

#pragma mark 路径
/// 获取沙盒Home的文件目录
- (NSString *)homePath;
/// 获取沙盒Library/Caches的文件目录
- (NSString *_Nullable)cachesPath;
/// 获取当前缓存类型下的缓存地址
- (NSString *)getAppDiskCachePath;


#pragma  mark 缓存存储
/// 数据存储到缓存中, content必须NSdata类型
- (void)storeContent:(NSObject *)content forKey:(NSString *)key isSuccess:(FFCacheIsSuccessBlock)isSuccess;
- (void)storeContent:(NSObject *)content forKey:(NSString *)key inPath:(NSString *)path isSuccess:(FFCacheIsSuccessBlock)isSuccess;

#pragma mark 硬盘缓存获取
/// 根据key获取缓存
- (NSData *)getCacheDataForKey:(NSString *)key;
/**
 * 获取缓存
 * path-父文件夹的路径
 */
- (NSData *)getCacheDataForKey:(NSString *)key inPath:(NSString *)path;
- (void)getCacheDataForKey:(NSString *)key value:(FFCacheValueBlock)value;
- (void)getCacheDataForKey:(NSString *)key inPath:(NSString *)path value:(FFCacheValueBlock)value;

#pragma  mark - 缓存是否存在
/**
 * 缓存是否存在, 优先检查内存缓存, 不存在检查硬盘缓存
 */
- (BOOL)cacheExistsForKey:(NSString *)key;

/**
 * 缓存是否存在
 * key-缓存key, path是父文件夹路径
 * 优先检查内存缓存, 不存在检查硬盘缓存
 */
- (BOOL)cacheExistsForKey:(NSString *)key inPath:(NSString *)path;
/**
 * 缓存是否存在, 只检查硬盘缓存
 */
- (BOOL)diskCacheExistsForKey:(NSString *)key;
/**
 * 缓存是否存在
 * key-缓存key, path是父文件夹路径
 * 只检查硬盘缓存
 */
- (BOOL)diskCacheExistsForKey:(NSString *)key inPath:(NSString *)path;

#pragma mark 清除单个缓存
/// 清除单个缓存
- (void)clearCacheForkey:(NSString *)key;
- (void)clearCacheForkey:(NSString *)key completion:(FFCacheCompletedBlock)completion;
- (void)clearCacheForkey:(NSString *)key inPath:(NSString *)path completion:(FFCacheCompletedBlock)completion;

#pragma mark 清除所有缓存
/// 清理内存
- (void)clearMemory;
/// 清理缓存
- (void)clearCache;
/// 清理缓存, 成功回调
- (void)clearCacheOnCompletion:(FFCacheCompletedBlock)completion;

#pragma  mark - 设置过期时间 清除单个缓存文件
/// 设置的单个缓存的过期时间
- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time;
- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time completion:(FFCacheCompletedBlock)completion;
- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time inPath:(NSString *)path completion:(FFCacheCompletedBlock)completion;

#pragma mark 获取缓存大小
/**
 *  显示data文件缓存大小 默认缓存路径/Library/Caches/App
 */
- (NSUInteger)getCacheSize;

/**
 *  显示data文件缓存个数 默认缓存路径/Library/Caches/App
 */
- (NSUInteger)getCacheCount;

/**
 *  显示文件大小
 *  @param path            自定义路径
 *  @return size           大小
 */
- (NSUInteger)getFileSizeWithPath:(NSString *_Nullable)path;

/**
 *  显示文件个数
 *  @param  path           自定义路径
 *  @return count          数量
 */
- (NSUInteger)getFileCountWithPath:(NSString *_Nullable)path;

/**
 *  显示文件的大小单位
 *
 *  @param size    得到的大小
 *  @return 显示的单位 GB/MB/KB
 */
- (NSString *_Nullable)fileUnitWithSize:(float)size;

/**
 *  磁盘总空间大小
 *
 *  @return size           大小
 */
- (NSUInteger)diskSystemSpace;

/**
 *  磁盘空闲系统空间
 *
 *  @return size           大小
 */
- (NSUInteger)diskFreeSystemSpace;


#pragma mark 清除内存tmp文件
/// 清除整个tmp文件夹
- (void)clearAllTmpFolder;
/// 清除具体某个缓存
- (void)clearOneDetailTmpWithName:(NSString *)tmpName;

@end

NS_ASSUME_NONNULL_END
