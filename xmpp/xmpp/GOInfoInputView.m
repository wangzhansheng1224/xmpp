//
//  GOInfoInputView.m
//  GoComIM
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "GOInfoInputView.h"
#import "UIView+PPCategory.h"


@interface GOInfoInputView()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton *showPwdBtn;
@property (nonatomic, strong) UIButton *clearTextBtn;
@property (nonatomic, strong) UIView *showView;

@end

@implementation GOInfoInputView

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
        _textField.clearsOnBeginEditing = NO;
        _textField.rightViewMode = UITextFieldViewModeWhileEditing;
        
        //左侧图标
        _iconView = [[UIImageView alloc] init];
        
        //密码右侧显示密码
        _showPwdBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, frame.size.height / 2 - 8, 18, 14)];
        [_showPwdBtn setBackgroundImage:[UIImage imageNamed:@"icon_eye_close"] forState:UIControlStateNormal];
        [_showPwdBtn setBackgroundImage:[UIImage imageNamed:@"icon_eye_open"] forState:UIControlStateSelected];
        [_showPwdBtn addTarget:self action:@selector(showPwdBtnClick) forControlEvents:UIControlEventTouchUpInside];
            
        //密码右侧清除功能
        _clearTextBtn = [[UIButton alloc] initWithFrame:CGRectMake(_showPwdBtn.frame.origin.x + 30, frame.size.height / 2 - 8, 14, 14)];
        [_clearTextBtn setBackgroundImage:[UIImage imageNamed:@"icon_close_normal"] forState:UIControlStateNormal];
        [_clearTextBtn setBackgroundImage:[UIImage imageNamed:@"icon_close_click"] forState:UIControlStateHighlighted];
        [_clearTextBtn addTarget:self action:@selector(clearTextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
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
            
            //左侧名字
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 12.0/568*IMScreenHeight, 60, 26)];
            label.text=leftstr;
            [self addSubview:label];
            
            //右侧图标
            self.iconView.frame = CGRectMake(self.width-10-26, 13.0/568*IMScreenHeight, 20, 20);
            self.iconView.image = [UIImage imageNamed:name];
            [self addSubview:self.iconView];
            
            //
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

- (void)showPwdBtnClick{
    _showPwdBtn.selected = !_showPwdBtn.selected;
    _textField.secureTextEntry = !_textField.secureTextEntry;

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

@end
