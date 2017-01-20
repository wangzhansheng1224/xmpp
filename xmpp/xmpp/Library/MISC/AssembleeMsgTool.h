//
//  AssembleeMsgTool.h
//  DoctorChat
//
//  Created by 王鹏 on 13-2-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssembleeMsgTool : NSObject

/**
 *  给定表情文本混排文本解析成图文数组
 *
 *  @param msgstr 给定表情文本混排文本
 *
 *  @return 返回数组
 */
+ (NSMutableArray *)getAssembleArrayWithStr:(NSString *)msgstr;

/**
 *  判断是否是表情图片
 *
 *  @param str 表情文字
 *
 *  @return 返回YES or NO
 */
+ (BOOL)isFaceStr:(NSString *)str;

/**
 *  获取表情文字映射数组
 *
 *  @return 表情文字映射数组
 */
+ (NSArray *)getFaceArray;

/**
 *  获取表情图片文件名
 *
 *  @param str 映射文字
 *
 *  @return 返回表情图片文件名
 */
+ (NSString *)getFaceImageWithStr:(NSString *)str;
@end
