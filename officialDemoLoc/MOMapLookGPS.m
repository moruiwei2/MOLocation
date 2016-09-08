//
//  MOMapLookGPS.m
//  爱任信
//
//  Created by 莫瑞伟 on 16/9/7.
//  Copyright © 2016年 moyejin. All rights reserved.
//

#import "MOMapLookGPS.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3

@interface MOMapLookGPS ()<AMapLocationManagerDelegate,MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet MAMapView *view_map;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
@property (nonatomic,copy) CLLocation *location;

@end

@implementation MOMapLookGPS

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查看定位";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view_map.delegate = self;
    self.view_map.showsCompass = NO;//隐藏罗盘
    self.view_map.showsScale = NO;//是否显示比例尺，默认为YES
    [self configLocationManager];
    [self initCompleteBlock];
    [self locAction];
    
    if (self.pointAnnotation) {
        [self.view_map setCenterCoordinate:self.pointAnnotation.location.coordinate animated:YES];
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        [annotation setCoordinate:self.pointAnnotation.location.coordinate];
        [annotation setTitle:[NSString stringWithFormat:@"%@", self.pointAnnotation.address]];
        [self addAnnotationToMapView:annotation];
        [self.view_map selectAnnotation:annotation animated:YES];
    }
    
}
- (IBAction)clickButton:(id)sender {
    if (self.location) {
        [self.view_map setCenterCoordinate:self.location.coordinate animated:YES];
    }
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout   = YES;
        annotationView.animatesDrop     = YES;
        annotationView.draggable        = NO;
        //        annotationView.pinColor         = MAPinAnnotationColorPurple;
        annotationView.image = [UIImage imageNamed:@"icon_position"];//icon_position
        return annotationView;
        
    }
    return nil;
}
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}
- (void)initCompleteBlock
{
    __weak typeof(self) weakSelf = self;
    
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            //如果为定位失败的error，则不进行annotation的添加
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        //得到定位信息，添加annotation
        if (location){
            weakSelf.location = location;
//            [weakSelf.view_map setCenterCoordinate:location.coordinate animated:YES];
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            [annotation setCoordinate:location.coordinate];
            [weakSelf addAnnotationToMapView:annotation];
            
        }
    };
}
- (void)locAction
{
    [self.view_map removeAnnotations:self.view_map.annotations];
    
    //进行单次定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
    
}
- (void)addAnnotationToMapView:(id<MAAnnotation>)annotation
{
    [self.view_map addAnnotation:annotation];
//    [self.view_map selectAnnotation:annotation animated:YES];
    [self.view_map setZoomLevel:15.1 animated:NO];
//    [self.view_map setCenterCoordinate:annotation.coordinate];
    
}

@end
