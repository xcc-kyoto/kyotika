//
//  KMViewController.m
//  KyotoMap
//
//  Created by kunii on 2013/01/11.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "KMViewController.h"
#import "KMLever.h"
#import "KMTreasureHunterAnnotation.h"
#import "KMTreasureHunterAnnotationView.h"
#import "KMTreasureAnnotation.h"
#import "KMTreasureAnnotationView.h"
#import "KMVaults.h"
#import "KMQuizeViewController.h"
#import "KMLandmarkViewController.h"
#import "KMVaultViewController.h"
#import "KMLandmarkListController.h"
#import "KMLocationManager.h"

@interface KMViewController ()<MKMapViewDelegate, KMLocationManagerDelegate, KMQuizeViewControllerDelegate, KMVaultViewControllerDelegate, KMLandmarkViewControllerDelegate> {
    MKMapView* _mapView;
    KMLever* _virtualLeaver;
    MKCoordinateRegion _kyotoregion;
    KMTreasureHunterAnnotation* _hunterAnnotation;
    KMTreasureHunterAnnotationView* _hunterAnnotationView;
    NSTimer*    _timer;
    KMVaults*    _vaults;
    BOOL        _virtualMode;
    KMLocationManager*  _locationManager;
    UILabel*    _virtualModeLabel;
    UISwitch*   _virtualSwitch;
    BOOL _first;

}
@end

@implementation KMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapTreasure:) name:@"KMTreasureAnnotationViewTapNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapHunter) name:@"KMTreasureHunterAnnotationViewTapNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 ビュー作成直後
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    //  お宝
    _vaults = [[KMVaults alloc]init];
    //  位置情報　（地図側は最大縮尺だとぶれまくるので使わない）
    if (_locationManager == nil) {
        _locationManager = [[KMLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    //  地図
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    //  バーチャルモード切り替えスイッチ
    [self addVirtualSwitch];
    
    //  京都府庁をデフォルト位置にする　latitude：35.0212466 longitude：135.7555968
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(35.0212466, 135.7555968);
    _kyotoregion = MKCoordinateRegionMakeWithDistance(center,
                                                      10000.0,  //  10km
                                                      10000.0);
    _mapView.region = _kyotoregion;  //  アニメーション抜き
    //  ハンター追加
    _hunterAnnotation = [[KMTreasureHunterAnnotation alloc] init];
    _hunterAnnotation.coordinate = CLLocationCoordinate2DMake(35.0212466, 135.7555968);
    [_mapView addAnnotation:_hunterAnnotation];
}

/*
 バーチャルモード切り替えスイッチの追加
 */
- (void)addVirtualSwitch
{
    CGRect frame = CGRectMake(10, self.view.bounds.size.height - 60, 100, 20);
    UILabel* label = [[UILabel alloc]initWithFrame:frame];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @"バーチャルモード";
    [self.view addSubview:label];
    frame.origin.y += frame.size.height;
    frame.size.width = 150;
    UISwitch* virtualSwitch = [[UISwitch alloc] initWithFrame:frame];
    virtualSwitch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [virtualSwitch addTarget:self action:@selector(virtualSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:virtualSwitch];
}

/*
 ビュー表示直後
    ノーティフィケーションを見張る
        アプリフォアグラウンド復帰   CLLocationManagerが使えるか調べ、使えない場合はバーチャルモードのみの運用にする
        アプリバックグラウンド移動   CLLocationManagerを使って位置確認中なら停止する
        KMTreasureAnnotationViewTapNotification ランドマークタップ
        KMTreasureHunterAnnotationViewTapNotification   探索者タップ
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

/*
    for (id < MKAnnotation > a  in _mapView.annotations) {
        if ([a isKindOfClass:[KMTreasureAnnotation class]]) {
            KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
            [v startAnimation];
        }
    }
 */
    [self startTracking];
    if (_first) {
        _first = NO;
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            MKCoordinateRegion rgn = MKCoordinateRegionMakeWithDistance(_mapView.region.center,
                                                                        1000.0,  //  1km
                                                                        1000.0);
            
            [_mapView setRegion:rgn animated:YES];
        });
    }
}

/*
 バックグラウンドから復帰した
 */
- (void)applicationDidBecomeActive
{
    [self startTracking];
}

/*
 バックグラウンドに入った（ホームボタン押し下げ時、なぜか何回か呼ばれる）
 */
- (void)applicationDidEnterBackground
{
    if (_virtualMode == NO)
        [_locationManager stop];
}

/*
 トラッキングスタート
 */
- (void)startTracking
{
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    _virtualModeLabel.text = locationServicesEnabled?@"バーチャルモード" : @"バーチャルモードしか使えません";
    _virtualSwitch.hidden = !locationServicesEnabled;
    if ((_virtualSwitch.hidden == NO) && (_virtualMode == NO)) {
        [_locationManager start];
    }
}

/*
 ハンターが持つ情報をみせる（ランドマーク、キーワード、アバウト）
 */
