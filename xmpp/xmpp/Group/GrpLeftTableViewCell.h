//
//  GrpLeftTableViewCell.h
//  xmpp
//
//  Created by 王战胜 on 2017/1/13.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrpLeftTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *LeftName;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *LeftMessageWidth;
@property (strong, nonatomic) IBOutlet UILabel *LeftMessage;

@end
