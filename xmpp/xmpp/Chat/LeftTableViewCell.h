//
//  LeftTableViewCell.h
//  xmpp
//
//  Created by 王战胜 on 2017/1/5.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface LeftTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *LeftLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *LeftMessageWidth;


@end
