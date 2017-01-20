//
//  ChatViewController.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/4.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPManager.h"
#import "LeftTableViewCell.h"
#import "RightTableViewCell.h"
#import "UIImage+PPCategory.h"
#import "RightImage.h"
#import "LeftImage.h"
#import "IMFaceView.h"
#import "UIView+PPCategory.h"
#import "AssembleeMsgTool.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,IMFaceViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *ToolBarView;
@property (nonatomic, strong) UITextField *tf;
@property (nonatomic, strong) UIImagePickerController *picker;
//切换表情键盘
@property (nonatomic, strong) UIButton *changeKeyBoardButton;
//加号
@property (nonatomic, strong) UIButton *addButton;
/** 聊天记录*/
@property (nonatomic, strong) NSMutableArray *chatHistory;
//表情View
@property (nonatomic, strong) IMFaceView *kbfaceView;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=self.chatJID.user;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=BGCOLOR;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.ToolBarView];
    [self getChatHistory];
    [self addNotifications];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatHistory) name:kXMPP_MESSAGE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillSHow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (UIView *)ToolBarView{
    if (!_ToolBarView) {
        _ToolBarView=[[UIView alloc]initWithFrame:CGRectMake(0, IMScreenHeight-50, IMScreenWidth, 50)];
        _ToolBarView.backgroundColor=[UIColor whiteColor];
        
        _tf=[[UITextField alloc]initWithFrame:CGRectMake(20, 10, IMScreenWidth-120, 30)];
        _tf.backgroundColor=[UIColor whiteColor];
        _tf.layer.borderWidth=0.5;
        _tf.layer.borderColor=[UIColor darkGrayColor].CGColor;
        _tf.layer.cornerRadius=5;
        _tf.layer.masksToBounds=YES;
        _tf.borderStyle = UITextBorderStyleRoundedRect;
        _tf.delegate=self;
        _tf.returnKeyType = UIReturnKeySend;
        [_ToolBarView addSubview:_tf];
        
        _changeKeyBoardButton = [[UIButton alloc] initWithFrame:CGRectMake(IMScreenWidth-80, 10, 30, 30)];
        [_changeKeyBoardButton setBackgroundImage:[UIImage imageNamed:@"xiaonie_icon"] forState:UIControlStateNormal];
        [_changeKeyBoardButton addTarget:self action:@selector(poppingFaceView:) forControlEvents:UIControlEventTouchUpInside];
        [_ToolBarView addSubview:_changeKeyBoardButton];
        
        
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(IMScreenWidth-40, 10, 30, 30)];
        [_addButton setBackgroundImage:[UIImage imageNamed:@"jia_more_icon"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(tapChangeKeyBoardButton) forControlEvents:UIControlEventTouchUpInside];
        [_ToolBarView addSubview:_addButton];
        
        _kbfaceView = [[IMFaceView alloc]initWithFrame:CGRectMake(0, self.view.height, self.view.width, 190)];
        _kbfaceView.backgroundColor = [UIColor grayColor];
        _kbfaceView.delegate=self;
        [self.view addSubview:_kbfaceView];
        
    }
    return _ToolBarView;
}

- (void)poppingFaceView:(UIButton *)btn{
    [self.view endEditing:YES];
    btn.selected=!btn.selected;
    if (btn.selected) {
        [UIView animateWithDuration:0.3 animations:^{
            _kbfaceView.transform = CGAffineTransformMakeTranslation(0,-190);
            _ToolBarView.transform = CGAffineTransformMakeTranslation(0,-190);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _kbfaceView.transform = CGAffineTransformIdentity;
            _ToolBarView.transform = CGAffineTransformIdentity;
        }];
    }
    
}
- (void)tapChangeKeyBoardButton{
    NSLog(@"发送图片");
    [self sendImage];
}

- (void)sendImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
//    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    picker.allowsEditing =YES;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark pickerController代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *imageNew = info[UIImagePickerControllerOriginalImage];
//    imageNew=[imageNew scaleImageWithWidth:200];
    //设置image的尺寸
//    CGSize imagesize = imageNew.size;
//    imagesize.width =100;
//    imagesize.height =100*imageNew.size.height/imageNew.size.width;
//    //对图片大小进行压缩--
//    imageNew = [self imageWithImage:imageNew scaledToSize:imagesize];
    NSData *imageData=UIImageJPEGRepresentation(imageNew, 0.01);
//    NSData *imageData = [self imageData:imageNew];
    
    
    [[XMPPManager defaultManager]sendMessageWithData:imageData bodyName:@"[图片]" toUser:_chatJID];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/** 把图片缩小到指定的宽度范围内为止 */
-(NSData *)imageData:(UIImage *)myimage

{
    
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    
    if (data.length>100*1024) {
        
        if (data.length>1024*1024) {//1M以及以上
            
            data=UIImageJPEGRepresentation(myimage, 0.1);
            
        }else if (data.length>512*1024) {//0.5M-1M
            
            data=UIImageJPEGRepresentation(myimage, 0.5);
            
        }else if (data.length>200*1024) {//0.25M-0.5M
            
            data=UIImageJPEGRepresentation(myimage, 0.9);
            
        }
        
    }
    
    return data;
    
}

//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

