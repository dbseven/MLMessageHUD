//
//  MLMessageHUD.m
//  TestMessageView
//
//  Created by CristianoRLong on 15/8/26.
//  Copyright (c) 2015年 CristianoRLong. All rights reserved.
//

#import "MLMessageHUD.h"

static NSString *const MLMessageHUDImageCheck = @"checkmark";
static NSString *const MLMessageHUDImageCross = @"cross";
static NSString *const MLMessageHUDImageProgress = @"progress";

static NSString *const MLMessageHUDImageCheckWhite = @"checkmark_white";
static NSString *const MLMessageHUDImageCrossWhite = @"cross_white";
static NSString *const MLMessageHUDImageProgressWhite = @"progress_white";

static NSString *const MLMessageHUDImageKeyCheck = @"Check";
static NSString *const MLMessageHUDImageKeyCross = @"Cross";
static NSString *const MLMessageHUDImageKeyProgress = @"Progress";

static NSString *const MLMessageHUDSuccessAnimationKey = @"SuccessAnimation";
static NSString *const MLMessageHUDErrorAnimationKey = @"ErrorAnimation";

static CGFloat const MLMessageHUDMargin = 10;

/** 导航栏下方时的默认高度 */
static CGFloat const MLMessageHUDShowStyleNavigationDefaultHeight = 50;

/** 动画展示的时间 */
static CGFloat const MLMessageHUDShowDuration = 0.2;

/** 提示信息停留时间 */
static CGFloat const MLMessageHUDShowTimeDuration = 1.6;

/** 背景透明度 */
static CGFloat const MLMessageHUDBackgroundAlpha = 0.6;

/** Loading 的默认文字信息 */
static NSString *const MLMessageHUDLoadingMessage = @"加载中...";

@interface MLMessageHUD ()

/** 显示 "对勾" "叉子" 等图片的 ImageView */
@property (nonatomic, strong) UIImageView *imageView;

/** 显示 Loading 图片的 ImageView */
@property (nonatomic, strong) UIImageView *loadingImageView;

/** 显示 提示文字 的 Label */
@property (nonatomic, strong) UILabel *messageLabel;

/** 用来存放 "对勾""叉子"等 图片的字典 */
@property (nonatomic, strong) NSMutableDictionary *imageDict;

/** 存放资源的 Bundle */
@property (nonatomic, strong) NSBundle *resourseBundle;

/** 最大宽度 */
@property (nonatomic, assign) CGFloat maxWidth;

/** Tap 手势 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

/** 用来判断是否已经展示 */
@property (nonatomic, assign) BOOL isShow;

/** 用来自动 Dismiss 的定时器 */
@property (nonatomic, strong) NSTimer *autoDismissTimer;

/** 是否需要 ImageView 动画 */
@property (nonatomic, assign) BOOL needImageViewAnimation;

@end

@implementation MLMessageHUD
#pragma mark - 单例
#pragma mark -
static MLMessageHUD *_instence = nil;
+ (instancetype) allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instence = [super allocWithZone:zone];
    });
    return _instence;
}
+ (instancetype) sharedMessageHUD {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instence = [[[self class]alloc] init];
    });
    return _instence;
}

#pragma mark - 构造方法
#pragma mark -
#pragma mark 复写 Init 方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 1. 配置 UI
        [self configureUI];
        
        // 2. 配置成员变量
        [self configureVariables];
        
        // 3. 添加手势
        [self configureTapGestureRecognizer];
    }
    return self;
}

