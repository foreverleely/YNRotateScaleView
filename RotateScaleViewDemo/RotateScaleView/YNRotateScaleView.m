//
//  YNRotateScaleView.m
//  RotateScaleViewDemo
//
//  Created by liyangly on 2018/9/21.
//  Copyright © 2018年 liyang. All rights reserved.
//

#import "YNRotateScaleView.h"
// pod
#import "Masonry.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#endif

@interface YNRotateScaleView()

@property (nonatomic, strong) UIImageView *viewImgV;
@property (nonatomic, strong) CAShapeLayer *viewBorder;
@property (nonatomic, strong) UIColor *borderColor;

/*** sacle rotate ***/

// 缩放旋转删除图片
@property (nonatomic, strong) UIImageView *scaleImageView;
@property (nonatomic, strong) UIImageView *deleteImageView;

// 当前视图原本 frame bounds transform
@property(assign,nonatomic) CGRect beforeOringalFrame;
@property(assign,nonatomic) CGRect beforeOringalBounds;
@property(assign,nonatomic) CGAffineTransform beforeOringalTransform;

// UIPanGestureRecognizer 操作的 当前点 和 起始点
@property(assign,nonatomic) CGPoint panLocationPoint;
@property(assign,nonatomic) CGPoint panStartPoint;
@property(assign,nonatomic) CGPoint roatePanLocationPoint;
@property(assign,nonatomic) CGPoint roatePanStartPoint;

@end

@implementation YNRotateScaleView

- (instancetype)initWithImageName:(NSString *)imgName
                      borderColor:(UIColor *)bordercolor {
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.viewImgV.image = [UIImage imageNamed:imgName];
        self.borderColor = bordercolor;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentPanGestureHanele:)];
        [self addGestureRecognizer:pan];
        
        [self configSubViews];
    }
    return self;
}

- (void)configSubViews {
    
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat xRate = SCREEN_WIDTH / 375.f;
    
    [self addSubview:self.viewImgV];
    self.viewImgV.frame = CGRectMake(0, 0, 100 * xRate, 100 * xRate);
    
    CGRect rect = CGRectMake(4.5, 4.5, 100 * xRate - 18, 100 * xRate - 18);
    
    self.viewBorder.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
    self.viewBorder.frame = rect;
    [self.layer addSublayer:self.viewBorder];
    
    [self addSubview:self.scaleImageView];
    self.scaleImageView.frame = CGRectMake(100 * xRate - 18, 100 * xRate - 18, 18, 18);
    
    [self addSubview:self.deleteImageView];
    self.deleteImageView.frame = CGRectMake(0, 0, 18, 18);
    
}

#pragma mark - Gesture
- (void)contentPanGestureHanele:(UIPanGestureRecognizer*)panGesture {
    
    if (!self.canEdit) {
        return;
    }
    
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint locationPoint = [panGesture locationInView:self.superview];
    // 不能移出父视图
    if (locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > self.superview.frame.size.width || locationPoint.y > self.superview.frame.size.height) {
        return;
    }
    // 点击缩放按钮区域无效
    CGPoint inScaleImgVPoint = [panGesture locationInView:self.scaleImageView];
    if ((inScaleImgVPoint.x > 0 && inScaleImgVPoint.x < 18) || (inScaleImgVPoint.y > 0 && inScaleImgVPoint.y < 18)) {
        return;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:{
            startPoint = locationPoint;
            self.panStartPoint = startPoint;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.panLocationPoint = locationPoint;
            if (self.superview) {
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.beforeCenterOffsetX + self.panLocationPoint.x - self.panStartPoint.x);
                    make.centerY.mas_equalTo(self.beforeCenterOffsetY + self.panLocationPoint.y - self.panStartPoint.y);
                }];
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
            self.beforeCenterOffsetX += self.panLocationPoint.x - self.panStartPoint.x;
            self.beforeCenterOffsetY += self.panLocationPoint.y - self.panStartPoint.y;
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (void)scaleRotatePanGestureHanele:(UIPanGestureRecognizer*)panGesture {
    
    if (!self.canEdit) {
        return;
    }
    
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint locationPoint = [panGesture locationInView:self.superview];
    switch (panGesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:{
            startPoint = locationPoint;
            self.panStartPoint = startPoint;
            self.beforeOringalBounds = self.bounds;
            self.beforeOringalFrame = self.frame;
            
            self.roatePanStartPoint = startPoint;
            self.beforeOringalTransform = self.transform;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.panLocationPoint = locationPoint;
            [self scaleHandle];
            
            self.roatePanLocationPoint = locationPoint;
            [self rotateHandle];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            self.roatePanLocationPoint = locationPoint;
            [self rotateHandle];
        }
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
    
}

- (void)deleteGestureHanele:(UITapGestureRecognizer*)tapGesture {
    if (self.superview) {
        if (self.deleteAction) {
            self.deleteAction();
        }
        [self removeFromSuperview];
    }
}

- (void)scaleHandle {
    
    CGFloat startToCenterDistance = sqrt(pow(self.center.x - self.panStartPoint.x, 2) + pow(self.center.y - self.panStartPoint.y, 2));
    CGFloat currentToCenterDistance = sqrt(pow(self.center.x - self.panLocationPoint.x, 2) + pow(self.center.y - self.panLocationPoint.y, 2));
    
    CGFloat percent = (currentToCenterDistance - startToCenterDistance) / startToCenterDistance;
    
    CGFloat percentOffX = self.beforeOringalBounds.size.width * percent;
    CGFloat percentOffY = self.beforeOringalBounds.size.height * percent;
    
    CGFloat width = self.beforeOringalBounds.size.width + percentOffX;
    CGFloat height = self.beforeOringalBounds.size.height + percentOffY;
    
    CGFloat minWH = 50;
    CGFloat realWidth = 0;
    CGFloat realHeight = 0;
    realWidth = width > minWH ? width : minWH;
    realHeight = height > minWH ? height : minWH;
    if (realWidth == minWH) {
        realHeight = realWidth/width * height;
    } else if (realHeight == minWH){
        realWidth = realHeight/height * width;
    }
    
    if (self.superview) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(realWidth);
            make.height.mas_equalTo(realHeight);
        }];
    }
    
    self.viewImgV.frame = CGRectMake(0, 0, realWidth, realHeight);
    
    // update border
    CGRect rect = CGRectMake(4.5f, 4.5f, realWidth - 18, realHeight - 18);
    
    self.viewBorder.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
    self.viewBorder.frame = rect;
    
    self.scaleImageView.frame = CGRectMake(realWidth - 18, realHeight - 18, 18, 18);
}

