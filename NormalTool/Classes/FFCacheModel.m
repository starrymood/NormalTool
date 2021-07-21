//
//  FFCacheModel.m
//  BlackHole
//
//  Created by 万材 on 2021/7/15.
//  Copyright © 2021 冯振伟. All rights reserved.
//

#import "FFCacheModel.h"

@implementation FFCacheModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isCanClear    = YES;
        _invalidTime   = 10;
        _isNeedRefresh = YES;
    }
    return self;
}


@end
