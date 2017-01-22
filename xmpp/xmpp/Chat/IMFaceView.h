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
{
	UIScrollView *_scrollView;
	UIPageControl *_pageCtrl;
}
@property (nonatomic, assign) id <IMFaceViewDelegate> delegate;
@end

@protocol IMFaceViewDelegate <NSObject>

@optional
- (void)faceViewDeleteLastFace:(IMFaceView *)faceView;
- (void)faceView:(IMFaceView *)faceView addFaceStr:(NSString *)facestr;
- (void)faceViewSend:(IMFaceView *)faceView;
@end