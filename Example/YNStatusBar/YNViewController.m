//
//  YNViewController.m
//  YNStatusBar
//
//  Created by luyinuo on 04/12/2022.
//  Copyright (c) 2022 luyinuo. All rights reserved.
//

#import "YNViewController.h"
#import <YNStatusBar/YNStatusBar.h>

@interface YNViewController ()
@property (nonatomic, strong) UIView *topToolView;
@property (nonatomic, strong) YNStatusBar *statusBar;
@end

@implementation YNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    ///创建顶部工具栏
    UIView *topToolView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,80)];
    UIImage *shadowImage = [UIImage imageNamed:@"top_shadow"];
    topToolView.layer.contents = (id)shadowImage.CGImage;
    self.topToolView = topToolView;
    [self.view addSubview:topToolView];
    
    
    YNStatusBar *bar = [[YNStatusBar alloc] initWithFrame:topToolView.bounds];
    bar.refreshTime = 2;
    self.statusBar = bar;
    [topToolView addSubview:bar];
    NSLog(@"viewDidLoad:%@",[NSValue valueWithCGRect:self.view.bounds]);
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    NSLog(@"viewWillLayoutSubviews:%@",[NSValue valueWithCGRect:self.view.bounds]);
    self.topToolView.frame = CGRectMake(0, 0, self.view.frame.size.width,80);
    self.statusBar.frame = CGRectMake(0, 0, self.view.frame.size.width,30);
}
/// 横屏
-(BOOL)shouldAutorotate{
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return  UIInterfaceOrientationLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
