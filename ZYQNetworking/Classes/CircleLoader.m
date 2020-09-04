//
//  CircleLoader.m
//  testYY
//
//  Created by Albert on 2019/1/17.
//  Copyright © 2019年 Albert. All rights reserved.
//

#import "CircleLoader.h"
@interface CircleLoader ()

@property (nonatomic,strong) CAShapeLayer *trackLayer;

@property (nonatomic,strong) CAShapeLayer *progressLayer;
/* <#属性#>*/
@property (nonatomic, strong) CAShapeLayer *circleLayer;
/* <#属性#>*/
@property (nonatomic, strong) CAShapeLayer *checkLayer;
@end

@implementation CircleLoader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    _trackLayer=[CAShapeLayer layer];
    _trackLayer.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _trackLayer.lineWidth=_lineWidth;
    _trackLayer.strokeColor=_trackTintColor.CGColor;
    _trackLayer.fillColor = self.backgroundColor.CGColor;
    _trackLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_trackLayer];
    
    _progressLayer=[CAShapeLayer layer];
    _progressLayer.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _progressLayer.lineWidth=_lineWidth;
    _progressLayer.strokeColor=_progressTintColor.CGColor;
    _progressLayer.fillColor = self.backgroundColor.CGColor;
    _progressLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_progressLayer];
    
    if (_centerImage!=nil) {
        UIImageView *centerImgView=[[UIImageView alloc]initWithImage:_centerImage];
        centerImgView.frame=CGRectMake(_lineWidth, _lineWidth, self.frame.size.width-2*_lineWidth, self.frame.size.height-_lineWidth*2);
        //        centerImgView.center=self.center;
        centerImgView.layer.cornerRadius=(self.frame.size.width+_lineWidth)/2;
        centerImgView.clipsToBounds=YES;
        [self.layer addSublayer:centerImgView.layer];
    }
}

- (void)drawBackgroundCircle:(BOOL) animationing {
    
    //贝塞尔曲线 0度是在十字右边方向   －M_PI/2相当于在十字上边方向
    CGFloat startAngle = - ((float)M_PI / 2); // 90 Degrees
    
    //
    CGFloat endAngle = (2 * (float)M_PI) + - ((float)M_PI / 8);;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;
    
    
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    //    processPath.lineWidth=_lineWidth;
    
    UIBezierPath *trackPath = [UIBezierPath bezierPath];
    //    trackPath.lineWidth=_lineWidth;
    
    //---------------------------------------
    // Make end angle to 90% of the progress
    //---------------------------------------
    if (animationing) {
        endAngle = (_progressValue * 2*(float)M_PI) + startAngle;
    }
    else
    {
        endAngle = (0.1 * 2*(float)M_PI) + startAngle;
    }
    
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [trackPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    _progressLayer.path = processPath.CGPath;
    _trackLayer.path=trackPath.CGPath;
}
- (void)startAnimated
{
    [self drawBackgroundCircle:_animationing];
    if (_animationing) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        rotationAnimation.duration = 0.5;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        [_progressLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    
}
- (void)hide
{
    [_progressLayer removeAllAnimations];
    if (self.checkLayer) {
        [self.checkLayer removeFromSuperlayer];
    }
    if (self.circleLayer) {
        [self.circleLayer removeFromSuperlayer];
    }
    self.hidden = true;
}

- (void)checkAnimate{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    CGRect rectInRound = CGRectInset(self.bounds, self.bounds.size.width*(1-1/sqrt(2.0))/2, self.bounds.size.width*(1-1/sqrt(2.0))/2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rectInRound.origin.x + rectInRound.size.width/9, rectInRound.origin.y + rectInRound.size.height*2/3)];
    [path addLineToPoint:CGPointMake(rectInRound.origin.x + rectInRound.size.width/3, rectInRound.origin.y + rectInRound.size.height*9/10)];
    [path addLineToPoint:CGPointMake(rectInRound.origin.x + rectInRound.size.width*8/10, rectInRound.origin.y + rectInRound.size.height*2/10)];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth =1.0f;
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:shapeLayer];
    
    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnima.duration = 0.25f;
    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnima.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnima.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnima.fillMode = kCAFillModeForwards;
    pathAnima.removedOnCompletion = NO;
    self.checkLayer = shapeLayer;
    [shapeLayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
}

- (void)circleAnimate{
    CAShapeLayer *circleShapeLayer = [CAShapeLayer layer];
    
    CGFloat startAngle = (_progressValue * 2*(float)M_PI) - ((float)M_PI / 2);
    CGFloat endAngle = (2 * (float)M_PI)- ((float)M_PI / 2);
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;
    circleShapeLayer.frame = self.bounds;
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    circleShapeLayer.fillColor = [UIColor clearColor].CGColor;
    circleShapeLayer.lineWidth =1.0f;
    circleShapeLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:circleShapeLayer];
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    circleShapeLayer.path = processPath.CGPath;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.25f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:_progressValue];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    self.circleLayer = circleShapeLayer;
    [circleShapeLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
}

- (void)endAnimated{
    [_progressLayer removeAllAnimations];

    [self checkAnimate];

    [self circleAnimate];
}


@end
