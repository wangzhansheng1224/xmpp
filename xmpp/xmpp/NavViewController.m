//
//  NavViewController.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "NavViewController.h"

@interface NavViewController ()

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏的背景色
    self.navigationBar.barTintColor=[UIColor colorWithWhite:0.2 alpha:1];
    
    //导航栏左右item的颜色
    self.navigationBar.tintColor=[UIColor whiteColor];
    
    //导航栏字体大小和颜色
    self.navigationBar.titleTextAttributes=@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0],NSForegroundColorAttributeName:[UIColor whiteColor]};
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    //白色
    return UIStatusBarStyleLightContent;
    //黑色
    //    return UIStatusBarStyleDefault;
}
@end
