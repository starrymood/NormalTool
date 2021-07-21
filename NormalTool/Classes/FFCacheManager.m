//
//  FFCacheManager.m
//  BlackHole
//
//  Created by 万材 on 2019/9/27.
//  Copyright © 2019 FF. All rights reserved.
//

#import "FFCacheManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "FFCacheNormalTool.h"
#import "FFCacheModel.h"

static const CGFloat unit = 1024.0;
@interface FFCacheManager ()

@property (nonatomic ,strong) NSCache *memoryCache;
@property (nonatomic ,  copy) NSString *diskCachePath;
@property (nonatomic ,strong) dispatch_queue_t operationQueue;
@property (nonatomic, strong) NSTimer *cacheDeleteTimer;

@end

@implementation FFCacheManager

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

+ (instancetype)shareInstance {
    static FFCacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FFCacheManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *memoryNameSpace = [@"memory.FFCacheManager" stringByAppendingString:ff_DefaultCachePathName];
        _operationQueue = dispatch_queue_create("dispatch.FFCacheManager", DISPATCH_QUEUE_SERIAL);
        
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.name = memoryNameSpace;
        
        self.cacheDeleteTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(autoCacheCleanAction) userInfo:nil repeats:YES];
  
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(automaticCleanCache) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundCleanCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

/// 根据缓存类型获取缓存路径
- (void)setCacheType:(FFCacheType)cacheType {
    _cacheType = cacheType;
    switch (cacheType) {
        case FFCacheGlobalType:
            [self initCachesfileWithName:globalPath];
            break;
        case FFCacheUserMsgType:
            [self initCachesfileWithName:userMsgPath];
            break;
        case FFCacheLiveRoomType:
            [self initCachesfileWithName:liveRoomPath];
            break;
        default: {
            
        }
            break;
    }
}

#pragma mark App硬盘缓存路径
- (NSString *)homePath {
    return NSHomeDirectory();
}

- (NSString *)cachesPath{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)getAppDiskCachePath {
    return self.diskCachePath;
}

#pragma mark 创建存储文件夹
- (void)initCachesfileWithName:(NSString *)name{
    self.diskCachePath = [[[self cachesPath] stringByAppendingPathComponent:ff_PathSpace] stringByAppendingPathComponent:name];
    [self createDirectoryAtPath:self.diskCachePath];
}

- (void)createDirectoryAtPath:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    } else {
        NSLog(@"当前缓存文件夹已存在");
    }
}

#pragma  mark 缓存存储
- (void)storeContent:(NSObject *)content forKey:(NSString *)key isSuccess:(FFCacheIsSuccessBlock)isSuccess{
    [self storeContent:content forKey:key inPath:self.diskCachePath isSuccess:isSuccess];
}

/// 缓存存储
- (void)storeContent:(NSObject *)content forKey:(NSString *)key inPath:(NSString *)path isSuccess:(FFCacheIsSuccessBlock)isSuccess {
    if (!content || !key) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(NO);
            });
        }
        return;
    }
    [self.memoryCache setObject:content forKey:key];
    
    dispatch_async(self.operationQueue,^{
        NSString *codingPath = [[self getDiskCacheWithCodingForKey:key inPath:path] stringByDeletingPathExtension];
        BOOL result = [self setContent:content writeToFile:codingPath];
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(result);
            });
        }
    });
}
/// 写入文件中
- (BOOL)setContent:(NSObject *)content writeToFile:(NSString *)path{
    if (!content||!path){
        return NO;
    }
    if ([content isKindOfClass:[NSData class]]) {
        return  [(NSData *)content writeToFile:path atomically:YES];
    }else {
        NSLog(@"文件类型:%@,沙盒存储失败。",NSStringFromClass([content class]));
        return NO;
    }
    return NO;
}

#pragma  mark - 缓存是否存在
- (BOOL)cacheExistsForKey:(NSString *)key{
    return [self cacheExistsForKey:key inPath:self.diskCachePath];
}

- (BOOL)cacheExistsForKey:(NSString *)key inPath:(NSString *)path{
    BOOL isInMemoryCache =  [self.memoryCache objectForKey:key];
    if (isInMemoryCache) {
        return YES;
    }
    return [self diskCacheExistsForKey:key inPath:path];
}

- (BOOL)diskCacheExistsForKey:(NSString *)key{
    return [self diskCacheExistsForKey:key inPath:self.diskCachePath];
}

- (BOOL)diskCacheExistsForKey:(NSString *)key inPath:(NSString *)path{
    NSString *isExists= [[self getDiskCacheWithCodingForKey:key inPath:path] stringByDeletingPathExtension];
    return [self fileExistsAtPath:isExists];
}

- (BOOL)fileExistsAtPath:(NSString *)key{
    return [[NSFileManager defaultManager] fileExistsAtPath:key];
}

#pragma mark 硬盘缓存获取
- (NSData *)getCacheDataForKey:(NSString *)key{
    return [self getCacheDataForKey:key inPath:self.diskCachePath];
}

