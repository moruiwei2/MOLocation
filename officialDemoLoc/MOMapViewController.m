//
//  MOMapViewController.m
//  officialDemoLoc
//
//  Created by 莫瑞伟 on 16/9/5.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MOMapViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MOPointAnnotation.h"
#import "officialDemoLoc-Swift.h"
#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3

@interface MOMapViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate,UISearchBarDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet MAMapView *view_map;
@property (weak, nonatomic) IBOutlet UITableView *tableView_main;
@property (weak, nonatomic) IBOutlet UITableView *tableView_two;
@property (nonatomic,strong) NSMutableArray *arr_data;
@property (nonatomic,strong) NSMutableArray *arr_two;
@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar_main;
@property (strong,nonatomic) AMapSearchAPI *search;
@property (nonatomic,copy) CLLocation *location;
@property (nonatomic,strong) MAPointAnnotation *pointAnnotation;
@property (nonatomic,strong) MOPointAnnotation *myPointAnnotation;
@property (nonatomic,assign) NSUInteger optionRow;
@property (nonatomic,assign) BOOL isClick;
@property (nonatomic,assign) BOOL isGPSSuccess;
@property (weak, nonatomic) IBOutlet UIImageView *imageView_icon;
@property (weak, nonatomic) IBOutlet UIView *view_back;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button_cencal_Ri;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageView_Y;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cencal_W;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *search_Y;//搜索框Y

@end

