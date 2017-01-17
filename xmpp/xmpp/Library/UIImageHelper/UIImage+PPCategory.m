//
//  UIImage+PPCategory.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/16.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "UIImage+PPCategory.h"

@implementation UIImage (PPCategory)
/** 把图片缩小到指定的宽度范围内为止 */
- (UIImage *)scaleImageWithWidth:(CGFloat)width{
    if (self.size.width <width || width <= 0) {
        return self;
    }
    CGFloat scale = self.size.width/width;
    CGFloat height = self.size.height/scale;
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 开始上下文 目标大小是 这么大
    UIGraphicsBeginImageContext(rect.size);
    
    // 在指定区域内绘制图像
    [self drawInRect:rect];
    
    // 从上下文中获得绘制结果
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文返回结果
    UIGraphicsEndImageContext();
    return resultImage;
}
@end
