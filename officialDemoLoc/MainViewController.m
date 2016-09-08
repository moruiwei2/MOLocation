//
//  MainViewController.m
//  AMapLocationDemo
//
//  Created by 刘博 on 16/3/7.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MainViewController.h"
#import "MOMapViewController.h"

@interface MainViewController ()

@property (nonatomic,weak)UITextField *textF;

@end

@implementation MainViewController

#pragma mark - UITableViewDataSource

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITextField *textF = [[UITextField alloc]init];
    textF.placeholder = @"点击空白处push";
    textF.frame = CGRectMake(50, 120, 200, 40);
    self.textF = textF;
    [self.view addSubview:textF];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    MOMapViewController *movc = [[MOMapViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    movc.option = ^(MOPointAnnotation *pointAnnotation){
        weakSelf.textF.text = pointAnnotation.name;
        NSLog(@"%@",pointAnnotation.name);
        
    };
    [self.navigationController pushViewController:movc animated:YES];
}


@end
