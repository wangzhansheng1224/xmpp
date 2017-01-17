//
//  LeftImage.h
//  xmpp
//
//  Created by 王战胜 on 2017/1/17.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftImage : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageV;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

@end
