//
//  SWHSpotlightView.h
//  
//
//  Created by skonb on 2013/10/01.
//  Copyright (c) 2013年 7woods. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SWHSpotlightView;
typedef void(^SWHSpotlightViewCompletionBlock)(SWHSpotlightView* spotlightView);
@interface SWHSpotlightView : UIView
@property (nonatomic, assign) CGPoint centerOfHole;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat radiusOfHole;
@property (nonatomic, assign) BOOL zoomInOutAnimation;
-(void)moveCenterToPoint:(CGPoint)anotherCenter animated:(BOOL)animated;
-(void)changeToRadius:(CGFloat)anotherRadius animated:(BOOL)animated;
-(void)moveCenterToPoint:(CGPoint)anotherCenter duration:(NSTimeInterval)duration completion:(SWHSpotlightViewCompletionBlock)completion;
-(void)changeToRadius:(CGFloat)anotherRadius duration:(NSTimeInterval)duration completion:(SWHSpotlightViewCompletionBlock) completion;



@end
