//
//  GOInfoInputView.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-25.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOInfoInputView : UIView

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *iconView;
//展示登录名的按钮
@property (nonatomic, strong) UIButton *userNameBtn;
@property (nonatomic, strong) UIButton *showPwdBtn;
@property (nonatomic, strong) UIButton *clearTextBtn;

@property (nonatomic, strong) UIView *showView;

- (instancetype)initWithFrame:(CGRect)frame fieldName:(NSString *)name andLeftStr:(NSString *)leftstr;

- (instancetype)initWithFrame:(CGRect)frame labelName:(NSString *)name;

- (void)setCornerDirection:(UIRectCorner)direction;

- (void)showPwdBtnShow;

@end