#pragma mark - 初始化方法
#pragma mark -
#pragma mark 添加手势
- (void) configureTapGestureRecognizer {
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapAction:)];
    self.doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer: self.doubleTap];
}
#pragma mark 配置成员变量
- (void) configureVariables {
    
    // 1. 存放图片资源的 Bundle
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"MLMessageHUDResource.bundle"];
    self.resourseBundle = [NSBundle bundleWithPath: bundlePath];
    
    // 2. HUD 样式
    self.style = MLHUDStyleDark;
    
    // 3. 设置最大宽度
    self.maxWidth = [UIScreen mainScreen].bounds.size.width/2.0;
    
    // 4. 需要双击手势
    self.needDoubleTap = YES;
}
#pragma mark 配置 UI
- (void) configureUI {

    // 1. 获取 Self 的宽度
    CGFloat width = [UIScreen mainScreen].bounds.size.width/3.0;
    
    // 2. 设置 Self
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.clipsToBounds = YES;
    self.windowLevel = UIWindowLevelStatusBar;
    [self makeKeyAndVisible];
    
    
    // 3. 创建内容试图
    self.contentView = [[UIView alloc] init];
    self.contentView.frame = CGRectMake(0, 0, width, width);
    self.contentView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    self.contentView.layer.cornerRadius = width/16;
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    self.contentView.layer.shadowOpacity = 0.5;
    self.contentView.layer.shadowRadius = 1.0;
    [self addSubview: self.contentView];
    
    // 4. 创建 imageView
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview: self.imageView];
    
    self.loadingImageView = [[UIImageView alloc] init];
    self.loadingImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview: self.loadingImageView];
    
    // 5. 创建 messageLabel
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 4;
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview: self.messageLabel];
}
#pragma mark 根据 MLHUDStyle 刷新 UI
- (void) refreshUI {
    
    switch (self.style) {
        case MLHUDStyleDark:
        {
            self.imageDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:MLMessageHUDImageCheckWhite ofType:@"png"]], MLMessageHUDImageKeyCheck,
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:MLMessageHUDImageCrossWhite ofType:@"png"]], MLMessageHUDImageKeyCross,
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:MLMessageHUDImageProgressWhite ofType:@"png"]], MLMessageHUDImageKeyProgress,
                              nil];

            self.messageLabel.textColor = [UIColor whiteColor];
            self.alpha = 0.0;
            
            switch (self.showStyle) {
                case MLHUDShowStyleNormal:
                {
                    CGFloat width = [UIScreen mainScreen].bounds.size.width/3.0;
                    
                    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: MLMessageHUDBackgroundAlpha]
                    ;
                    self.windowLevel = UIWindowLevelNormal;
                    self.contentView.frame = CGRectMake(0, 0, width, width);
                    self.contentView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
                    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.3];
                    self.contentView.layer.cornerRadius = width/16;
                }
                    break;
                    
                case MLHUDShowStyleNavigationBar:
                {
                    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.3];
                    self.backgroundColor = [UIColor clearColor];
                    self.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, MLMessageHUDShowStyleNavigationDefaultHeight);
                    self.windowLevel = UIWindowLevelNormal;
                    self.contentView.frame = (CGRect) {CGPointZero, self.frame.size};
                    self.contentView.layer.cornerRadius = 0;
                }
                    break;
                    
                case MLHUDShowStyleStatusBar:
                {
                    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.9];
                    self.backgroundColor = [UIColor clearColor];
                    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
                    self.windowLevel = UIWindowLevelStatusBar;
                    self.contentView.frame = (CGRect) {CGPointZero, self.frame.size};
                    self.imageView.hidden = YES;
                    self.loadingImageView.hidden = YES;
                    self.contentView.layer.cornerRadius = 0;
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
            
        case MLHUDStyleLight:
        {
            self.imageDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:MLMessageHUDImageCheck ofType:@"png"]], MLMessageHUDImageKeyCheck,
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:MLMessageHUDImageCross ofType:@"png"]], MLMessageHUDImageKeyCross,
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:MLMessageHUDImageProgress ofType:@"png"]], MLMessageHUDImageKeyProgress,
                              nil];
            
            self.messageLabel.textColor = [UIColor blackColor];
            self.alpha = 0.0;
            
            switch (self.showStyle) {
                case MLHUDShowStyleNormal:
                {
                    CGFloat width = [UIScreen mainScreen].bounds.size.width/3.0;
                    
                    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: MLMessageHUDBackgroundAlpha];
                    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                    self.windowLevel = UIWindowLevelNormal;
                    
                    self.contentView.frame = CGRectMake(0, 0, width, width);
                    self.contentView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
                    self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.7];
                    self.contentView.layer.cornerRadius = width/16;
                }
                    break;
                    
                case MLHUDShowStyleNavigationBar:
                {
                    self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.7];
                    self.backgroundColor = [UIColor clearColor];
                    self.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, MLMessageHUDShowStyleNavigationDefaultHeight);
                    self.windowLevel = UIWindowLevelNormal;
                    self.contentView.frame = (CGRect) {CGPointZero, self.frame.size};
                    self.contentView.layer.cornerRadius = 0;
                }
                    break;
                    
                case MLHUDShowStyleStatusBar:
                {
                    self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.9];
                    self.backgroundColor = [UIColor clearColor];
                    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
                    self.windowLevel = UIWindowLevelStatusBar;
                    self.contentView.frame = (CGRect) {CGPointZero, self.frame.size};
                    self.imageView.hidden = YES;
                    self.loadingImageView.hidden = YES;
                    self.contentView.layer.cornerRadius = 0;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 公有方法
