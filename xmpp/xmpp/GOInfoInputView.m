//
//  GOInfoInputView.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-25.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOInfoInputView.h"
//#import "PPCoreMacros.h"
//#import "PPCore.h"
#import <QuartzCore/QuartzCore.h>
//#import "UIImage+WB.h"
#import "UIView+PPCategory.h"

#define LABEL_HEIGHT 15.0

@interface GOInfoInputView()<UITextFieldDelegate>

@property (nonatomic, copy)NSString *tmpString;

@end

@implementation GOInfoInputView

- (void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        // 背景颜色
        self.backgroundColor = [UIColor whiteColor];
        //输入框
        _textField = [[UITextField alloc] initWithFrame:self.bounds];
        _textField.borderStyle = UITextBorderStyleNone;
        //带删除按钮
        _textField.clearButtonMode = YES;
        _textField.font = [UIFont fontWithName:@"Arial" size:16.0];
        _textField.delegate = self;
        _textField.clearsOnBeginEditing = NO;
        _userNameBtn = [[UIButton alloc] init];
        _userNameBtn.hidden = YES;
        
        _iconView = [[UIImageView alloc] init];
        
        //12.05两个按钮向右移10像素
        _showPwdBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, frame.size.height / 2 - 8, 18, 14)];
        //_showPwdBtn.hidden = YES;
        
        [_showPwdBtn setBackgroundImage:[UIImage imageNamed:@"icon_eye_close"] forState:UIControlStateNormal];
        [_showPwdBtn setBackgroundImage:[UIImage imageNamed:@"icon_eye_open"] forState:UIControlStateSelected];
        [_showPwdBtn addTarget:self action:@selector(showPwdBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
        
        _clearTextBtn = [[UIButton alloc] initWithFrame:CGRectMake(_showPwdBtn.frame.origin.x + 30, frame.size.height / 2 - 8, 14, 14)];
        
        [_clearTextBtn setBackgroundImage:[UIImage imageNamed:@"icon_close_normal"] forState:UIControlStateNormal];
        [_clearTextBtn setBackgroundImage:[UIImage imageNamed:@"icon_close_click"] forState:UIControlStateHighlighted];
        [_clearTextBtn addTarget:self action:@selector(clearTextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
        
        self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, self.height)];
        
        [self.showView addSubview:self.clearTextBtn];
        [self.showView addSubview:self.showPwdBtn];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame fieldName:(NSString *)name andLeftStr:(NSString *)leftstr
{
    if (self = [self initWithFrame:frame]) {
        //        UILabel *nameLabel = nil;
        if (name) {
            
            //添加透明度
            self.alpha=0.5;
            //添加背景图
            [self setBackgroundImage:[UIImage imageNamed:@"btn_white"]];
            //textfild布局
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 10.0/568*IMScreenHeight, 60, 26)];
            label.text=leftstr;
            [self addSubview:label];
            
            self.iconView.frame = CGRectMake(self.width-10-26, 13.0/568*IMScreenHeight, 20, 20);
            self.iconView.image = [UIImage imageNamed:name];
            [self addSubview:self.iconView];
            
//            CGFloat inputHeight = 0;
//            if (isFourInchScreen) {
//                inputHeight=   CGRectGetHeight(self.bounds);
//            }else
//            {
//             inputHeight=   CGRectGetHeight(self.bounds);
//            
//            }
            self.textField.frame = CGRectMake(60 + 20.0, 2.0, CGRectGetWidth(self.textField.frame) - CGRectGetWidth(self.iconView.frame) - 20.0 - 60 - 20, CGRectGetHeight(self.bounds));
            self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            [self addSubview:self.textField];
            
            self.userInteractionEnabled = YES;
        }
    }
    
    return self;
}

- (void)showPwdBtnShow{
    self.textField.rightView = self.showView;
}


- (instancetype)initWithFrame:(CGRect)frame labelName:(NSString *)name
{
    if (self = [self initWithFrame:frame]) {
        UILabel *nameLabel = nil;
        if (name) {
            //CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:14.0]];
            CGFloat labelWidth = 80;
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.5 * (frame.size.height - LABEL_HEIGHT), labelWidth, LABEL_HEIGHT)];
            nameLabel.font = [UIFont systemFontOfSize:14.0];
            nameLabel.backgroundColor = [UIColor whiteColor];
            nameLabel.text = name;
            nameLabel.textColor = UICOLOR_RGB(112.0, 112.0, 112.0);
            nameLabel.textAlignment = NSTextAlignmentLeft;
            [self addSubview:nameLabel];
            
            self.textField.frame = CGRectMake(CGRectGetWidth(nameLabel.frame) + 20.0, 1.6, CGRectGetWidth(self.textField.frame) - CGRectGetWidth(nameLabel.frame) - 20.0, CGRectGetHeight(self.bounds));
            self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            [self addSubview:self.textField];
            
            self.userInteractionEnabled = YES;
        }
    }
    
    return self;
}

- (void)showPwdBtnClick{
    
    self.tmpString = _textField.text;
    _textField.text = @"";
    _showPwdBtn.selected = !_showPwdBtn.selected;
    _textField.secureTextEntry = !_textField.secureTextEntry;
    _textField.font = [UIFont fontWithName:@"Arial" size:16.0];
    _textField.text = self.tmpString;
    
}

- (void)clearTextBtnClick{
    _textField.text = @"";
}

- (void)setCornerDirection:(UIRectCorner)direction
{
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:direction
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;

    
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
   
}


//
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    
//    if([textField.text isEqual:@""]){
//        //textField.text = @"Password";
//        //textField.secureTextEntry = NO;
//        textField.font = [UIFont systemFontOfSize:14];
//    }
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
