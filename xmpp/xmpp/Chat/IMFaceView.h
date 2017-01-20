//
//  IMFaceView.h
//  DoctorChat
//
//  Created by 王鹏 on 13-3-1.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IMFaceViewDelegate;
@interface IMFaceView : UIView<UIScrollViewDelegate>
@property (nonatomic, assign) id <IMFaceViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageCtrl;
@end

@protocol IMFaceViewDelegate <NSObject>

@optional
- (void)faceViewDeleteLastFace:(IMFaceView *)faceView;
- (void)faceView:(IMFaceView *)faceView addFaceStr:(NSString *)facestr;
- (void)faceViewSend:(IMFaceView *)faceView;
@end