#pragma mark -
#pragma mark 显示
+ (void) show {
    
    MLMessageHUD *messageHUD = [MLMessageHUD sharedMessageHUD];
    [messageHUD stopTimer];
    [messageHUD showMessageHUDWithMessage: MLMessageHUDLoadingMessage
                                    image: messageHUD.imageDictionary[MLMessageHUDImageKeyProgress]
                                showStyle: MLHUDShowStyleNormal messageType: MLHUDMessageTypeLoading];
}
#pragma mark 隐藏
+ (void) dismiss {
    
    MLMessageHUD *messageHUD = [MLMessageHUD sharedMessageHUD];
    [messageHUD hideMessageHUDWithShowStyle: messageHUD.showStyle animation: NO];
}
#pragma mark 动画隐藏
+ (void) dismissWithAnimation {
    
    MLMessageHUD *messageHUD = [MLMessageHUD sharedMessageHUD];
    [messageHUD hideMessageHUDWithShowStyle: messageHUD.showStyle animation: YES];
}
#pragma mark 显示文字, 然后隐藏
+ (void) dismissWithMessage:(NSString *)message messageType:(MLHUDMessageType)messageType {
    
    MLMessageHUD *messageHUD = [MLMessageHUD sharedMessageHUD];
    
    UIImage *showImage = nil;

    switch (messageType) {
        case MLHUDMessageTypeSuccess:
        {
            showImage = messageHUD.imageDictionary[MLMessageHUDImageKeyCheck];
        }
            break;
        
        case MLHUDMessageTypeError:
        {
            showImage = messageHUD.imageDictionary[MLMessageHUDImageKeyCross];
        }
            break;
            
        default:
            break;
    }
    
    messageHUD.needImageViewAnimation = YES;
    
    [messageHUD configureContentWithMessage: message image: showImage messageType: messageType];
    
    messageHUD.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:MLMessageHUDShowTimeDuration target:[self class] selector:@selector(dismissWithAnimation) userInfo:nil repeats:NO];
}

#pragma mark 提示错误信息,  默认的 ShowStyle = MLHUDShowStyleNormal
+ (void) showErrorMessage:(NSString *)message {
    [MLMessageHUD showErrorMessage:message showStyle: MLHUDShowStyleNormal];
}

#pragma mark 提示错误信息
+ (void) showErrorMessage:(NSString *)message showStyle:(MLHUDShowStyle)showStyle {
    MLMessageHUD *messageHUD = [MLMessageHUD sharedMessageHUD];
    
    [messageHUD showMessageHUDWithMessage: message image: messageHUD.imageDictionary[MLMessageHUDImageKeyCross] showStyle: showStyle messageType: MLHUDMessageTypeError];
    
    [messageHUD startTimer];
}

#pragma mark 提示成功信息,  默认的 ShowStyle = MLHUDShowStyleNormal
+ (void) showSuccessMessage:(NSString *)message {
    [MLMessageHUD showSuccessMessage: message showStyle: MLHUDShowStyleNormal];
}

#pragma mark 提示成功信息
+ (void) showSuccessMessage:(NSString *)message showStyle:(MLHUDShowStyle)showStyle {
    
    MLMessageHUD *messageHUD = [MLMessageHUD sharedMessageHUD];
    
    [messageHUD showMessageHUDWithMessage: message image: messageHUD.imageDictionary[MLMessageHUDImageKeyCheck] showStyle: showStyle messageType: MLHUDMessageTypeSuccess];
   
    [messageHUD startTimer];
}

#pragma mark - Set 方法重写
#pragma mark -
#pragma mark Set Style
- (void) setStyle:(MLHUDStyle)style {
    
    if (_style == style) {
        return;
    }
    
    _style = style;
    
    // 1. 根据 style 刷新 UI
    [self refreshUI];
}

#pragma mark Set ShowStyle
- (void) setShowStyle:(MLHUDShowStyle)showStyle {
    
    if (_showStyle == showStyle) {
        return;
    }
    
    _showStyle = showStyle;
    
    // 1. 刷新 UI
    [self refreshUI];
}

