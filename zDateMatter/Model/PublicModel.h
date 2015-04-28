//
//  PublicModel.h
//  zDateMatter
//
//  Created by hou on 15/3/31.
//  Copyright (c) 2015年 hou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicModel : NSObject

+(PublicModel*)sharedModel;

@property(nonatomic,retain)NSString*mMatter;
@property(nonatomic,retain)NSDate*mDate;
@property(nonatomic,assign)int mType;

@end
