//
//  TableViewController.m
//  MLMessageHUDDemo
//
//  Created by 李梦龙 on 15/8/27.
//  Copyright (c) 2015年 CristianoRLong. All rights reserved.
//

#import "TableViewController.h"
#import "MLMessageHUD.h"

typedef NS_ENUM(NSInteger, MLSelectedType) {
    
    MLSelectedTypeShow = 2, //
    MLSelectedTypeShowDismissWithSuccessMessage,
    MLSelectedTypeShowDismissWithErrorMessage,
    MLSelectedTypeShowSuccessMessage,
    MLSelectedTypeShowErrorMessage,
    
    MLSelectedTypeShowSuccessMessageNavigationBar = 8,
    MLSelectedTypeShowErrorMessageNavigationBar,
    
    MLSelectedTypeShowMessage = 11,
};

static CGFloat const duration = 0.7;

@interface TableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *darkButton;

@property (weak, nonatomic) IBOutlet UIButton *lightButton;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 配置 TableView
    [self configureTableView];
    
    // 2. 配置 UI
    [self configureUI];
}

#pragma mark - 初始化方法
#pragma mark -
#pragma mark 配置 UI
- (void) configureUI {
}
#pragma mark 配置 TableView
- (void) configureTableView {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: self.view.bounds];
    imageView.image = [UIImage imageNamed:@"tableView_background"];
    
    [self.tableView setBackgroundView: imageView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableView Delegate && UITableView DataSource
#pragma mark -
#pragma mark 点击
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case MLSelectedTypeShow:
        {
            [MLMessageHUD show];
        }
            break;
            
        case MLSelectedTypeShowDismissWithSuccessMessage:
        {
            [MLMessageHUD show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MLMessageHUD dismissWithMessage:@"Load Success" messageType:MLHUDMessageTypeSuccess];
            });
        }
            break;
            
        case MLSelectedTypeShowDismissWithErrorMessage:
        {
            [MLMessageHUD show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MLMessageHUD dismissWithMessage:@"Load Error" messageType:MLHUDMessageTypeError];
            });
        }
            break;
            
        case MLSelectedTypeShowSuccessMessage:
        {
            [MLMessageHUD showSuccessMessage: @"Load Success" showStyle: MLHUDShowStyleNormal];
//            [MLMessageHUD showSuccessMessage: @"Loading Success"]; // 等价于上面这个方法, 默认的 ShowStyle 就是 MLHUDShowStyleNormal
        }
            break;
            
        case MLSelectedTypeShowErrorMessage:
        {
            [MLMessageHUD showErrorMessage: @"Load Error" showStyle: MLHUDShowStyleNormal];
//            [MLMessageHUD showErrorMessage: @"Loading Error"]; // 等价于上面这个方法, 默认的 ShowStyle 就是 MLHUDShowStyleNormal
        }
            break;
            
        case MLSelectedTypeShowSuccessMessageNavigationBar:
        {
            [MLMessageHUD showSuccessMessage: @"Load Success" showStyle: MLHUDShowStyleNavigationBar];
        }
            break;
            
        case MLSelectedTypeShowErrorMessageNavigationBar:
        {
            [MLMessageHUD showErrorMessage: @"Load Error" showStyle: MLHUDShowStyleNavigationBar];
        }
            break;
            
        case MLSelectedTypeShowMessage:
        {
            [MLMessageHUD showSuccessMessage: @"Refresh Success" showStyle: MLHUDShowStyleStatusBar];
        }
            
        default:
            break;
    }
}

#pragma mark - 点击事件
#pragma mark -
#pragma mark 选择 HUDStyle
- (IBAction)chooseHUDStyle:(UIButton *)sender {
    
    if (sender.selected) return;
    
    self.lightButton.selected = NO;
    self.darkButton.selected = NO;
    
    sender.selected = YES;
    
    if ([sender.titleLabel.text isEqualToString: @"HUDStyleDark"]) {
        [MLMessageHUD sharedMessageHUD].style = MLHUDStyleDark;
        self.title = [NSString stringWithFormat: @"HUDStyle: Dark"];
    } else {
        [MLMessageHUD sharedMessageHUD].style = MLHUDStyleLight;
        self.title = [NSString stringWithFormat: @"HUDStyle: Light"];
    }
}


@end