#pragma mark - Get 方法重写
#pragma mark -
#pragma mark Get ImageDictionary
- (NSMutableDictionary *) imageDictionary {
    return self.imageDict;
}

#pragma mark - 私有方法
#pragma mark -
#pragma mark 播放图片动画
- (void) beginImageViewAnimationWithMessageType:(MLHUDMessageType)messageType {
    
    switch (messageType) {
        case MLHUDMessageTypeSuccess: // 成功时, "对勾"图片会有个放大缩小的动画
        {
            CAKeyframeAnimation *successAnimation = [CAKeyframeAnimation animationWithKeyPath: @"transform.scale"];
            successAnimation.values = @[@(1.2), @(0.8), @(1.0)];
            successAnimation.duration = 0.25f;
            [self.imageView.layer addAnimation: successAnimation forKey: MLMessageHUDSuccessAnimationKey];
        }
            break;
            
        case MLHUDMessageTypeError: // 失败时, "叉子"图片会有个抖动的动画
        {
            CAKeyframeAnimation *errorAnimation = [CAKeyframeAnimation animationWithKeyPath: @"transform.translation.x"];
            errorAnimation.values = @[@(-2), @(2), @(-2), @(2), @(-2), @(2), @(0)];
            errorAnimation.duration = 0.25f;
            [self.imageView.layer addAnimation: errorAnimation forKey: MLMessageHUDErrorAnimationKey];
        }
            
        default:
            break;
    }
}
#pragma mark 刷新控件状态
- (void) refreshUIState {
    
    [self.loadingImageView.layer removeAnimationForKey: MLMessageHUDLoadingMessage];
    [self.loadingImageView.layer removeAllAnimations];
    [self.imageView.layer removeAnimationForKey: MLMessageHUDErrorAnimationKey];
    [self.imageView.layer removeAnimationForKey: MLMessageHUDSuccessAnimationKey];
    [self.imageView.layer removeAllAnimations];
    self.messageLabel.text = @"";
    self.isShow = NO;
    self.alpha = 0.0;
}
#pragma mark 隐藏 MLMessageHUD
- (void) hideMessageHUDWithShowStyle:(MLHUDShowStyle)showStyle animation:(BOOL)needAnimation{
    
    // 1. 关闭用户交互
    self.userInteractionEnabled = NO;
    
    // 2. 根据 ShowStyle, 设置 UI, 进行隐藏动画
    switch (showStyle) {
        case MLHUDShowStyleNormal:
        {
            if (needAnimation) {
                [UIView animateWithDuration: MLMessageHUDShowDuration delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 0.0;
                    self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                } completion:^(BOOL finished) {
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    [self refreshUIState];
                }];
            } else {
                [self refreshUIState];
            }
        }
            break;
            
        case MLHUDShowStyleNavigationBar:
        {
            if (needAnimation) {
                [UIView animateWithDuration: MLMessageHUDShowDuration delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 0.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 0.1);
                } completion:^(BOOL finished) {
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    [self refreshUIState];
                }];
            } else {
                [self refreshUIState];
            }
        }
            break;
            
        case MLHUDShowStyleStatusBar:
        {
            if (needAnimation) {
                [UIView animateWithDuration: MLMessageHUDShowDuration delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self refreshUIState];
                }];
            } else {
                [self refreshUIState];
            }
        }
            break;
            
        case MLHUDShowStyleBottomBar:
        {
            
        }
            break;
            
        default:
            break;
    }
}
#pragma mark 动画显示 MLMessageHUD
- (void) showMessageHUDWithMessage:(NSString *)message image:(UIImage *)image showStyle:(MLHUDShowStyle)showStyle messageType:(MLHUDMessageType)messageType {
    
    @synchronized(self)  {
        
        if (self.isShow) {
            [self hideMessageHUDWithShowStyle: MLHUDShowStyleNormal animation: NO];
        }
        self.isShow = YES;
        
        // 0. 保存 ShowStyle
        self.showStyle = showStyle;
        
        // 1. 判断是否需要双击手势
        if (self.needDoubleTap) {
            self.userInteractionEnabled = YES;
        } else {
            self.userInteractionEnabled = NO;
        }
        
        // 2. 根据 ShowStyle, 设置 UI, 进行动画显示
        switch (showStyle) {
            case MLHUDShowStyleNormal:
            {
                // 3. 设置显示内容
                [self configureContentWithMessage: message image: image messageType: messageType];
                
                // 4. 播放动画
                self.contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                [UIView animateWithDuration:MLMessageHUDShowDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 1.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    
                    [self beginImageViewAnimationWithMessageType: messageType];
                }];
            }
                break;
                
            case MLHUDShowStyleNavigationBar:
            {
                // 3. 设置显示内容
                [self configureContentWithMessage: message image: image messageType: messageType];
                
                // 4. 播放动画
                self.contentView.transform = CGAffineTransformMakeScale(1.0, 0.0);
                [UIView animateWithDuration:MLMessageHUDShowDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 1.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    
                    [self beginImageViewAnimationWithMessageType: messageType];
                }];
            }
                break;
                
            case MLHUDShowStyleStatusBar:
            {
                // 3. 设置显示内容
                [self configureContentWithMessage: message image: image messageType: messageType];
                
                // 4. 动画显示
                [UIView animateWithDuration:MLMessageHUDShowDuration*2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 1.0;
                } completion:^(BOOL finished) {
                }];
            }
                break;
                
            case MLHUDShowStyleBottomBar:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark 配置显示内容 (适用于: MLHUDShowStyleStatusBar)