- (NSData *)getCacheDataForKey:(NSString *)key inPath:(NSString *)path{
    if (!key)return nil;
    NSData *obj = [self.memoryCache objectForKey:key];
    if (obj) {
        return obj;
    }else{
        NSString *filePath=[[self getDiskCacheWithCodingForKey:key inPath:path] stringByDeletingPathExtension];
        NSData *diskdata= [NSData dataWithContentsOfFile:filePath];
        if (diskdata) {
            [self.memoryCache setObject:diskdata forKey:key];
        }
       return diskdata;
    }
}

- (void)getCacheDataForKey:(NSString *)key value:(FFCacheValueBlock)value{
    [self getCacheDataForKey:key inPath:self.diskCachePath value:value];
}

- (void)getCacheDataForKey:(NSString *)key inPath:(NSString *)path value:(FFCacheValueBlock)value{
    if (!key)return;
    NSData *obj = [self.memoryCache objectForKey:key];
    if (obj) {
        if (value) {
            value(obj,@"memoryCache");
        }
    }else{
        dispatch_async(self.operationQueue,^{
            @autoreleasepool {
                NSString *filePath=[[self getDiskCacheWithCodingForKey:key inPath:path]stringByDeletingPathExtension];
                NSData *diskdata= [NSData dataWithContentsOfFile:filePath];
                if (diskdata) {
                    if (value) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            value(diskdata,filePath);
                        });
                    }
                    [self.memoryCache setObject:diskdata forKey:key];
                }
            }
        });
    }
}

- (NSString *)getDiskFileForKey:(NSString *)key inPath:(NSString *)path{
    if (!key)return path;
    return [path stringByAppendingPathComponent:key];
}

- (NSArray *)getDiskCacheFileWithPath:(NSString *)path{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    dispatch_sync(self.operationQueue, ^{
        NSArray* fileEnumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for (NSString *fileName in fileEnumerator){
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            [array addObject:filePath];
        }
    });
    return array;
}

- (NSDictionary* )getDiskFileAttributes:(NSString *)key inPath:(NSString *)path{
    NSString *filePath=[[self getDiskCacheWithCodingForKey:key inPath:path]stringByDeletingPathExtension];
    return [self getDiskFileAttributesWithFilePath:filePath];
}

/// 获取文件的信息
- (NSDictionary* )getDiskFileAttributesWithFilePath:(NSString *)filePath{
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return info;
}

#pragma mark - 清除所有缓存
/// 内存缓存删除
- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}
/// 删除所有disk缓存
- (void)clearCache{
     [self clearCacheOnCompletion:nil];
}

- (void)clearCacheOnCompletion:(FFCacheCompletedBlock)completion{
    dispatch_async(self.operationQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
        [self createDirectoryAtPath:self.diskCachePath];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(),^{
                completion();
            });
        }
    });
}

#pragma mark 清除单个缓存
- (void)clearCacheForkey:(NSString *)key{
    [self clearCacheForkey:key completion:nil];
}

- (void)clearCacheForkey:(NSString *)key completion:(FFCacheCompletedBlock)completion{
    [self clearCacheForkey:key inPath:self.diskCachePath completion:completion];
}

- (void)clearCacheForkey:(NSString *)key inPath:(NSString *)path completion:(FFCacheCompletedBlock)completion{
//    if (self.cacheType == FFCacheGlobalType) return;
    if (!key)return;
    [self.memoryCache removeObjectForKey:key];
    dispatch_async(self.operationQueue,^{
        NSString *filePath=[[self getDiskCacheWithCodingForKey:key inPath:path]stringByDeletingPathExtension];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(),^{
                completion();
            });
        }
    });
}

#pragma mark 定时器定时删除缓存
- (void)autoCacheCleanAction {
    NSString *sourcePath = [[self cachesPath] stringByAppendingPathComponent:ff_PathSpace];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:sourcePath];
    NSString *path;
    while ((path = [fileEnumerator nextObject]) != nil) {
        NSString *filePath = [sourcePath stringByAppendingPathComponent:path];
        BOOL isExist = [self fileExistsAtPath:filePath];
        NSData *diskdata= [NSData dataWithContentsOfFile:filePath];
        if (isExist && diskdata) {
            FFCacheModel *cacheModel = [FFCacheModel mj_objectWithKeyValues:diskdata.mj_keyValues];
            if (!cacheModel.isCanClear) continue;
            if (!cacheModel.isNeedRefresh) continue;
            NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheModel.invalidTime];
            NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *current = [info objectForKey:NSFileModificationDate];
            if ([[current laterDate:expirationDate] isEqualToDate:expirationDate]){
                BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                if (isSuccess) {
                    NSLog(@"删除成功了!");
                }
            }
        }
    }
}

#pragma mark 设置过期时间 清除某路径缓存文件
- (void)automaticCleanCache {
   [self clearCacheWithTime:defaultCacheMaxCacheAge completion:nil];
}

