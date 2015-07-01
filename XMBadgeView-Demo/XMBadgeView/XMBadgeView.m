//
//  XMBadgeView.m
//  XMBadgeView-Demo
//
//  Created by shscce on 15/7/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMBadgeView.h"

#import <QuartzCore/QuartzCore.h>
#include <mach-o/dyld.h>

#if !__has_feature(objc_arc)
#error XMBadgeView must be compiled with ARC.
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error XMBadgeView only support IOS7+
#endif

// Silencing some deprecation warnings if your deployment target is iOS7 that can only be fixed by using methods that
// Are only available on iOS7.
// Soon JSBadgeView will require iOS 7 and we'll be able to use the new methods.
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#define XMBadgeViewSilenceDeprecatedMethodStart()   _Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
#define XMBadgeViewSilenceDeprecatedMethodEnd()     _Pragma("clang diagnostic pop")
#else
#define XMBadgeViewSilenceDeprecatedMethodStart()
#define XMBadgeViewSilenceDeprecatedMethodEnd()
#endif

/**
 *  默认XMBadgeView 阴影的圆角值
 */
static const CGFloat XMBadgeViewShadowRadius = 1.0f;

/**
 *  默认的XMBadgeView的高度
 */
static const CGFloat XMBadgeViewHeight = 16.0f;

/**
 *  默认的XMBadgeView文字距离左右两侧边距
 */
static const CGFloat XMBadgeViewTextSideMargin = 8.0f;

@interface XMBadgeView ()

@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (strong, nonatomic) UIView *smallBadgeView;
@property (weak, nonatomic) UIView *attachView;

@end

@implementation XMBadgeView

+ (void)applyIOS7Style
{
    XMBadgeView *badgeViewAppearanceProxy = XMBadgeView.appearance;


    
    badgeViewAppearanceProxy.badgeTextColor = [UIColor whiteColor];
    badgeViewAppearanceProxy.badgeTextFont = [UIFont systemFontOfSize:12.0f];
    badgeViewAppearanceProxy.badgeBackgroundColor = [UIColor redColor];
    badgeViewAppearanceProxy.badgeShadowSize = CGSizeZero;
    badgeViewAppearanceProxy.badgeShadowColor = UIColor.clearColor;
    badgeViewAppearanceProxy.badgeTextShadowColor = UIColor.clearColor;
    badgeViewAppearanceProxy.badgeTextShadowSize = CGSizeZero;
    
    badgeViewAppearanceProxy.badgeStrokeWidth = 0.0f;
    badgeViewAppearanceProxy.badgeStrokeColor = badgeViewAppearanceProxy.badgeBackgroundColor;
    
    badgeViewAppearanceProxy.backgroundColor =  [UIColor clearColor];
}


+ (void)initialize
{
    if (self == XMBadgeView.class)
    {
        [self applyIOS7Style];
        
    }
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}


- (instancetype)initWithParentView:(UIView *)parentView alignment:(XMBadgeViewAlignment)alignment
{
    if ((self = [self initWithFrame:CGRectZero]))
    {
        self.badgeViewAlignment = alignment;
        self.panable = NO;
        [parentView addSubview:self];
    }
    
    return self;
}


- (instancetype)initWithAttachView:(UIView *)attachView alignment:(XMBadgeViewAlignment)alignment{
    if ((self = [self initWithFrame:CGRectZero])) {
        self.badgeViewAlignment = alignment;
        self.attachView = attachView;
        self.panable = YES;
        
        [self.attachView.superview insertSubview:self aboveSubview:self.attachView];
    }
    return self;
}

- (void)awakeFromNib{
    [self setUp];
}

#pragma mark - Layout

