//
//  MOMapViewController.h
//  officialDemoLoc
//
//  Created by 莫瑞伟 on 16/9/5.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MOPointAnnotation.h"

@interface MOMapViewController : UIViewController

@property (nonatomic, copy) void(^option)(MOPointAnnotation *pointAnnotation);

@end
