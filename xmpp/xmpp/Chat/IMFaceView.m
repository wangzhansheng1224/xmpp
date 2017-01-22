//
//  IMFaceView.m
//  DoctorChat
//
//  Created by 王鹏 on 13-3-1.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFaceView.h"
#import "UIView+PPCategory.h"
//#import "UIScrollView+PPCategory.h"
//#import "PPCore.h"
#import "AssembleeMsgTool.h"
//#import "AppDelegate.h"

@implementation IMFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self layoutItems];
    }
    return self;
}

- (void)layoutItems
{
	_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, 147)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.backgroundColor = UICOLOR_RGB(235, 235, 235);
//	NSArray *faceArray = [NSArray arrayWithObjects:@"1-18-3.png",@"1-18-3.png", nil];
	CGFloat startX = 10.0/320*IMScreenWidth;
	CGFloat startY = 10.0f;
	CGFloat paddingX = 8.0/320*IMScreenWidth;
	CGFloat paddingY = 10.0f;
	CGFloat wd = 30.0/320*IMScreenWidth;
	CGFloat hi = 30.0/320*IMScreenWidth;
	NSInteger PNUM = 24;
	NSInteger itemNum = 82;
    NSInteger page = (itemNum-1)/PNUM + 1;
	
	for (NSInteger i = 0; i < page; i++) {
		CGFloat x = self.width * i + startX;
		CGFloat y = startY;
		NSInteger n = 0;
		for (NSInteger j = 0; j < PNUM;j++) {
			if(i*PNUM+j < itemNum)
			{
				NSInteger idx = i * PNUM + j;
				
				UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
				btn.frame = CGRectMake(x, y, wd, hi);
				btn.tag = idx;
				[btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"smiley_%ld.png", (long)idx]] forState:UIControlStateNormal];
				[btn addTarget:self action:@selector(faceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
				[_scrollView addSubview:btn];
				
				x = x + paddingX +wd;
				n++;
				if(n % 8 == 0)
				{
					x = self.width*i + startX;
					y += paddingY + hi;
				}
			}
		}
		
	}
	
	[_scrollView setContentSize:CGSizeMake(self.width * page, _scrollView.height)];
	_scrollView.delegate = self;
	[self addSubview:_scrollView];
	
	UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(0, _scrollView.bottom, IMScreenWidth, 44)];
    imgv.backgroundColor = [UIColor grayColor];
	//imgv.image = [[UIImage imageNamed:@"topbarbg_ios7"] resizableImage];
	[self addSubview:imgv];
	
	
	UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	delBtn.frame = CGRectMake(0, _scrollView.bottom, 70, 40);
	//[delBtn setImage:[UIImage imageNamed:@"emotion_del.png"] forState:UIControlStateNormal];
    delBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
	[delBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //[delBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self addSubview:delBtn];
	
	_pageCtrl = [[UIPageControl alloc]initWithFrame:CGRectMake(70, _scrollView.bottom, self.width - 140, 40)];
    _pageCtrl.numberOfPages = page;
	_pageCtrl.currentPage = 0;
	[_pageCtrl addTarget:self action:@selector(pageCtrlChanged:) forControlEvents:UIControlEventValueChanged];
	_pageCtrl.backgroundColor = [UIColor clearColor];
	[self addSubview:_pageCtrl];
	
	UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	sendBtn.frame = CGRectMake(self.width - 65, _scrollView.bottom+5, 60, 30);
	//[sendBtn setBackgroundImage:[UIImage imageNamed:@"login_btnbj"] forState:UIControlStateNormal];
	[sendBtn setTitle:@"发送" forState:UIControlStateNormal];
	sendBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
	[sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:sendBtn];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)faceBtnClick:(UIButton *)button
{
	if([self.delegate respondsToSelector:@selector(faceView:addFaceStr:)])
	{
		NSInteger idx = button.tag;
		NSArray *tmpArray = [AssembleeMsgTool getFaceArray];
		if(idx >= 0 && idx < [tmpArray count])
			[self.delegate faceView:self addFaceStr:[tmpArray objectAtIndex:idx]];
	}
}

- (void)delBtnClick:(id)sender
{
	if([self.delegate respondsToSelector:@selector(faceViewDeleteLastFace:)])
	{
		[self.delegate faceViewDeleteLastFace:self];
	}
}

- (void)sendBtnClick:(id)sender
{
	if([self.delegate respondsToSelector:@selector(faceViewSend:)])
	{
		[self.delegate faceViewSend:self];
	}
}

- (void)pageCtrlChanged:(id)sender
{
	[_scrollView setContentOffset:CGPointMake(_pageCtrl.currentPage * self.width, 0) animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_pageCtrl.currentPage = _scrollView.contentOffset.x / (self.width - 10);
}
@end
