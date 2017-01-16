//
//  GrpChatViewController.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/10.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "GrpChatViewController.h"
#import "XMPPManager.h"
#import "GrpLeftTableViewCell.h"
#import "RightTableViewCell.h"

@interface GrpChatViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *messageArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *ToolBarView;
@property (nonatomic, strong) UITextField *tf;
//切换键盘
@property (nonatomic, strong) UIButton *changeKeyBoardButton;
@end

@implementation GrpChatViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.title=_roomName;
        self.automaticallyAdjustsScrollViewInsets=NO;
        self.view.backgroundColor=BGCOLOR;
        [self.view addSubview:self.tableView];
        [self.view addSubview:self.ToolBarView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMessage:) name:kXMPP_MESSAGE_GROUPS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillSHow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)acceptMessage:(NSNotification *)notification
{
    [self.messageArr addObject:notification.object];
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIView *)ToolBarView{
    if (!_ToolBarView) {
        _ToolBarView=[[UIView alloc]initWithFrame:CGRectMake(0, IMScreenHeight-50, IMScreenWidth, 50)];
        _ToolBarView.backgroundColor=[UIColor whiteColor];
        
        _tf=[[UITextField alloc]initWithFrame:CGRectMake(20, 10, 300, 30)];
        _tf.backgroundColor=[UIColor whiteColor];
        _tf.layer.borderWidth=0.5;
        _tf.layer.borderColor=[UIColor blackColor].CGColor;
        _tf.layer.cornerRadius=5;
        _tf.layer.masksToBounds=YES;
        _tf.delegate=self;
        _tf.returnKeyType = UIReturnKeySend;
        [_ToolBarView addSubview:_tf];
        
        _changeKeyBoardButton = [[UIButton alloc] initWithFrame:CGRectMake(350, 10, 30, 30)];
        [_changeKeyBoardButton setBackgroundImage:[UIImage imageNamed:@"xiaonie_icon"] forState:UIControlStateNormal];
        [_changeKeyBoardButton addTarget:self action:@selector(tapChangeKeyBoardButton) forControlEvents:UIControlEventTouchUpInside];
        [_ToolBarView addSubview:self.changeKeyBoardButton];
        
    }
    return _ToolBarView;
}
- (void)tapChangeKeyBoardButton{
    NSLog(@"弹出表情");
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[XMPPManager defaultManager]sendGrpMessage:textField.text];
    textField.text=@"";
    return YES;
}
- (void)tableViewScrollToBottom
{
    if (_messageArr.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_messageArr.count-1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, IMScreenWidth, IMScreenHeight-50-64) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.backgroundColor=BGCOLOR;
        //消除分割线
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView=[[UIView alloc]init];
        [_tableView registerNib:[UINib nibWithNibName:@"GrpLeftTableViewCell" bundle:nil] forCellReuseIdentifier:@"left"];
        [_tableView registerNib:[UINib nibWithNibName:@"RightTableViewCell" bundle:nil] forCellReuseIdentifier:@"right"];
        //点击隐藏输入框
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [_tableView addGestureRecognizer:tapGesture];
        _tableView.rowHeight=80;
    }
    return _tableView;
}

- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *messageDic = self.messageArr[indexPath.row];
    
    NSRange range1=[messageDic[@"to"] rangeOfString:@"@localhost"];
    NSString *to=[messageDic[@"to"] substringToIndex:range1.location];
    NSRange range2=[messageDic[@"from"] rangeOfString:@"/"];
    NSString *from=[messageDic[@"from"] substringFromIndex:range2.location+1];
    if ([to isEqualToString:from]) {
        RightTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"right" forIndexPath:indexPath];
        cell.RightLabel.text=messageDic[@"body"];
        CGSize titleSize = [messageDic[@"body"] sizeWithFont:cell.RightLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.MessageRightWidth.constant=titleSize.width+25;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        GrpLeftTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"left" forIndexPath:indexPath];
        NSString *name=messageDic[@"from"];
        NSRange rang=[name rangeOfString:@"/"];
        name=[name substringFromIndex:rang.location+1];
        cell.LeftName.text=name;
        cell.LeftMessage.text=messageDic[@"body"];
        CGSize titleSize = [messageDic[@"body"] sizeWithFont:cell.LeftMessage.font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.LeftMessageWidth.constant=titleSize.width+25;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *messageDic = self.messageArr[indexPath.row];
    
    NSRange range1=[messageDic[@"to"] rangeOfString:@"@localhost"];
    NSString *to=[messageDic[@"to"] substringToIndex:range1.location];
    NSRange range2=[messageDic[@"from"] rangeOfString:@"/"];
    NSString *from=[messageDic[@"from"] substringFromIndex:range2.location+1];
    if ([to isEqualToString:from]) {
        return 70;
    }else{
        return 80;
    }
}

- (void)keyboardWillSHow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        _ToolBarView.transform = CGAffineTransformMakeTranslation(0, -size.height);
        CGRect rect = _tableView.frame;
        rect.size.height = IMScreenHeight-50-64-size.height;
        _tableView.frame = rect;
        [self tableViewScrollToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        _ToolBarView.transform = CGAffineTransformIdentity;
        CGRect rect = _tableView.frame;
        rect.size.height = IMScreenHeight-50-64;
        _tableView.frame = rect;
    }];
}

- (void)dealloc{
    [[XMPPManager defaultManager].xmppRoom leaveRoom];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPP_MESSAGE_GROUPS object:nil];
}

- (NSMutableArray *)messageArr{
    ArrayLazyLoad(_messageArr);
}


@end
