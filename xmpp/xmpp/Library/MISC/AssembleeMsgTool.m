//
//  AssembleeMsgTool.m
//  DoctorChat
//
//  Created by 王鹏 on 13-2-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "AssembleeMsgTool.h"
//表情文字 开始标记 [
#define BEGIN_FLAG @"["
//表情文字 结束标记 [
#define END_FLAG @"]"
//表情数组
static NSArray *faceArray = nil;
@implementation AssembleeMsgTool

+ (void)getFaceRange:(NSString *)message inArray:(NSMutableArray *)array
{
	if(message == nil || [message length] <= 0)
		return;
	
    //开始标记
	NSRange range = [message rangeOfString:BEGIN_FLAG];
    
    //结束标记
	NSRange endRange = [message rangeOfString:END_FLAG];

	if(range.length > 0 && endRange.length > 0 && endRange.location > range.location)
	{
		if(range.location > 0)
		{
            //添加文字部分到数组中
			[array addObject:[message substringToIndex:range.location]];
            //添加寻找到的表情到数组中
//			[array addObject:[message substringWithRange:NSMakeRange(range.location, endRange.location+1-range.location)]];
//			NSString *str = [message substringFromIndex:endRange.location + 1];
            
            NSString *nextStr = [message substringWithRange:NSMakeRange(range.location, endRange.location + 1 - range.location)];
            NSString *tmpStr = [nextStr substringWithRange:NSMakeRange(1,nextStr.length - 2)];
            
            
            if ([tmpStr rangeOfString:BEGIN_FLAG].location != NSNotFound) {
                nextStr = [nextStr substringWithRange:NSMakeRange(0, [tmpStr rangeOfString:BEGIN_FLAG].location + 1)];
            }
            
            //继续遍历
            if(![nextStr isEqualToString:@""])
            {
                [array addObject:nextStr];
                //NSString *str = [message substringWithRange:NSMakeRange(range.location, [tmpStr rangeOfString:BEGIN_FLAG].location + 1 - range.location)];
                NSString *str = [message substringFromIndex:range.location + nextStr.length];
                [self getFaceRange:str inArray:array];
            }
//			[self getFaceRange:str inArray:array];
		}
		else
		{
//            if (endRange.location - range.location > 4) {
//                NSString *str = [message substringFromIndex:endRange.location + 1];
//                return;
//            }
			NSString *nextStr = [message substringWithRange:NSMakeRange(range.location, endRange.location + 1 - range.location)];
            NSString *tmpStr = [nextStr substringWithRange:NSMakeRange(1,nextStr.length - 2)];
            
            
            if ([tmpStr rangeOfString:BEGIN_FLAG].location != NSNotFound) {
                nextStr = [message substringWithRange:NSMakeRange(range.location, [tmpStr rangeOfString:BEGIN_FLAG].location + 1 - range.location)];
            }
            
			if(![nextStr isEqualToString:@""])
			{
				[array addObject:nextStr];
				NSString *str = [message substringFromIndex:nextStr.length];
				[self getFaceRange:str inArray:array];
			}
			else
				return;
		}
	}
    else if (range.length > 0 && endRange.length > 0 && endRange.location < range.location){
        NSString *nextStr = [message substringWithRange:NSMakeRange(0, endRange.location + 1)];
        [array addObject:nextStr];
        NSString *str = [message substringFromIndex:nextStr.length];
        [self getFaceRange:str inArray:array];
    }
	else
	{
		[array addObject:message];
	}
}

+ (NSMutableArray *)getAssembleArrayWithStr:(NSString *)msgstr
{
	if(msgstr == nil || [msgstr length] <= 0)
		return nil;
	NSMutableArray *array = [NSMutableArray array];
	[self getFaceRange:msgstr inArray:array];
	return array;
}

/**
 *  获取表情文字映射数组
 *
 *  @return 表情文字映射数组
 */
+ (NSArray *)getFaceArray
{
	if(faceArray == nil)
	{
		faceArray = [[NSArray arrayWithObjects:
                     @"[微笑]",
					 @"[撇嘴]",
					 @"[色]",
					 @"[得意]",
					 @"[害羞]",
					 @"[闭嘴]",
					 @"[睡]",
					 @"[大哭]",
					 @"[尴尬]",
					 @"[发怒]",
					 @"[调皮]",
					 @"[呲牙]",
					 @"[惊讶]",
					 @"[难过]",
					 @"[酷]",
					 @"[冷汗]",
					 @"[抓狂]",
					 @"[吐]",
					 @"[偷笑]",
					 @"[愉快]",
					 @"[白眼]",
					 @"[傲慢]",
					 @"[饥饿]",
					 @"[困]",
					 @"[惊恐]",
					 @"[流汗]",
					 @"[憨笑]",
					 @"[大兵]",
					 @"[奋斗]",
					 @"[疑问]",
					 @"[嘘]",
					 @"[晕]",
					 @"[衰]",
					 @"[骷髅]",
					 @"[敲打]",
					 @"[再见]",
					 @"[抠鼻]",
					 @"[鼓掌]",
					 @"[糗大了]",
					 @"[坏笑]",
					 @"[左哼哼]",
					 @"[右哼哼]",
					 @"[鄙视]",
					 @"[委屈]",
					 @"[快哭了]",
					 @"[亲亲]",
					 @"[吓]",
					 @"[可怜]",
					 @"[菜刀]",
					 @"[西瓜]",
					 @"[啤酒]",
					 @"[篮球]",
					 @"[乒乓]",
					 @"[咖啡]",
					 @"[饭]",
					 @"[猪头]",
					 @"[玫瑰]",
					 @"[凋谢]",
					 @"[示爱]",
					 @"[爱心]",
					 @"[心碎]",
					 @"[蛋糕]",
					 @"[闪电]",
					 @"[炸弹]",
					 @"[刀]",
					 @"[足球]",
					 @"[瓢虫]",
					 @"[便便]",
					 @"[月亮]",
					 @"[太阳]",
					 @"[礼物]",
					 @"[拥抱]",
					 @"[强]",
					 @"[弱]",
					 @"[握手]",
					 @"[抱拳]",
					 @"[勾引]",
					 @"[拳头]",
					 @"[差劲]",
					 @"[爱你]",
					 @"[NO]",
					 @"[OK]",
					 nil] copy];

	}
	return faceArray;
}

/**
 *  判断是否是内置表情图片
 *
 *  @param str 待判断表情文字
 *
 *  @return 返回YES or NO
 */
+ (BOOL)isFaceStr:(NSString *)str
{
    //获取表情文字 映射数组
	NSArray *array = [self getFaceArray];
    
    //判断该数组是否包含 该表情文字str
	if([array containsObject:str])
	{
        //存在
		return YES;
	}
    //不存在
	return NO;
}

/**
 *  获取表情图片文件名
 *
 *  @param str 映射文字
 *
 *  @return 返回表情图片文件名
 */
+ (NSString *)getFaceImageWithStr:(NSString *)str
{
    //获取表情文字 映射数组
	NSArray *array = [self getFaceArray];
    //获取 选取文字 在 映射数组中的索引位置
	NSInteger idx = [array indexOfObject:str];
    //如果索引位置存在
	if(idx != NSNotFound)
	{
        //返回当前索引对应的表情图片名
		return [NSString stringWithFormat:@"smiley_%@.png", @(idx).stringValue];
	}
	return nil;
}

@end
