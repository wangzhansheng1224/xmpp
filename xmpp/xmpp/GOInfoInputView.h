//
//  GOInfoInputView.h
//  GoComIM
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOInfoInputView : UIView

- (instancetype)initWithFrame:(CGRect)frame fieldName:(NSString *)name andLeftStr:(NSString *)leftstr;

- (void)setCornerDirection:(UIRectCorner)direction;

- (void)showPwdBtnShow;

@end
