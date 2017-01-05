//
//  RightTableViewCell.h
//  xmpp
//
//  Created by 王战胜 on 2017/1/5.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *RightLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *MessageRightWidth;

@end