- (CGFloat)marginToDrawInside
{
    return self.badgeStrokeWidth * 2.0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect newFrame = self.frame;
    const CGFloat textWidth = [self sizeOfTextForCurrentSettings].width;
    const CGFloat textHeight = [self sizeOfTextForCurrentSettings].height;
    const CGFloat marginToDrawInside = [self marginToDrawInside];
    const CGFloat viewWidth = MAX(_badgeMinWidth, textWidth + XMBadgeViewTextSideMargin + (marginToDrawInside * 2));
    const CGFloat viewHeight = MAX(24, textHeight + (marginToDrawInside * 2));
    newFrame.size.width = MAX(viewWidth, viewHeight);
    newFrame.size.height = MAX(viewWidth, viewHeight);
    
    //判断是否有依附view 计算坐标方式不同
    if (self.attachView) {
        CGPoint newCenter = self.center;
        CGRect attachViewRect = self.attachView.frame;
        
        switch (self.badgeViewAlignment) {
            case XMBadgeViewAlignmentTopLeft:
                newCenter.x = attachViewRect.origin.x;
                newCenter.y = attachViewRect.origin.y;
                break;
            case XMBadgeViewAlignmentTopRight:
                newCenter.x = attachViewRect.origin.x + attachViewRect.size.width;
                newCenter.y = attachViewRect.origin.y;
                break;
            case XMBadgeViewAlignmentTopCenter:
                newCenter.x = attachViewRect.origin.x + attachViewRect.size.width/2;
                newCenter.y = attachViewRect.origin.y;
                break;
            case XMBadgeViewAlignmentCenterLeft:
                newCenter.x = attachViewRect.origin.x;
                newCenter.y = attachViewRect.origin.y + attachViewRect.size.height/2;
                break;
            case XMBadgeViewAlignmentCenterRight:
                newCenter.x = attachViewRect.origin.x + attachViewRect.size.width;
                newCenter.y = attachViewRect.origin.y + attachViewRect.size.height/2;
                break;
            case XMBadgeViewAlignmentBottomLeft:
                newCenter.x = attachViewRect.origin.x;
                newCenter.y = attachViewRect.origin.y + attachViewRect.size.height;
                break;
            case XMBadgeViewAlignmentBottomRight:
                newCenter.x = attachViewRect.origin.x + attachViewRect.size.width;
                newCenter.y = attachViewRect.origin.y + attachViewRect.size.height;
                break;
            case XMBadgeViewAlignmentBottomCenter:
                newCenter.x = attachViewRect.origin.x + attachViewRect.size.width/2;
                newCenter.y = attachViewRect.origin.y + attachViewRect.size.height;
                break;
            case XMBadgeViewAlignmentCenter:
                newCenter.x = attachViewRect.origin.x + attachViewRect.size.width/2;
                newCenter.y = attachViewRect.origin.y + attachViewRect.size.height/2;
                break;
            default:
                NSAssert(NO, @"Unimplemented XMBadgeAligment type %lul", (unsigned long)self.badgeViewAlignment);
        }
        
        newCenter.x += _badgePositionAdjustment.x;
        newCenter.y += _badgePositionAdjustment.y;
        
        // Do not set frame directly so we do not interfere with any potential transform set on the view.
        self.bounds = CGRectIntegral(CGRectMake(0, 0, CGRectGetWidth(newFrame), CGRectGetHeight(newFrame)));
        self.center = newCenter;

    }else{
     
        const CGRect superviewBounds = self.superview.bounds;
        const CGFloat superviewWidth = superviewBounds.size.width;
        const CGFloat superviewHeight = superviewBounds.size.height;
        
        switch (self.badgeViewAlignment) {
            case XMBadgeViewAlignmentTopLeft:
                newFrame.origin.x = -viewWidth / 2.0f;
                newFrame.origin.y = -viewHeight / 2.0f;
                break;
            case XMBadgeViewAlignmentTopRight:
                newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
                newFrame.origin.y = -viewHeight / 2.0f;
                break;
            case XMBadgeViewAlignmentTopCenter:
                newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
                newFrame.origin.y = -viewHeight / 2.0f;
                break;
            case XMBadgeViewAlignmentCenterLeft:
                newFrame.origin.x = -viewWidth / 2.0f;
                newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
                break;
            case XMBadgeViewAlignmentCenterRight:
                newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
                newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
                break;
            case XMBadgeViewAlignmentBottomLeft:
                newFrame.origin.x = -viewWidth / 2.0f;
                newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
                break;
            case XMBadgeViewAlignmentBottomRight:
                newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
                newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
                break;
            case XMBadgeViewAlignmentBottomCenter:
                newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
                newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
                break;
            case XMBadgeViewAlignmentCenter:
                newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
                newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
                break;
            default:
                NSAssert(NO, @"Unimplemented XMBadgeAligment type %lul", (unsigned long)self.badgeViewAlignment);
        }
        
        newFrame.origin.x += _badgePositionAdjustment.x;
        newFrame.origin.y += _badgePositionAdjustment.y;
        
        // Do not set frame directly so we do not interfere with any potential transform set on the view.
        self.bounds = CGRectIntegral(CGRectMake(0, 0, CGRectGetWidth(newFrame), CGRectGetHeight(newFrame)));
        self.center = CGPointMake(ceilf(CGRectGetMidX(newFrame)), ceilf(CGRectGetMidY(newFrame)));
        
    }
    
    CGRect smallCircleRect = CGRectMake(0, 0, self.badgeViewCornerRadius * (2 - 0.5) , self.badgeViewCornerRadius * (2 - 0.5));
    self.smallBadgeView.bounds = smallCircleRect;
    self.smallBadgeView.center = self.center;
    self.smallBadgeView.layer.cornerRadius = _smallBadgeView.bounds.size.width/2;
    
    [self setNeedsDisplay];
}

