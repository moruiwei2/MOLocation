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


@end

@implementation MainViewController

#pragma mark - UITableViewDataSource

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MOMapViewController *movc = [[MOMapViewController alloc]init];
    movc.option = ^(MOPointAnnotation *pointAnnotation){
        
        NSLog(@"%@",pointAnnotation.name);
        
    };
}

@end