@implementation MOMapViewController
- (NSMutableArray *)arr_two
{
    if (!_arr_two) {
        _arr_two = [NSMutableArray array];
    }
    return _arr_two;
}
- (NSMutableArray *)arr_data
{
    if (!_arr_data) {
        _arr_data = [NSMutableArray array];
    }
    return _arr_data;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
            //定位功能可用，开始定位
        }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        [MOAlertView showAlertWithTitle:@"定位服务" message:@"请开启定位服务" buttonArrayAsString:@[@"取消",@"去开启"] finish:^(NSInteger index) {
            if (index == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"定位";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.searchBar_main.delegate = self;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    //设置代理
    self.view_map.delegate = self;
    self.view_map.showsCompass = NO;//隐藏罗盘
    
    [self initCompleteBlock];
    //初始化
    [self configLocationManager];
    //开始定位
    [self locAction];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 30);
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *ri = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = ri;
    
    UIButton *button_let = [UIButton buttonWithType:UIButtonTypeCustom];
    button_let.frame = CGRectMake(0, 0, 50, 30);
    [button_let setTitle:@"取消" forState:UIControlStateNormal];
    //    [button_let setTitleColor:[UIColor colorWithRed:21.0/255.0 green:126.0/255.0 blue:251.0/255.0 alpha:1] forState:UIControlStateNormal];
    [button_let setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [button_let addTarget:self action:@selector(clickCecan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *let = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationController.navigationItem.leftBarButtonItem = let;
}
- (void)clickCecan
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clickOrigin:(id)sender {
    
    [self.view_map setCenterCoordinate:self.location.coordinate animated:YES];
    
}
/**
 *  点击确定
 */
- (void)clickButton
{
    if (self.arr_data.count > 0 && self.option != nil) {
        self.option(self.arr_data[self.optionRow]);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//cancel按钮点击时调用
- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar

{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
    
}
/**
 *  取消输入
 *
 *  @param sender
 */
- (IBAction)clickCencal:(id)sender {
    __weak typeof(self) weakSelf = self;
    self.search_Y.constant = 44;
    self.cencal_W.constant = 0;
    self.button_cencal_Ri.constant = 0;
    [UIView animateWithDuration:0.35 animations:^{
        [weakSelf.view layoutIfNeeded];
        weakSelf.view_back.alpha = 0;
    }];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.searchBar_main.text = @"";
    [self.searchBar_main resignFirstResponder];
    
    [self.arr_two removeAllObjects];
    [self.tableView_two reloadData];
    if (self.view_back.userInteractionEnabled == YES) {
        self.view_back.userInteractionEnabled = NO;
        self.tableView_two.alpha = 0;
    }
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    __weak typeof(self) weakSelf = self;
    self.search_Y.constant = 0;
    self.cencal_W.constant = 40;
    self.tableView_two.alpha = 1;
    self.view_back.alpha = 1;
    self.button_cencal_Ri.constant = 10;
    [UIView animateWithDuration:0.35 animations:^{
        [weakSelf.view layoutIfNeeded];
        weakSelf.tableView_two.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
    }];
    self.view_back.userInteractionEnabled = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.view_back.userInteractionEnabled == YES) {
        [self clickCencal:nil];
    }
}
//点击搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location            =  [AMapGeoPoint locationWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
    request.keywords            = searchBar.text;
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.offset = 50;
    request.requireExtension    = YES;
    [self.search AMapPOIAroundSearch:request];
    [searchBar endEditing:YES];
}
- (void)searchNearbyWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.isGPSSuccess) {
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        /* 按照距离排序. */
        request.sortrule  = 0;
        request.offset = 40;
        request.requireExtension = YES;
        //    request.types = @"050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|150000|160000|170000";
        request.types = @"道路|地点|大厦|学校|广场|大道|花苑|体育场|KTV|中学|小学|地址|广场|酒店|医院|美食";
        [self.search AMapPOIAroundSearch:request];
    }
    shakerAnimation(self.imageView_icon, 1.2, 10);
}
/**
 *  动画效果
 */
void shakerAnimation (UIView *view ,NSTimeInterval duration,float height){
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat currentTx = view.transform.ty;
    animation.duration = duration;
    animation.values = @[@(currentTx), @(currentTx + height), @(currentTx-height/3*2), @(currentTx + height/3*2), @(currentTx -height/3), @(currentTx + height/3), @(currentTx)];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:animation forKey:@"kViewShakerAnimationKey"];
}
//当检索成功时，会进到 onPOISearchDone 回调函数中，在该回调中，可以把检索结果在地图上绘制点展示出来。
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    [self.arr_data removeAllObjects];
    [self.arr_two removeAllObjects];
    if (self.myPointAnnotation) {
        [self.arr_data addObject:self.myPointAnnotation];
        self.myPointAnnotation = nil;
    }
    self.tableView_main.contentSize = CGSizeMake(0, 0);
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        CLLocation *locaron = [[CLLocation alloc]initWithLatitude:obj.location.latitude longitude:obj.location.longitude];
        MOPointAnnotation *moPoin = [[MOPointAnnotation alloc]init];
        moPoin.uid =  obj.uid;//!< POI全局唯一ID
        moPoin.name = obj.name; //!< 名称
        moPoin.type = obj.type; //!< 兴趣点类型
        moPoin.location = locaron; //!< 经纬度
        moPoin.address = obj.address;  //!< 地址
        moPoin.tel = obj.tel;  //!< 电话
        moPoin.distance = obj.distance; //!< 距中心点距离，仅在周边搜索时有效
        moPoin.parkingType = obj.parkingType; //!< 停车场类型，地上、地下、路边
        moPoin.postcode = obj.postcode; //!< 邮编
        moPoin.website = obj.website; //!< 网址
        moPoin.email = obj.email;    //!< 电子邮件
        moPoin.province = obj.province; //!< 省
        moPoin.pcode = obj.pcode;   //!< 省编码
        moPoin.city = obj.city; //!< 城市名称
        moPoin.citycode = obj.citycode; //!< 城市编码
        moPoin.district = obj.district; //!< 区域名称
        moPoin.adcode = obj.adcode;   //!< 区域编码
        moPoin.gridcode = obj.gridcode; //!< 地理格ID
//        moPoin.enterLocation = obj.enterLocation; //!< 入口经纬度
//        moPoin.exitLocation = obj.exitLocation; //!< 出口经纬度
        moPoin.direction = obj.direction; //!< 方向
        moPoin.hasIndoorMap = obj.hasIndoorMap; //!< 是否有室内地图
        moPoin.businessArea = obj.businessArea; //!< 所在商圈
//        moPoin.indoorData = obj.indoorData; //!< 室内信息
//        moPoin.subPOIs = obj.subPOIs; //!< 子POI列表 AMapSubPOI 数组
        if (self.view_back.userInteractionEnabled) {
            [self.arr_two addObject:moPoin];
        }
        else{
            [self.arr_data addObject:moPoin];
        }
        
        
    }];
    if (self.view_back.userInteractionEnabled) {
        if (self.arr_two.count > 0) {
            self.tableView_two.backgroundColor = [UIColor whiteColor];
        }
        else{
            self.tableView_two.backgroundColor = [UIColor clearColor];
        }
        [self.tableView_two reloadData];
    }
    else{
        [self.tableView_main reloadData];
    }
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        [self.view_map setCenterCoordinate:[poiAnnotations[0] coordinate]];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.view_map showAnnotations:poiAnnotations animated:NO];
    }
}
- (void)locAction
{
    [self.view_map removeAnnotations:self.view_map.annotations];
    
    //进行单次定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
    
}
- (void)initCompleteBlock
{
    __weak MOMapViewController *weakSelf = self;
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
                
            [weakSelf.view_map setCenterCoordinate:location.coordinate animated:YES];
            weakSelf.location = location;
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            [annotation setCoordinate:location.coordinate];
//            if (regeocode)
//            {
//                [annotation setTitle:[NSString stringWithFormat:@"%@", regeocode.formattedAddress]];
//                [annotation setSubtitle:[NSString stringWithFormat:@"%@-%@-%.2fm", regeocode.citycode, regeocode.adcode, location.horizontalAccuracy]];
//            }
//            else
//            {
//                [annotation setTitle:[NSString stringWithFormat:@"lat:%f;lon:%f;", location.coordinate.latitude, location.coordinate.longitude]];
//                [annotation setSubtitle:[NSString stringWithFormat:@"accuracy:%.2fm", location.horizontalAccuracy]];
//            }
            [weakSelf addAnnotationToMapView:annotation];
            weakSelf.isGPSSuccess = YES;
            //开始搜索
            [weakSelf searchNearbyWithCoordinate:location.coordinate];
            
        }
    };
}
- (void)addAnnotationToMapView:(id<MAAnnotation>)annotation
{
    [self.view_map addAnnotation:annotation];
//    [self.view_map selectAnnotation:annotation animated:YES];
    [self.view_map setZoomLevel:15.1 animated:NO];
    [self.view_map setCenterCoordinate:annotation.coordinate];
    
}
- (void)cleanUpAction
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
    
    [self.locationManager setDelegate:nil];
    
    [self.view_map removeAnnotations:self.view_map.annotations];
    
    
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
#pragma mark - MAMapView Delegate
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
/**
 *  移动中心点完成
 *
 */