/*
 * Use it When initWithParentView
 /
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect newFrame = self.frame;
    const CGRect superviewBounds = self.superview.bounds;
    
    const CGFloat textWidth = [self.badgeText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}].width;
    
    const CGFloat marginToDrawInside = [self marginToDrawInside];
    const CGFloat viewWidth = MAX(_badgeMinWidth, textWidth + XMBadgeViewTextSideMargin + (marginToDrawInside * 2));
    const CGFloat viewHeight = XMBadgeViewHeight + (marginToDrawInside * 2);
    
    const CGFloat superviewWidth = superviewBounds.size.width;
    const CGFloat superviewHeight = superviewBounds.size.height;
    
    newFrame.size.width = MAX(viewWidth, viewHeight);
    newFrame.size.height = MAX(viewWidth, viewHeight);

    switch (self.badgeViewAlignment) {
        case XMBadgeViewAlignmentTopLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case XMBadgeViewAlignmentTopRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case XMBadgeViewAlignmentTopCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case XMBadgeViewAlignmentCenterLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case XMBadgeViewAlignmentCenterRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case XMBadgeViewAlignmentBottomLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case XMBadgeViewAlignmentBottomRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case XMBadgeViewAlignmentBottomCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case XMBadgeViewAlignmentCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        default:
            NSAssert(NO, @"Unimplemented XMBadgeAligment type %lul", (unsigned long)self.badgeViewAlignment);
    }
    
    newFrame.origin.x += _badgePositionAdjustment.x;
    newFrame.origin.y += _badgePositionAdjustment.y;
    
    // Do not set frame directly so we do not interfere with any potential transform set on the view.
    self.bounds = CGRectIntegral(CGRectMake(0, 0, CGRectGetWidth(newFrame), CGRectGetHeight(newFrame)));
    self.center = CGPointMake(ceilf(CGRectGetMidX(newFrame)), ceilf(CGRectGetMidY(newFrame)));
    
    CGRect smallCircleRect = CGRectMake(0, 0, self.badgeViewCornerRadius * (2 - 0.5) , self.badgeViewCornerRadius * (2 - 0.5));
    self.smallBadgeView.bounds = smallCircleRect;
    self.smallBadgeView.center = self.center;
    self.smallBadgeView.layer.cornerRadius = _smallBadgeView.bounds.size.width/2;
    
    
    [self setNeedsDisplay];
}
*/
 
 
#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    const BOOL anyTextToDraw = (self.badgeText.length > 0);
    
    if (anyTextToDraw)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        const CGFloat marginToDrawInside = [self marginToDrawInside];
        const CGRect rectToDraw = CGRectInset(rect, marginToDrawInside, marginToDrawInside);
        
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rectToDraw byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(self.badgeViewCornerRadius, self.badgeViewCornerRadius)];
        
        /* 绘制背景色,背景阴影 */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetFillColorWithColor(ctx, self.badgeBackgroundColor.CGColor);
            CGContextSetShadowWithColor(ctx, self.badgeShadowSize, XMBadgeViewShadowRadius, self.badgeShadowColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathFill);
        }
        CGContextRestoreGState(ctx);
        
        /* 绘制边框 */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetLineWidth(ctx, self.badgeStrokeWidth);
            CGContextSetStrokeColorWithColor(ctx, self.badgeStrokeColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        CGContextRestoreGState(ctx);
        
        /* 绘制文字 */
        
        CGContextSaveGState(ctx);
        {
            CGContextSetFillColorWithColor(ctx, self.badgeTextColor.CGColor);
            CGContextSetShadowWithColor(ctx, self.badgeTextShadowSize, 1.0, self.badgeTextShadowColor.CGColor);
            
            CGRect textFrame = rectToDraw;
            const CGSize textSize = [self sizeOfTextForCurrentSettings];
            
            textFrame.size.height = textSize.height;
            textFrame.origin.y = rectToDraw.origin.y + ceilf((rectToDraw.size.height - textFrame.size.height) / 2.0f);
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = NSTextAlignmentCenter;
            [self.badgeText drawInRect:textFrame withAttributes:@{NSFontAttributeName:self.badgeTextFont,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:self.badgeTextColor}];
        }
        CGContextRestoreGState(ctx);
    }
}


