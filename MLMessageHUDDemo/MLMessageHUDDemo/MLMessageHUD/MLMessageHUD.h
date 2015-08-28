//
//  MLMessageHUD.h
//  TestMessageView
//
//  Created by CristianoRLong on 15/8/26.
//  Copyright (c) 2015年 CristianoRLong. All rights reserved.
//

/**
 *  MLMessageHUD
 *      
 */

#import <UIKit/UIKit.h>

/** HUD 样式, 黑色 || 白色 */
typedef NS_ENUM(NSInteger, MLHUDStyle) {
    MLHUDStyleLight, // 黑色背景
    MLHUDStyleDark // 白色背景
};

/** HUD 出现样式 */
typedef NS_ENUM(NSInteger, MLHUDShowStyle) {
    MLHUDShowStyleNormal, // 出现在试图中心
    MLHUDShowStyleStatusBar, // 出现在状态栏中
    MLHUDShowStyleNavigationBar, // 出现在导航栏下方
    MLHUDShowStyleBottomBar, // 出现在屏幕下方  PS: 未实现
};

/** HUD 消息样式 */
typedef NS_ENUM(NSInteger, MLHUDMessageType) {
    MLHUDMessageTypeLoading,
    MLHUDMessageTypeSuccess, // 成功, 会显示 "对勾" 的图片
    MLHUDMessageTypeError // 失败, 会显示 "叉子" 的图片
};

@interface MLMessageHUD : UIWindow
/**
 *   MLMessageHUD 单例对象
 *
 *  @return MLMessageHUD单例
 */
+ (instancetype) sharedMessageHUD;

/** MLMessageHUD 的样式 */
@property (nonatomic, assign) MLHUDStyle style;

/** MLMessageHUD 的出现样式 */
@property (nonatomic, assign) MLHUDShowStyle showStyle;

/**
 *  用来存放 "对勾""叉子"等 图片的字典
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *imageDictionary;

/** 内容试图 */
@property (nonatomic, strong) UIView *contentView;

/** 是否需要双击手势, 双击手势默认行为: Dismiss 掉 MLMessageHUD */
@property (nonatomic, assign) BOOL needDoubleTap;

/**
 *  show 方法会展示默认的 Loading 样式
 */
+ (void) show;

/**
 *  提示错误信息,  默认的 ShowStyle = MLHUDShowStyleNormal
 *
 *  @param message 文字信息
 */
+ (void) showErrorMessage:(NSString *)message;

/**
 *  提示错误信息
 *
 *  @param message   文字信息
 *  @param showStyle 展示方式
 */
+ (void) showErrorMessage:(NSString *)message showStyle:(MLHUDShowStyle)showStyle;

/**
 *  提示成功信息,  默认的 ShowStyle = MLHUDShowStyleNormal
 *
 *  @param message 文字信息
 */
+ (void) showSuccessMessage:(NSString *)message;

/**
 *  提示成功信息
 *
 *  @param message   文字信息
 *  @param showStyle 展示方式
 */
+ (void) showSuccessMessage:(NSString *)message showStyle:(MLHUDShowStyle)showStyle;

/**
 *  隐藏
 */
+ (void) dismiss;

/**
 *  动画隐藏 (如果您希望在 UIViewController 的 viewWillDisappear 或 viewDidDisapper 中 dismiss 掉 MLMessageHUD, 请使用 +(void) dismiss 方法)
 */
+ (void) dismissWithAnimation;

/**
 *  展示文字, 然后隐藏 (当您确定 MLMessageHUD 正在处于 Loading 状态显示的时候, 调用此方法来提示用户成功 或 失败)
 *
 *  @param message     需要展示的消息
 *  @param messageType 消息类型, 成功 或 失败
 */
+ (void) dismissWithMessage:(NSString *)message messageType:(MLHUDMessageType)messageType;

@end
