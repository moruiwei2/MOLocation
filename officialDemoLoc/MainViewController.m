//
//  MainViewController.m
//  officialDemoLoc
//
//  Created by 莫瑞伟 on 16/9/9.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MainViewController.h"
#import "MOPointAnnotation.h"
#import "MOMapViewController.h"
#import "MOMapLookGPS.h"

@interface MainViewController ()

@property (nonatomic,strong)MOPointAnnotation *pointAnnotation;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (IBAction)clickPush:(id)sender {
    
    MOMapViewController *vc = [[MOMapViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    vc.option = ^(MOPointAnnotation *pointAnnotation){
        weakSelf.pointAnnotation = pointAnnotation;
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)clickLook:(id)sender {
    if (self.pointAnnotation) {
        MOMapLookGPS *vc = [[MOMapLookGPS alloc]init];
        vc.pointAnnotation = self.pointAnnotation;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}



@end