#pragma mark - Response Actions

/**
 *  处理拖动手势
 *
 *  @param pan
 */
- (void)handlePan:(UIPanGestureRecognizer *)pan{
    CGPoint panPoint = [pan translationInView:self];
    
    CGPoint changeCenter = self.center;
    changeCenter.x += panPoint.x;
    changeCenter.y += panPoint.y;
    self.center = changeCenter;
    [pan setTranslation:CGPointZero inView:self];
    
    //俩个圆的中心点之间的距离
    CGFloat dist = [self pointToPoitnDistanceWithPoint:self.center potintB:self.smallBadgeView.center];
    
    if (dist < self.maxDistance) {
        
        CGFloat cornerRadius = self.badgeViewCornerRadius;
        CGFloat samllCrecleRadius = cornerRadius - dist / 20;
        self.smallBadgeView.bounds = CGRectMake(0, 0, samllCrecleRadius * (2 - 0.5), samllCrecleRadius * (2 - 0.5));
        self.smallBadgeView.layer.cornerRadius = self.smallBadgeView.bounds.size.width / 2;
        
        if (self.smallBadgeView.hidden == NO && dist > 0) {
            //画不规则矩形
            self.shapeLayer.path = [self pathWithBigCirCleView:self smallCirCleView:_smallBadgeView].CGPath;
        }
    } else {
        
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        self.smallBadgeView.hidden = YES;
    
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (dist > self.maxDistance) {
            [self reset];
            [UIView animateWithDuration:.3 animations:^{
                self.alpha = 0.0f;
            }completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        } else {
            
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = self.smallBadgeView.center;
            } completion:^(BOOL finished) {
                self.smallBadgeView.hidden = NO;
            }];
        }
    }
}

#pragma mark - Private

- (void)setUp{
    
    self.maxDistance =  100;
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGes];
    
}

/**
 *  重置,将smallBadgeView,shapeLayer 从父view中移除,以免内存泄露
 */
- (void)reset{
    [self.smallBadgeView removeFromSuperview];
    self.smallBadgeView = nil;
    
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}

/**
 *  计算两点之间距离
 *
 *  @param pointA A点
 *  @param pointB B点
 *
 *  @code
 *  CGFloat distance = [self pointToPoitnDistanceWithPoint:aPoint potintB:bPoint]
 *  @endcode
 *
 *  @return 两点之间距离
 */
- (CGFloat)pointToPoitnDistanceWithPoint:(CGPoint)pointA potintB:(CGPoint)pointB
{
    CGFloat offestX = pointA.x - pointB.x;
    CGFloat offestY = pointA.y - pointB.y;
    CGFloat dist = sqrtf(offestX * offestX + offestY * offestY);
    
    return dist;
}


/**
 *  绘制贝塞尔曲线路径
 *
 *  @param bigCirCleView   被拖动的View
 *  @param smallCirCleView 留在原地的view
 *
 *  @return UIBezierPath 的实例
 */