- (void)showValuts:(int)tabIndex
{
    KMVaultViewController* c = [[KMVaultViewController alloc] init];
    c.selectedIndex = tabIndex;
    c.keywords = [_vaults keywords];
    c.landmarks= [_vaults landmarks];
    c.vaultsDelegate = self;
    c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:c animated:YES];
}

/*
 プロローグを見せる
 */
- (void)showProlog
{
    [self showValuts:2];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _first = YES;
    });
}

/*
 ハンターがタップされた
 */
- (void)tapHunter
{
    [self showValuts:0];
}

/*
 ランドマークがタップされた
 */
- (void)tapTreasure:(NSNotification*)notification
{
    KMTreasureAnnotation* annotation = [notification.userInfo objectForKey:@"annotation"];

    if (annotation.passed) {
        //  キーワードを見る
        KMLandmarkViewController* c = [[KMLandmarkViewController alloc] init];
        c.keywords = annotation.keywords;
        c.landmarkDelegate = self;
        c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:c animated:YES];
        return;
    }
    
    KMQuizeViewController* c = [[KMQuizeViewController alloc] initWithStyle:UITableViewStyleGrouped];
    c.question = annotation.question;
    c.answers = annotation.answers;
    c.userRef = annotation;
    c.quizeDelegate = self;
    c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:c animated:YES];
}

/*
 バーチャルモードスイッチが切り替わった
 */
- (void)virtualSwitch:(UISwitch*)virtualSwitch
{
    [self setVirtualMode:virtualSwitch.on];
}

static BOOL coordinateInRegion(CLLocationCoordinate2D centerCoordinate, MKCoordinateRegion region)
{
    float minlatitude = region.center.latitude - region.span.latitudeDelta / 2;
    float maxlatitude = region.center.latitude + region.span.latitudeDelta / 2;
    float minlongitude = region.center.longitude - region.span.longitudeDelta / 2;
    float maxlongitude = region.center.longitude + region.span.longitudeDelta / 2;
    if ((centerCoordinate.longitude > minlongitude) && (centerCoordinate.longitude < maxlongitude)
        && (centerCoordinate.latitude > minlatitude) && (centerCoordinate.latitude < maxlatitude)) {
        //  画面範囲内移動
        return YES;
    }
    return NO;
}
/*
 ハンターを移動させる
 画面外への移動の場合、一度領域を10km四方にしてから移動させ、その後元の大きさにズームインする
 元の大きさが500m以上の場合、500m四方にズームインする
 */
- (void)moveHunter:(CLLocationCoordinate2D)centerCoordinate course:(CLLocationDirection)course
{
    _hunterAnnotation.coordinate = centerCoordinate;
    [_hunterAnnotationView setCourse:course];
    [_mapView setCenterCoordinate:centerCoordinate animated:NO];

}

/*
 バーチャルレバー表示
    アニメーション付きでレバーを表示する
 */
- (void)showVirtualLeaver
{
    float radius = 100;
    CGRect frame = CGRectMake(self.view.bounds.size.width - radius - 30,
                       self.view.bounds.size.height - radius - 30, radius, radius);
    _virtualLeaver = [[KMLever alloc] initWithFrame:frame];
    _virtualLeaver.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [_virtualLeaver addTarget:self action:@selector(virtualMove) forControlEvents:UIControlEventTouchDragInside];

    CAKeyframeAnimation * popupAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform"];

    NSArray* keyAttributes = @[
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DIdentity]
                           ];

    popupAnimation.values = keyAttributes;
    NSArray* keyTimes = @[@0.0,@0.5,@0.75,@1.0];
    popupAnimation.keyTimes = keyTimes;
    popupAnimation.duration= 0.5;
    [self.view addSubview:_virtualLeaver];
    [_virtualLeaver.layer addAnimation:popupAnimation forKey:@"popup"];
}

/*
 レバー対応
 */
- (void)virtualMove
{
    CGPoint vector = _virtualLeaver.vector;
    CGPoint pt = [_mapView convertCoordinate:_hunterAnnotation.coordinate toPointToView:_mapView];
    
    float dx = 15 * vector.x;
    float dy = 15 * vector.y;
    CGPoint point = CGPointMake(pt.x + dx, pt.y + dy);
    
    CLLocationDirection course = _virtualLeaver.rotation * 360.0 / (2.0 * 3.1415) - 90;
    if (course < 0) course += 270;
    [self moveHunter:[_mapView convertPoint:point toCoordinateFromView:_mapView] course:course];
}

/*
 バーチャルモードの設定
    バーチャルモード：レバー表示、位置トラッキング停止
    リアルモード：レバー非表示、位置トラッキング開始
 */
