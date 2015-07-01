//
//  ViewController.m
//  XMBadgeView-Demo
//
//  Created by shscce on 15/7/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "ViewController.h"

#import "XMBadgeView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet XMBadgeView *badgeViewFromXib;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //测试 直接从XIB中实例化 badgeView
    [self.badgeViewFromXib setBadgeText:@"10"];
    [self.badgeViewFromXib setBadgeViewAlignment:XMBadgeViewAlignmentCenterRight];
    
    //测试 直接addSubView添加到需要显示的父view
    XMBadgeView *badge = [[XMBadgeView alloc] initWithFrame:CGRectZero];
    [badge setPanable:NO];
    [badge setBadgeText:@"99+"];
    [badge setBadgeViewAlignment:XMBadgeViewAlignmentCenter];
    [self.view addSubview:badge];
    
    
    //测试使用initWithAttachView 添加badgeView
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(30, 80, 100, 100)];
    greenView.userInteractionEnabled = YES;
    greenView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:greenView];
    
    XMBadgeView *greenBadgeView = [[XMBadgeView alloc] initWithAttachView:greenView alignment:XMBadgeViewAlignmentTopRight];
    [greenBadgeView setBadgeText:@"31"];
    
    //测试使用initParentView 添加badgeView
    UIView *yellowView = [[UIView alloc] initWithFrame:CGRectMake(30, 200, 120, 120)];
    yellowView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:yellowView];
    
    XMBadgeView *yellowBadgeView = [[XMBadgeView alloc] initWithParentView:yellowView alignment:XMBadgeViewAlignmentCenter];
    [yellowBadgeView setPanable:YES];
    [yellowBadgeView setBadgeText:@"79"];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