- (void) configureStatusBarStyleContentWithMessage:(NSString *)message image:(UIImage *)image messageType:(MLHUDMessageType)messageType {
    
    // 0. 停止动画
    [self.loadingImageView.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 1. 设置 Label 位置
    self.messageLabel.frame = CGRectMake(0, 0, self.contentView.bounds.size.width - 2*MLMessageHUDMargin, 20);
    
    // 2. 设置 Label 文字
    self.messageLabel.text = message;
}

#pragma mark 配置显示内容 (适用于: MLHUDShowStyleNavigationBar)
- (void) configureNavigationBarStyleContentWithMessage:(NSString *)message image:(UIImage *)image messageType:(MLHUDMessageType)messageType {
    
    // 0. 停止动画
    [self.loadingImageView.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 1. 设置图片位置
    CGFloat scale = image.size.width / image.size.height;
    CGFloat imageHeight = MLMessageHUDShowStyleNavigationDefaultHeight - MLMessageHUDMargin*2;
    CGFloat imageWidth = scale * imageHeight;
    self.loadingImageView.frame = CGRectMake(MLMessageHUDMargin, MLMessageHUDMargin, imageWidth, imageHeight);
    self.imageView.frame = self.loadingImageView.frame;
    
    // 2. 设置 Label 位置
    self.messageLabel.frame = CGRectMake(CGRectGetMaxX(self.loadingImageView.frame)+MLMessageHUDMargin, 0, self.contentView.bounds.size.width - 2*MLMessageHUDMargin - imageWidth, self.contentView.frame.size.height);
    
    // 3. 显示或隐藏 Loading ImageView
    if ([message isEqualToString: MLMessageHUDLoadingMessage]) {
        
        self.loadingImageView.hidden = NO;
        self.imageView.hidden = YES;
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z" ];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue = @( 100 * M_PI );
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.duration = 36.0f;
        rotationAnimation.autoreverses = YES;
        [self.loadingImageView.layer addAnimation: rotationAnimation  forKey: MLMessageHUDLoadingMessage];
    } else {
        self.loadingImageView.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    // 11. 设置显示内容
    //    CATransition *animation = [CATransition animation];
    //    animation.duration = MLMessageHUDShowDuration * 2;
    self.messageLabel.text = message;
    //    [self.messageLabel.layer addAnimation:animation forKey:nil];
    self.imageView.image = image;
    self.loadingImageView.image = self.imageDict[MLMessageHUDImageKeyProgress];
    
    // 12. 播放 ImageView 动画
    if (self.needImageViewAnimation) {
        self.needImageViewAnimation = NO;
        [self beginImageViewAnimationWithMessageType: messageType];
    }
}

#pragma mark 配置显示内容 (适用于: MLHUDShowStyleNormal 和 MLHUDShowStyleNavigationBar)
- (void) configureContentWithMessage:(NSString *)message image:(UIImage *)image messageType:(MLHUDMessageType)messageType {
    
    if (self.showStyle == MLHUDShowStyleStatusBar) {
        [self configureStatusBarStyleContentWithMessage: message image: image messageType: messageType];
        return;
    }
    
    if (self.showStyle == MLHUDShowStyleNavigationBar) {
        [self configureNavigationBarStyleContentWithMessage: message image: image messageType: messageType];
        return;
    }
    
    // 0. 停止动画
    [self.loadingImageView.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 1. 计算 Message 的长度, 获取 Label 应有的高度
    CGFloat messageLabelHeight = [message boundingRectWithSize: CGSizeMake(image.size.width + 2*MLMessageHUDMargin, MAXFLOAT)
                                                       options: NSStringDrawingUsesLineFragmentOrigin
                                                    attributes: @{NSFontAttributeName : self.messageLabel.font}
                                                       context: nil].size.height + MLMessageHUDMargin;
    
    // 2. 获取 Image 的高度
    CGFloat imageHeight = image.size.height;
    
    // 3. 计算并设置 MLMessageHUD 的 bounds
    CGFloat height = messageLabelHeight + imageHeight + 3*MLMessageHUDMargin;
    CGFloat width = height<self.maxWidth ? height : self.maxWidth;
    
    // 4. 宽度计算完成后, 再计算一次 Label 的高度
    CGFloat currentHeight = [message boundingRectWithSize: CGSizeMake(width - 2*MLMessageHUDMargin, MAXFLOAT)
                                                  options: NSStringDrawingUsesLineFragmentOrigin
                                               attributes: @{NSFontAttributeName : self.messageLabel.font}
                                                  context: nil].size.height + MLMessageHUDMargin;
    
    // 5. 如果计算后的 Label 高度 小于 之前 Label 的高度, 则 Self 的高度应该减去一个差值
    if (currentHeight < messageLabelHeight) {
        height -= (messageLabelHeight - currentHeight);
    }
    
    // 6. 设置 UI 控件的位置
    [UIView animateWithDuration: MLMessageHUDShowDuration delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        // 7. 设置 内容视图的大小
        self.contentView.bounds = (CGRect){CGPointZero, {width, height}};
        
        // 8. 设置 Image 的 Frame
        self.imageView.frame = CGRectMake((self.contentView.bounds.size.width - image.size.width) * 0.5, MLMessageHUDMargin, image.size.width, imageHeight);
        self.loadingImageView.frame = self.imageView.frame;
        
        // 9. 设置 Label 的 位置
        self.messageLabel.frame = CGRectMake(MLMessageHUDMargin, CGRectGetMaxY(self.imageView.frame) + MLMessageHUDMargin, self.contentView.bounds.size.width - 2*MLMessageHUDMargin, currentHeight);
    } completion:^(BOOL finished) {}];
    
    // 10. 显示或隐藏 Loading ImageView
    if ([message isEqualToString: MLMessageHUDLoadingMessage]) {
        
        self.loadingImageView.hidden = NO;
        self.imageView.hidden = YES;
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z" ];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue = @( 100 * M_PI );
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.duration = 36.0f;
        rotationAnimation.autoreverses = YES;
        [self.loadingImageView.layer addAnimation: rotationAnimation  forKey: MLMessageHUDLoadingMessage];
    } else {
        self.loadingImageView.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    // 11. 设置显示内容
//    CATransition *animation = [CATransition animation];
//    animation.duration = MLMessageHUDShowDuration * 2;
    self.messageLabel.text = message;
//    [self.messageLabel.layer addAnimation:animation forKey:nil];
    self.imageView.image = image;
    self.loadingImageView.image = self.imageDict[MLMessageHUDImageKeyProgress];
    
    // 12. 播放 ImageView 动画
    if (self.needImageViewAnimation) {
        self.needImageViewAnimation = NO;
        [self beginImageViewAnimationWithMessageType: messageType];
    }
}

#pragma mark 停止定时器
- (void) stopTimer {
    
    [[MLMessageHUD sharedMessageHUD].autoDismissTimer invalidate];
    [MLMessageHUD sharedMessageHUD].autoDismissTimer = nil;
}

#pragma mark 开启定时器
- (void) startTimer {
    
    if ([MLMessageHUD sharedMessageHUD].autoDismissTimer.valid) {
        [[MLMessageHUD sharedMessageHUD] stopTimer];
    }
    
    [MLMessageHUD sharedMessageHUD].autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:MLMessageHUDShowTimeDuration target:[self class] selector:@selector(dismissWithAnimation) userInfo:nil repeats:NO];
}

#pragma mark - 事件
#pragma mark -
#pragma mark Tap 手势事件
- (void) tapAction:(UITapGestureRecognizer *)tap {
    [[MLMessageHUD sharedMessageHUD] stopTimer];
    [MLMessageHUD dismissWithAnimation];
}

@end