#pragma mark - UITextField代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[XMPPManager defaultManager]sendMessage:_tf.text toUser:self.chatJID];
    _tf.text=@"";
    [self tableViewScrollToBottom];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if ([string isEqualToString:@""]) {
        [self deleteLastCharOrFace];
        return NO;
    }else{
        return YES;

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
        [_tableView registerNib:[UINib nibWithNibName:@"LeftTableViewCell" bundle:nil] forCellReuseIdentifier:@"left"];
        [_tableView registerNib:[UINib nibWithNibName:@"RightTableViewCell" bundle:nil] forCellReuseIdentifier:@"right"];
        [_tableView registerNib:[UINib nibWithNibName:@"RightImage" bundle:nil] forCellReuseIdentifier:@"rightImage"];
        [_tableView registerNib:[UINib nibWithNibName:@"LeftImage" bundle:nil] forCellReuseIdentifier:@"leftImage"];
        //点击隐藏输入框
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [_tableView addGestureRecognizer:tapGesture];
        _tableView.rowHeight=70;
    }
    return _tableView;
}

- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *message = self.chatHistory[indexPath.row];
    NSString *identifier = message.isOutgoing?@"right":@"left";
    if ([identifier isEqualToString:@"right"]) {
        
        if ([message.body isEqualToString:@"[图片]"]) {
            RightImage *cell = [tableView dequeueReusableCellWithIdentifier:@"rightImage" forIndexPath:indexPath];
            XMPPMessage *msg = message.message;
            NSString *base64str = [[msg elementForName:@"attachment"] stringValue];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
            UIImage *receiveImage = [[UIImage alloc]initWithData:data];
            cell.imageV.image=receiveImage;
            if (receiveImage.size.height>receiveImage.size.width) {
                cell.imageHeight.constant=200;
                cell.imageWidth.constant=200*receiveImage.size.width/receiveImage.size.height;
            }else{
                cell.imageWidth.constant=200;
                cell.imageHeight.constant=200*receiveImage.size.height/receiveImage.size.width;
            }
            cell.imageV.layer.cornerRadius=5;
            cell.imageV.layer.masksToBounds=YES;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
            
        }else{
            RightTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"right" forIndexPath:indexPath];
            cell.RightLabel.text=message.body;
            CGSize titleSize = [message.body sizeWithFont:cell.RightLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
            cell.MessageRightWidth.constant=titleSize.width+25;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    }else{
        if ([message.body isEqualToString:@"[图片]"]) {
            LeftImage *cell = [tableView dequeueReusableCellWithIdentifier:@"leftImage" forIndexPath:indexPath];
            XMPPMessage *msg = message.message;
            NSString *base64str = [[msg elementForName:@"attachment"] stringValue];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
            UIImage *receiveImage = [[UIImage alloc]initWithData:data];
            cell.imageV.image=receiveImage;
            if (receiveImage.size.height>receiveImage.size.width) {
                cell.imageHeight.constant=200;
                cell.imageWidth.constant=200*receiveImage.size.width/receiveImage.size.height;
            }else{
                cell.imageWidth.constant=200;
                cell.imageHeight.constant=200*receiveImage.size.height/receiveImage.size.width;
            }
            cell.imageV.layer.cornerRadius=5;
            cell.imageV.layer.masksToBounds=YES;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            LeftTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"left" forIndexPath:indexPath];
            cell.LeftLabel.text=message.body;
            CGSize titleSize = [message.body sizeWithFont:cell.LeftLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
            cell.LeftMessageWidth.constant=titleSize.width+25;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *message = self.chatHistory[indexPath.row];
    if ([message.body isEqualToString:@"[图片]"]){
        XMPPMessage *msg = message.message;
        NSString *base64str = [[msg elementForName:@"attachment"] stringValue];
        NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
        UIImage *receiveImage = [[UIImage alloc]initWithData:data];
        if (receiveImage.size.height>receiveImage.size.width) {
            return 200+20;
        }else{
            return 200*receiveImage.size.height/receiveImage.size.width+20;
        }
        
        
    }else{
        return 70;
    }
}

- (void)getChatHistory
{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPManager defaultManager].xmppMessageArchivingCoreDataStorage;
    //查询的时候要给上下文
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJID.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil) {
        self.chatHistory = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    }
    
    [self.tableView reloadData];
    
    [self tableViewScrollToBottom];
}

- (void)tableViewScrollToBottom
{
    if (_chatHistory.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_chatHistory.count-1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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

#pragma mark kbfaceView代理
- (void)faceView:(IMFaceView *)faceView addFaceStr:(NSString *)facestr{
    _tf.text=[_tf.text stringByAppendingString:facestr];
}
- (void)faceViewDeleteLastFace:(IMFaceView *)faceView{
    [self deleteLastCharOrFace];
}
//删除最后一个字符
- (void)deleteLastCharOrFace{
    NSMutableArray *array = [AssembleeMsgTool getAssembleArrayWithStr:_tf.text];
    if(array == nil || [array count] <= 0)
        return;
    NSString *str = [array lastObject];
    
    if([AssembleeMsgTool isFaceStr:str])
    {
        [array removeLastObject];
        NSString *str1 = [NSString stringWithFormat:@"%@", [array componentsJoinedByString:@""]];
        _tf.text = str1;
    }
    else if ([self stringContainsEmoji:str]){
        NSMutableString *mutStr = [NSMutableString stringWithString:str];
        
        [array removeLastObject];
        NSString *str1 = [NSString stringWithFormat:@"%@%@", [array componentsJoinedByString:@""], [mutStr substringToIndex:mutStr.length - 2]];
        _tf.text = str1;
    }
    else
    {
        NSMutableString *mutStr = [NSMutableString stringWithString:str];
        [mutStr deleteCharactersInRange:NSMakeRange([mutStr length] - 1, 1)];
        [array removeLastObject];
        NSString *str1 = [NSString stringWithFormat:@"%@%@", [array componentsJoinedByString:@""], mutStr];
        _tf.text = str1;
    }

}
- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
         
     }];
    return returnValue;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPP_MESSAGE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

@end