- (void)clearCacheWithTime:(NSTimeInterval)time completion:(nullable FFCacheCompletedBlock)completion{
     [self clearCacheWithTime:time inPath:self.diskCachePath completion:completion];
}

- (void)clearCacheWithTime:(NSTimeInterval)time inPath:(NSString *)path completion:(FFCacheCompletedBlock)completion{
    if (self.cacheType == FFCacheGlobalType) return;
    if (!time||!path)return;
    dispatch_async(self.operationQueue,^{
        // “-” time
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-time];
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        
        for (NSString *fileName in fileEnumerator){
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *current = [info objectForKey:NSFileModificationDate];

            if ([[current laterDate:expirationDate] isEqualToDate:expirationDate]){
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)backgroundCleanCacheWithPath:(NSString *)path{
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    // Start the long-running task and return immediately.
    [self clearCacheWithTime:defaultCacheMaxCacheAge inPath:path completion:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)backgroundCleanCache {
    [self backgroundCleanCacheWithPath:self.diskCachePath];
}


#pragma  mark - 设置过期时间 清除单个缓存文件
- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time{
    [self clearCacheForkey:key time:time completion:nil];
}

- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time completion:(FFCacheCompletedBlock)completion{
    [self clearCacheForkey:key time:time inPath:self.diskCachePath completion:completion];
}

- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time inPath:(NSString *)path completion:(FFCacheCompletedBlock)completion {
    if (!time||!key||!path)return;
    dispatch_async(self.operationQueue,^{
        // “-” time
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-time];
        
        NSString *filePath=[[self getDiskCacheWithCodingForKey:key inPath:path]stringByDeletingPathExtension];
        
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSDate *current = [info objectForKey:NSFileModificationDate];
        
        if ([[current laterDate:expirationDate] isEqualToDate:expirationDate]){
            [self.memoryCache removeObjectForKey:key];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

#pragma mark 获取缓存大小
- (NSUInteger)getCacheSize {
    return [self getFileSizeWithPath:self.diskCachePath];
}

- (NSUInteger)getCacheCount {
    return [self getFileCountWithPath:self.diskCachePath];
}

- (NSUInteger)getFileSizeWithPath:(NSString *)path{
    __block NSUInteger size = 0;
    //sync
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

- (NSUInteger)getFileCountWithPath:(NSString *)path{
    __block NSUInteger count = 0;
    //sync
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}

- (NSString *)fileUnitWithSize:(float)size{
    if (size >= unit * unit * unit) { // >= 1GB
        return [NSString stringWithFormat:@"%.2fGB", size / unit / unit / unit];
    } else if (size >= unit * unit) { // >= 1MB
        return [NSString stringWithFormat:@"%.2fMB", size / unit / unit];
    } else { // >= 1KB
        return [NSString stringWithFormat:@"%.2fKB", size / unit];
    }
}

- (NSUInteger)diskSystemSpace{
    __block NSUInteger size = 0.0;
    dispatch_sync(self.operationQueue, ^{
        NSError *error=nil;
        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self homePath] error:&error];
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }else{
            NSNumber *systemNumber = [dic objectForKey:NSFileSystemSize];
            size = [systemNumber floatValue];
        }
    });
    return size;
}

- (NSUInteger)diskFreeSystemSpace{
    __block NSUInteger size = 0.0;
    dispatch_sync(self.operationQueue, ^{
        NSError *error=nil;
        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self homePath] error:&error];
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }else{
            NSNumber *freeSystemNumber = [dic objectForKey:NSFileSystemFreeSize];
            size = [freeSystemNumber floatValue];
        }
    });
    return size;
}



#pragma mark 解码MD5
- (NSString *)getDiskCacheWithCodingForKey:(NSString *)key{
    NSString *path=[self getDiskCacheWithCodingForKey:key inPath:self.diskCachePath];
    return path;
}

- (NSString *)getDiskCacheWithCodingForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self MD5StringForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)MD5StringForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    return filename;
}

#pragma mark 清除Tmp文件, Tmp文件生命周期短
/// 清除整个tmp文件夹
- (void)clearAllTmpFolder {
    NSString *tmpPath = NSTemporaryDirectory();
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL res = [manager removeItemAtPath:tmpPath error:nil];
    if (res) {
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败");
    }
}

/// 清除具体某个缓存
- (void)clearOneDetailTmpWithName:(NSString *)tmpName {
    if (tmpName.length == 0) {
        NSLog(@"缓存必须有key");
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cachePath = NSTemporaryDirectory();
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:cachePath];
    for (NSString *fileName in enumerator) {
      if ([fileName isEqualToString:tmpName]) {
          NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
          BOOL res=[manager removeItemAtPath:filePath error:nil];
          if (res) {
              NSLog(@"删除成功");
          } else {
              NSLog(@"删除失败");
          }
      }
    }
}



@end
