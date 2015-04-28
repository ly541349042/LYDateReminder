//
//  PublicModel.m
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import "PublicModel.h"

@implementation PublicModel

+(PublicModel*)sharedModel
{
    static PublicModel*_model;
    if (!_model) {
        _model = [[PublicModel alloc]init];
    }
    return _model;
}

@end
