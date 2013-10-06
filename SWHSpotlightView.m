//
//  SWHSpotlightView.m
//  skonb
//
//  Created by skonb on 2013/10/01.
//  Copyright (c) 2013年 7woods. All rights reserved.
//
#define MOVE_DURATION .5
#define MOVE_STEP .05

#define ZOOM_DURATION .5
#define ZOOM_STEP .05

#define ZOOM_IN_OUT_INTERVAL 1.
#define ZOOM_IN_OUT_STEP .05

#import "SWHSpotlightView.h"
@interface SWHSpotlightView()
@property (nonatomic, assign) NSInteger totalZoomStep;
@property (nonatomic, assign) NSInteger currentZoomStep;
@property (nonatomic, assign) NSInteger totalMoveStep;
@property (nonatomic, assign) NSInteger currentMoveStep;
@property (nonatomic, assign) NSInteger currentZoomInOutStep;
@property (nonatomic, strong) NSTimer *zoomTimer;
@property (nonatomic, strong) NSTimer *moveTimer;
@property (nonatomic, strong) NSTimer *zoomInOutTimer;
@property (nonatomic, assign) CGFloat originalRadius;
@property (nonatomic, assign) NSTimeInterval currentMoveDuration;
@property (nonatomic, assign) NSTimeInterval currentZoomDuration;
@property (nonatomic, copy) SWHSpotlightViewCompletionBlock currentMoveCompletionBlock;
@property (nonatomic, copy) SWHSpotlightViewCompletionBlock currentZoomCompletionBlock;
@end

@implementation SWHSpotlightView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
        self.radiusOfHole = 0;
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [self.fillColor setFill];
    CGRect holeRect = CGRectMake(self.centerOfHole.x - self.radiusOfHole , self.centerOfHole.y - self.radiusOfHole , self.radiusOfHole * 2, self.radiusOfHole * 2);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:holeRect];
    [circlePath appendPath:[UIBezierPath bezierPathWithRect:rect]];
    circlePath.usesEvenOddFillRule = YES;
    [circlePath fill];
}


-(void)moveCenterToPoint:(CGPoint)anotherCenter animated:(BOOL)animated{
    [self moveCenterToPoint:anotherCenter duration:animated ? MOVE_DURATION : 0 completion:NULL];
}

-(void)changeToRadius:(CGFloat)anotherRadius animated:(BOOL)animated{
    [self changeToRadius:anotherRadius duration:animated ? ZOOM_DURATION : 0 completion:NULL];
}

-(void)moveStep:(NSTimer*)timer{
    self.currentMoveStep += 1;
    if (self.currentMoveStep > self.totalMoveStep) {
        [timer invalidate];
        self.totalMoveStep = 0;
        self.currentMoveStep = 0;
        if (self.currentMoveCompletionBlock) {
            self.currentMoveCompletionBlock(self);
        }
    }else{
        CGSize totalDiff = [timer.userInfo[@"diff"]CGSizeValue];
        CGSize diff = CGSizeMake(totalDiff.width * MOVE_STEP / MOVE_DURATION, totalDiff.height * MOVE_STEP / MOVE_DURATION);
        self.centerOfHole = CGPointMake(self.centerOfHole.x + diff.width, self.centerOfHole.y + diff.height);
        [self setNeedsDisplay];
        
    }
}

-(void)zoomStep:(NSTimer*)timer{
    self.currentZoomStep += 1;
    if (self.currentZoomStep > self.totalZoomStep) {
        [timer invalidate];
        self.totalZoomStep = 0;
        self.currentZoomStep= 0;
        if (self.currentZoomCompletionBlock) {
            self.currentZoomCompletionBlock(self);
        }
    }else{
        float totalDiff = [timer.userInfo[@"diff"]floatValue];
        float diff = totalDiff * ZOOM_STEP / ZOOM_DURATION;
        
        self.radiusOfHole += diff;
        [self setNeedsDisplay];
    }
}

-(void)setZoomInOutAnimation:(BOOL)zoomInOutAnimation{
    if (_zoomInOutAnimation != zoomInOutAnimation) {
        _zoomInOutAnimation = zoomInOutAnimation;
        if (!zoomInOutAnimation) {
            [self.zoomInOutTimer invalidate];
            self.radiusOfHole = self.originalRadius;
            [self setNeedsDisplay];
        }else{
            [self.zoomInOutTimer invalidate];
            self.currentZoomInOutStep = 0;
            self.originalRadius = self.radiusOfHole;
            self.zoomInOutTimer = [NSTimer timerWithTimeInterval:ZOOM_IN_OUT_STEP target:self selector:@selector(stepZoomInOut:) userInfo:@{@"diff": @(2)} repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:self.zoomInOutTimer forMode:NSRunLoopCommonModes];
        }
    }
}

-(void)stepZoomInOut:(NSTimer*)timer{
    self.currentZoomInOutStep += 1;
    float previousRadian = M_PI * 2. * (((float)self.currentZoomInOutStep -1) * ZOOM_IN_OUT_STEP / ZOOM_IN_OUT_INTERVAL);
    float currentRadian = M_PI * 2. * ((float)self.currentZoomInOutStep * ZOOM_IN_OUT_STEP / ZOOM_IN_OUT_INTERVAL);
    float diff = (sinf(currentRadian) - sinf(previousRadian)) * [timer.userInfo[@"diff"]floatValue];
    self.radiusOfHole += diff;
    [self setNeedsDisplay];
}

-(void)dealloc{
    [self.zoomInOutTimer invalidate];
    [self.moveTimer invalidate];
    [self.zoomTimer invalidate];
}

-(void)moveCenterToPoint:(CGPoint)anotherCenter duration:(NSTimeInterval)duration completion:(SWHSpotlightViewViewCompletionBlock)completion{
    [self.moveTimer invalidate];
    self.currentMoveCompletionBlock = NULL;
    if (duration > 0) {
        self.currentMoveDuration = duration;
        self.totalMoveStep = duration / MOVE_STEP;
        self.currentMoveStep = 0;
        CGSize size = CGSizeMake(anotherCenter.x - self.centerOfHole.x, anotherCenter.y - self.centerOfHole.y);
        self.moveTimer = [NSTimer timerWithTimeInterval:MOVE_STEP target:self selector:@selector(moveStep:) userInfo:@{@"diff" : [NSValue valueWithCGSize:size]} repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.moveTimer forMode:NSRunLoopCommonModes];
        self.currentMoveCompletionBlock = completion;
    }else{
        self.centerOfHole = anotherCenter;
        if (completion) {
            completion(self);
        }
        [self setNeedsDisplay];
    }
    
}

-(void)changeToRadius:(CGFloat)anotherRadius duration:(NSTimeInterval)duration completion:(SWHSpotlightViewViewCompletionBlock)completion{
    [self.zoomTimer invalidate];
    self.originalRadius = anotherRadius;
    if (duration > 0) {
        self.totalZoomStep  = duration / ZOOM_STEP;
        self.currentZoomStep = 0;
        self.zoomTimer = [NSTimer timerWithTimeInterval:ZOOM_STEP target:self selector:@selector(zoomStep:) userInfo:@{@"diff":@(anotherRadius - self.radiusOfHole)} repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.zoomTimer forMode:NSRunLoopCommonModes];
        self.currentZoomCompletionBlock = completion;
    }else{
        self.radiusOfHole = anotherRadius;
        if (completion) {
            completion(self);
        }
        [self setNeedsDisplay];
    }
}


@end
