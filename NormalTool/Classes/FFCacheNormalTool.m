//
//  FFCacheNormalTool.m
//  BtnDemo
//
//  Created by 万材 on 2021/7/16.
//  Copyright © 2021 万材. All rights reserved.
//

#import "FFCacheNormalTool.h"

@implementation FFCacheNormalTool

+ (NSMutableArray *)getDataStructureKeyArrayWithDataDic:(NSDictionary *)dataDic type:(FFCacheType)cacheType {
    NSMutableArray *keys = [NSMutableArray array];
    switch (cacheType) {
        case FFCacheGlobalType: {
            NSArray *data = [dataDic objectForKey:globalPath];
            keys = [NSMutableArray arrayWithArray:data];
        }
            break;
        case FFCacheUserMsgType: {
            NSArray *data = [dataDic objectForKey:userMsgPath];
            keys = [NSMutableArray arrayWithArray:data];
        }
            break;
        case FFCacheLiveRoomType: {
            NSArray *data = [dataDic objectForKey:liveRoomPath];
            keys = [NSMutableArray arrayWithArray:data];
        }
            break;
            
        default:
            break;
    }
    return keys;
}

/// 新增缓存key
+ (void)insertDataStructureKeyWithDataDic:(NSMutableDictionary *)dataDic dataArr:(NSArray *)dataArr type:(FFCacheType)cacheType {
    switch (cacheType) {
        case FFCacheGlobalType: {
            [dataDic setObject:dataArr forKey:globalPath];
        }
            break;
        case FFCacheUserMsgType: {
            [dataDic setObject:dataArr forKey:userMsgPath];
        }
            break;
        case FFCacheLiveRoomType: {
            [dataDic setObject:dataArr forKey:liveRoomPath];
        }
            break;
        default:
            break;
    }
}


@end