- (void)setVirtualMode:(BOOL)virtualMode
{
    if (_virtualMode == virtualMode) {
        return;
    }
    _virtualMode = virtualMode;
    if (_virtualMode) {
        [self showVirtualLeaver];
        [_locationManager stop];
        if (coordinateInRegion(_hunterAnnotation.coordinate, _kyotoregion)) {
            return;
        }
        [self moveHunter:_kyotoregion.center course:0];
    } else {
        [_virtualLeaver removeFromSuperview];
        _virtualLeaver = nil;
        [self startTracking];
    }
}

#pragma mark - KMLocationManager delegate

/*
 位置が更新された
 */
- (void)locationManagerUpdate:(KMLocationManager*)locationManager
{
    [self moveHunter:locationManager.curtLocation.coordinate course:locationManager.curtLocation.course];
}

#pragma mark - MKMapView delegate
/*
 注釈ビューを返す
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // これがユーザの位置の場合は、単にnilを返す
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        if (_virtualLeaver.hidden == NO)
            return nil;
        KMTreasureHunterAnnotationView* pinView = (KMTreasureHunterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Hunter"];
        if (pinView == nil) {
            pinView = [[KMTreasureHunterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Hunter"];
        }
        pinView.hunterAnnotation = _hunterAnnotation;
        pinView.canShowCallout = NO;
        [pinView startAnimation];
        _hunterAnnotationView = pinView;
        return pinView;
    }
    if ([annotation isKindOfClass:[KMTreasureHunterAnnotation class]]) {
        KMTreasureHunterAnnotationView* pinView = (KMTreasureHunterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Hunter"];
        if (pinView == nil) {
            pinView = [[KMTreasureHunterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Hunter"];
        }
        pinView.hunterAnnotation = _hunterAnnotation;
        pinView.canShowCallout = NO;
        [pinView startAnimation];
        _hunterAnnotationView = pinView;
        return pinView;
    }
    KMTreasureAnnotationView* pinView = (KMTreasureAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (pinView == nil) {
        pinView = [[KMTreasureAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    pinView.canShowCallout = YES;
    [pinView startAnimation];
    return pinView;
}

/*
 表示領域が変更された
 */
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [_hunterAnnotationView setRegion:_mapView.region];
    NSMutableSet* treasureAnnotations = [[_vaults treasureAnnotationsInRegion:_mapView.region] mutableCopy];
    NSArray* array = [_mapView annotations];
    NSMutableSet* set = [NSMutableSet setWithArray:array];
    [set minusSet:treasureAnnotations];
    if (_hunterAnnotation)
        [set removeObject:_hunterAnnotation];
    if ([set count] > 0)
        [_mapView removeAnnotations:set.allObjects];
    [treasureAnnotations minusSet:[NSSet setWithArray:array]];
    if ([treasureAnnotations count] > 0)
        [_mapView addAnnotations:treasureAnnotations.allObjects];
    
    for (KMTreasureAnnotation* a  in _mapView.annotations) {
        if ([a isKindOfClass:[KMTreasureAnnotation class]]) {
            KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
            [v setNeedsDisplay];
            [v startAnimation];
        }
    }

    int64_t delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (KMTreasureAnnotation* a  in _mapView.annotations) {
            if ([a isKindOfClass:[KMTreasureAnnotation class]]) {
                KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
                if ([v enter:_hunterAnnotation.coordinate]) {
                    [v enterNotification];
                    break;
                }
            }
        }

    });
}

#pragma mark - KMVaultViewController delegate

-(void)vaultViewControllerDone:(KMVaultViewController*)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)landmarkViewControllerDone:(KMLandmarkViewController*)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)keywordListControllerShowLocation:(KMKeywordListController*)controller object:(id)object
{
    NSArray* landmarks = [_vaults landmarksForKey:object];
    for (KMTreasureAnnotation* a in landmarks) {
        printf("show landmark %s\n", [a.title UTF8String]) ;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString*)keywordListControllerKeyword:(KMKeywordListController*)ViewController fromObject:(id)object
{
    return  [NSString stringWithFormat:@"Key %d", [object intValue]];
}

- (NSArray*)keywordListControllerLandmarks:(KMKeywordListController*)ViewController fromObject:(id)object
{
    return [_vaults landmarksForKey:object];
}

- (void)landmarkListControllerShowLocation:(KMLandmarkListController*)controller object:(id)object
{
    KMTreasureAnnotation* a = (KMTreasureAnnotation*)object;
    printf("show landmark %s\n", [a.title UTF8String]) ;
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString*)landmarkListControllerLandmark:(KMLandmarkListController*)controller fromObject:(id)object
{
    KMTreasureAnnotation* a = (KMTreasureAnnotation*)object;
    return a.title;
}

#pragma mark - KMQuizeViewController delegate

- (void)quizeViewControllerAnswer:(KMQuizeViewController*)controller
{
    KMTreasureAnnotation* annotation = (KMTreasureAnnotation*)controller.userRef;
    if (controller.selectedIndex == annotation.correctAnswerIndex) {
        annotation.passed = YES;
        KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:annotation];
        [v setNeedsDisplay];
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end