- (UIBezierPath *)pathWithBigCirCleView:(UIView *)bigCirCleView  smallCirCleView:(UIView *)smallCirCleView
{
    CGPoint bigCenter = bigCirCleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCirCleView.bounds.size.width / 2;
    
    CGPoint smallCenter = smallCirCleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCirCleView.bounds.size.width / 2;
    
    // 获取圆心距离
    CGFloat d = [self pointToPoitnDistanceWithPoint:self.smallBadgeView.center potintB:self.center];
    CGFloat sinθ = 0.0f;
    CGFloat cosθ = 0.0f;
    if (d == 0) {
        sinθ = 0;
        cosθ = 1;
    }else{
        sinθ = (x2 - x1) / d;
        cosθ = (y2 - y1) / d;
    }
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}


- (CGSize)sizeOfTextForCurrentSettings
{
    
    return [self.badgeText sizeWithAttributes:@{NSFontAttributeName:self.badgeTextFont}];
//    XMBadgeViewSilenceDeprecatedMethodStart();
//    return [self.badgeText sizeWithFont:self.badgeTextFont];
//    XMBadgeViewSilenceDeprecatedMethodEnd();
}

#pragma mark - Setters

- (void)setBadgeViewAlignment:(XMBadgeViewAlignment)badgeViewAlignment{
    
    if (badgeViewAlignment != _badgeViewAlignment) {
        _badgeViewAlignment = badgeViewAlignment;
        [self setNeedsLayout];
    }
    
}

- (void)setBadgePositionAdjustment:(CGPoint)badgePositionAdjustment
{
    _badgePositionAdjustment = badgePositionAdjustment;
    
    [self setNeedsLayout];
}

- (void)setBadgeText:(NSString *)badgeText
{
    if (badgeText != _badgeText)
    {
        _badgeText = [badgeText copy];
        
        [self setNeedsLayout];
    }
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    if (badgeTextColor != _badgeTextColor)
    {
        _badgeTextColor = badgeTextColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeTextShadowColor:(UIColor *)badgeTextShadowColor
{
    if (badgeTextShadowColor != _badgeTextShadowColor)
    {
        _badgeTextShadowColor = badgeTextShadowColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeTextShadowSize:(CGSize)badgeTextShadowSize{
    
    _badgeTextShadowSize = badgeTextShadowSize;
    [self setNeedsDisplay];

}


- (void)setBadgeTextFont:(UIFont *)badgeTextFont
{
    if (badgeTextFont != _badgeTextFont)
    {
        _badgeTextFont = badgeTextFont;
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor
{
    if (badgeBackgroundColor != _badgeBackgroundColor)
    {
        _badgeBackgroundColor = badgeBackgroundColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeStrokeWidth:(CGFloat)badgeStrokeWidth
{
    if (badgeStrokeWidth != _badgeStrokeWidth)
    {
        _badgeStrokeWidth = badgeStrokeWidth;
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)setBadgeStrokeColor:(UIColor *)badgeStrokeColor
{
    if (badgeStrokeColor != _badgeStrokeColor)
    {
        _badgeStrokeColor = badgeStrokeColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeShadowColor:(UIColor *)badgeShadowColor
{
    if (badgeShadowColor != _badgeShadowColor)
    {
        _badgeShadowColor = badgeShadowColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeShadowSize:(CGSize)badgeShadowSize
{
    if (!CGSizeEqualToSize(badgeShadowSize, _badgeShadowSize))
    {
        _badgeShadowSize = badgeShadowSize;
        
        [self setNeedsDisplay];
    }
}


- (void)setPanable:(BOOL)panable{
    _panable = panable;
    self.userInteractionEnabled = _panable;
}

#pragma mark - Getters

- (CGFloat)badgeViewCornerRadius{
    if (_badgeViewCornerRadius <= 0.0f) {
        return self.bounds.size.width/2;
    }
    return _badgeViewCornerRadius;
}

- (UIView *)smallBadgeView{
    if (!_smallBadgeView) {
        _smallBadgeView = [[UIView alloc] init];
        _smallBadgeView.backgroundColor = self.badgeBackgroundColor;
        [self.superview insertSubview:_smallBadgeView belowSubview:self];
    }
    return _smallBadgeView;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.badgeBackgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    return _shapeLayer;
}

@end