-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!self.isClick && self.isGPSSuccess == YES) {//如果是用户滚动中心点
        self.optionRow = 0;
        //开始搜索
        [self searchNearbyWithCoordinate:mapView.region.center];
    }
    else{
        self.isClick = NO;
    }
   
}

//MARK:tableView代理方法----------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView_main){
        return self.arr_data.count;
    }
    else{
        return self.arr_two.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView_main) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        MOPointAnnotation *poin = self.arr_data[indexPath.row];
        cell.textLabel.text = poin.name;
        cell.detailTextLabel.text = poin.address;
        if (self.optionRow == indexPath.row) {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        return cell;
    }
    else{
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        MOPointAnnotation *poin = self.arr_two[indexPath.row];
        cell.textLabel.text = poin.name;
        cell.detailTextLabel.text = poin.address;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView_main) {
        MOPointAnnotation *poin = self.arr_data[indexPath.row];
        CLLocation *locaron = [[CLLocation alloc]initWithLatitude:poin.location.coordinate.latitude longitude:poin.location.coordinate.longitude];
        self.isClick = YES;
        //设置中心点
        [self.view_map setCenterCoordinate:locaron.coordinate animated:YES];
        self.optionRow = indexPath.row;
        [self.tableView_main reloadData];
    }
    else{
        MOPointAnnotation *poin = self.arr_two[indexPath.row];
        self.myPointAnnotation = poin;
        [self.view_map setCenterCoordinate:poin.location.coordinate animated:YES];
        [self clickCencal:nil];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView_two) {
        return 0.01;
    }
    return 10;
}
- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

@end