- (void)rotateHandle {
    
    CGPoint center = self.center;
    
    CGFloat angleInRadians = angleBetweenLines(center, self.roatePanLocationPoint, center, self.roatePanStartPoint);
    
    CGPoint startOff = CGPointMake(self.roatePanStartPoint.x - center.x, self.roatePanStartPoint.y - center.y);
    CGPoint locationOff = CGPointMake(self.roatePanLocationPoint.x - self.roatePanStartPoint.x, self.roatePanLocationPoint.y - self.roatePanStartPoint.y);
    CGFloat off = startOff.x * locationOff.y - startOff.y * locationOff.x;
    
    if (off > 0) {//顺时针方向
        angleInRadians  = fabs(angleInRadians);
    } else { //逆时针方向
        angleInRadians  = -fabs(angleInRadians);
    }
    CGAffineTransform _trans = self.beforeOringalTransform;
    CGFloat rotate = acosf(_trans.a);
    
    // 旋转180度后，需要处理弧度的变化
    if (_trans.b < 0) {
        rotate = -rotate;
    }
    
    CGFloat orignalRotateAngle = rotate;
    CGFloat currentRotateAngle = orignalRotateAngle + angleInRadians *M_PI / 180.0;
    self.transform = CGAffineTransformMakeRotation(currentRotateAngle);
}

#ifndef pi
#define pi 3.14159265358979323846
#endif
CGFloat angleBetweenLines(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End) {
    
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    
    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    
    return (180.0 * rads / pi);
    return rads;
}

#pragma mark - Setters
- (void)setCanEdit:(BOOL)canEdit {
    _canEdit = canEdit;
    
    if (canEdit) {
        self.viewBorder.strokeColor = self.borderColor.CGColor;
        self.scaleImageView.hidden = NO;
        self.deleteImageView.hidden = NO;
    } else {
        self.viewBorder.strokeColor = [UIColor clearColor].CGColor;
        self.scaleImageView.hidden = YES;
        self.deleteImageView.hidden = YES;
    }
}

#pragma mark - Getters
- (UIImageView *)viewImgV {
    if (!_viewImgV) {
        _viewImgV = [[UIImageView alloc] init];
        _viewImgV.contentMode = UIViewContentModeScaleToFill;
    }
    return _viewImgV;
}

- (CAShapeLayer *)viewBorder {
    if (!_viewBorder) {
        _viewBorder = [CAShapeLayer layer];
        _viewBorder.strokeColor = self.borderColor.CGColor;
        _viewBorder.fillColor = nil;
        _viewBorder.lineWidth = 1.f;
        _viewBorder.lineCap = @"square";
        _viewBorder.lineDashPattern = @[@4, @2];
    }
    return _viewBorder;
}

- (UIImageView *)scaleImageView {
    if (!_scaleImageView) {
        _scaleImageView = [[UIImageView alloc] init];
        _scaleImageView.image = [UIImage imageNamed:@"yn_rotatescale_icon_magnify"];
        _scaleImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _scaleImageView.layer.shadowOffset = CGSizeZero;
        _scaleImageView.layer.shadowRadius = 4;
        _scaleImageView.layer.shadowOpacity = 0.3;
        _scaleImageView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *scalePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scaleRotatePanGestureHanele:)];
        [_scaleImageView addGestureRecognizer:scalePan];
    }
    return _scaleImageView;
}

- (UIImageView *)deleteImageView {
    if (!_deleteImageView) {
        _deleteImageView = [[UIImageView alloc] init];
        _deleteImageView.image = [UIImage imageNamed:@"yn_rotatescale_icon_close"];
        _deleteImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _deleteImageView.layer.shadowOffset = CGSizeZero;
        _deleteImageView.layer.shadowRadius = 4;
        _deleteImageView.layer.shadowOpacity = 0.3;
        _deleteImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteGestureHanele:)];
        [_deleteImageView addGestureRecognizer:deleteTap];
    }
    return _deleteImageView;
}

@end
