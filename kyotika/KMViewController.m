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
#import "KMAreaAnnotation.h"
#import "KMAreaAnnotationView.h"
#import "KMVaults.h"
#import "KMQuizeViewController.h"
#import "KMLandmarkViewController.h"
#import "KMVaultViewController.h"
#import "KMLandmarkListController.h"
#import "KMLocationManager.h"
#import "KMEventViewController.h"
#import "Landmark.h"
#import "Tag.h"

static CLLocationCoordinate2D kyotoCenter = {34.985, 135.758};  //  JR京都駅をデフォルト位置にする　latitude：34.985 longitude：135.758

@interface KMViewController ()<MKMapViewDelegate, KMLocationManagerDelegate, KMQuizeViewControllerDelegate, KMVaultViewControllerDelegate, KMLandmarkViewControllerDelegate> {
    MKMapView* _mapView;
    KMLever* _virtualLeaver;
    MKCoordinateRegion _kyotoregion;
    KMTreasureHunterAnnotation* _hunterAnnotation;
    KMTreasureHunterAnnotationView* _hunterAnnotationView;
    NSTimer*    _timer;
    BOOL        _virtualMode;
    KMLocationManager*  _locationManager;
    NSArray* _targets;
    UIView*   _stopTargetModeButton;
    UIButton*   _currentLocationButton;         /// 現在地を探す
    UIButton*   _returnLocationButton;          /// パトラッシュの位置に戻る
    BOOL        _prologue;                      /// 一度だけYESになる
}
@end

@implementation KMViewController

/*
 ノーティフィケーションをここで登録する
    アプリサスペンド
        リジューム
    KMTreasureAnnotationViewのタップ
    KMTreasureHunterAnnotationViewのタップ
 アプリフォアグラウンド復帰   CLLocationManagerが使えるか調べ、使えない場合はバーチャルモードのみの運用にする
 アプリバックグラウンド移動   CLLocationManagerを使って位置確認中なら停止する
 KMTreasureAnnotationHitNotification ランドマークヒット（タップ）
 KMTreasureHunterAnnotationViewTapNotification   探索者タップ
 */
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hitTreasure:) name:@"KMTreasureAnnotationHitNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapHunter) name:@"KMTreasureHunterAnnotationViewTapNotification" object:nil];

    }
    return self;
}

/*
 ノーティフィケーション解除
 */
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
    //  京都駅をデフォルト位置にする　latitude：35.0212466 longitude：135.7555968
    CLLocationCoordinate2D center = kyotoCenter;
    _kyotoregion = MKCoordinateRegionMakeWithDistance(center,
                                                      12000.0,  //  15km
                                                      12000.0);
    [_vaults makeArea:_kyotoregion];
    //  位置情報　（地図側は最大縮尺だとぶれまくるので使わない）
    if (_locationManager == nil) {
        _locationManager = [[KMLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    //  地図
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    //  バーチャルモード切り替えスイッチ
    [self addVirtualSwitch];
    
    //  ハンター追加
    _hunterAnnotation = [[KMTreasureHunterAnnotation alloc] init];
    _hunterAnnotation.coordinate = kyotoCenter;
    [_mapView addAnnotation:_hunterAnnotation];

    _mapView.region = _kyotoregion;  //  アニメーション抜き
}

/*
 バーチャルモード切り替えスイッチの追加
 */
- (void)addVirtualSwitch
{
    UIImage* roundrect = [[UIImage imageNamed:@"roundrect"] stretchableImageWithLeftCapWidth:6 topCapHeight:14];
    CGRect frame = CGRectMake(10, self.view.bounds.size.height - 60, 30, 30);
    _currentLocationButton = [self addButton:frame backgroundImage:roundrect image:[UIImage imageNamed:@"arrow"] action:@selector(startTracking)];
    
    frame = CGRectOffset(frame, frame.size.width + 10, 0);
    _returnLocationButton = [self addButton:frame backgroundImage:roundrect image:[UIImage imageNamed:@"hunter"] action:@selector(returnLocation)];
    _returnLocationButton.alpha = 0;

    //  レバー
    float radius = 150;
    frame = CGRectMake(self.view.bounds.size.width - radius - 10,
                              self.view.bounds.size.height - radius - 10, radius, radius);
    _virtualLeaver = [[KMLever alloc] initWithFrame:frame];
    _virtualLeaver.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [_virtualLeaver addTarget:self action:@selector(virtualMove) forControlEvents:UIControlEventTouchDragInside];
    [self.view addSubview:_virtualLeaver];
    
    _virtualLeaver.hidden = YES;
    _returnLocationButton.hidden = YES;
}

/*
 操作ボタンの追加
 */
- (UIButton*)addButton:(CGRect)frame backgroundImage:(UIImage*)backgroundImage image:(UIImage*)image action:(SEL)action
{
    UIButton* bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setImage:image forState:UIControlStateNormal];
    [bt setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [bt addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    bt.frame = frame;
    [self.view addSubview:bt];
    return bt;
}


/*
 トラッキングスタート
 */
- (void)startTracking
{
    if ([CLLocationManager locationServicesEnabled]) {
        [UIView animateWithDuration:0.3 animations:^{
            _currentLocationButton.alpha = 0;
            _virtualLeaver.alpha = 0;
        }];
        [_locationManager start];
    } else {
        _currentLocationButton.hidden = YES;
        [self showVirtualLeaver];
    }
}

/*
    地図をパトラッシュの位置に戻す
 */
- (void)returnLocation
{
    [UIView animateWithDuration:0.3 animations:^{
        _returnLocationButton.alpha = 0;
    }];
    [_mapView setCenterCoordinate:_hunterAnnotation.coordinate animated:YES];
}

/*
 バックグラウンドから復帰した
 */
- (void)applicationDidBecomeActive
{
    for (id a in _mapView.annotations) {
        UIView* view = [_mapView viewForAnnotation:a];
        if ([a isKindOfClass:[KMAnnotationView class]]) {
            KMAnnotationView* annotationView = (KMAnnotationView*)view;
            [annotationView restoreAnimation];
        }
    }
    [self startTracking];
}

/*
 バックグラウンドに入った（ホームボタン押し下げ時、なぜか何回か呼ばれる）
 */
- (void)applicationDidEnterBackground
{
    if (_virtualMode == NO)
        [_locationManager stop];
    [_vaults save];
}


/*
 ハンターが持つ情報をみせる（ランドマーク、キーワード、アバウト）
 */
- (void)showValuts
{
    KMVaultViewController* c = [[KMVaultViewController alloc] init];
    c.keywords = [_vaults keywords];
    c.landmarks= [_vaults landmarks];
    c.totalLandmarkCount = _vaults.totalLandmarkCount;
    c.selectedIndex = _prologue ? 2 : 0;

    c.vaultsDelegate = self;
    c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:c animated:YES];
}

/*
 プロローグを見せる
 */
- (void)showProlog
{
    _prologue = YES;
    [self showValuts];
}

/*
 ハンターがタップされた
 */
- (void)tapHunter
{
    [self showValuts];
}

/*
 ランドマークがタップされた
 */
- (void)hitTreasure:(NSNotification*)notification
{
    KMTreasureAnnotation* annotation = [notification.userInfo objectForKey:@"annotation"];

    if (annotation.passed) {
        //  キーワードを見る
        KMLandmarkViewController* c = [[KMLandmarkViewController alloc] init];
        c.title = annotation.title;
        c.keywords = annotation.keywords;
        c.urlString = annotation.landmark.url;
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


static BOOL coordinateInRegion(CLLocationCoordinate2D a, MKCoordinateRegion region)
{
    CLLocationDegrees delta = region.span.latitudeDelta / 2.0;
    if (a.latitude < (region.center.latitude - delta)) return NO;
    if (a.latitude >= (region.center.latitude + delta)) return NO;
    delta = region.span.longitudeDelta / 2.0;
    if (a.longitude < (region.center.longitude - delta)) return NO;
    if (a.longitude >= (region.center.longitude + delta)) return NO;
    return YES;
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
    _virtualLeaver.alpha = 1;
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
    [_virtualLeaver.layer addAnimation:popupAnimation forKey:@"popup"];
}

/*
 レバー対応
 */
- (void)virtualMove
{
    CGPoint vector = _virtualLeaver.vector;
    CGPoint pt = [_mapView convertCoordinate:_mapView.region.center toPointToView:_mapView];
    
    float dx = 8 * vector.x;
    float dy = 8 * vector.y;
    CGPoint point = CGPointMake(pt.x + dx, pt.y + dy);
    
    CLLocationDirection course = _virtualLeaver.rotation * 360.0 / (2.0 * 3.1415) - 90;
    if (course < 0) course += 270;
    [self moveHunter:[_mapView convertPoint:point toCoordinateFromView:_mapView] course:course];
    
    if (_returnLocationButton.alpha != 0) {
        [UIView animateWithDuration:0.3 animations:^{
            _returnLocationButton.alpha = 0;
        }];
    }
}

#pragma mark - KMLocationManager delegate
// WiFi、GPS位置情報デリゲート


/*
    領域外アラート　自動消滅
 */
- (void)showOutOfBoundsAlert
{
    CGRect frame = self.view.bounds;
    frame.size.height /= 5;
    frame.origin.y += frame.size.height;
    UILabel* alert = [[UILabel alloc] initWithFrame:CGRectInset(frame, 20, 0)];
    alert.text = @"現在、京都チカチカの範囲外です。";
    alert.numberOfLines = 2;
    alert.textAlignment = NSTextAlignmentCenter;
    alert.textColor = [UIColor whiteColor];
    alert.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.5 brightness:0.3 alpha:0.5];
    alert.layer.cornerRadius = 8;
    [self.view addSubview:alert];
    [UIView animateWithDuration:1 delay:2 options:0 animations:^{
        alert.alpha = 0;
    } completion:^(BOOL finished) {
        [alert removeFromSuperview];
    }];
}

- (void)searchAnimation
{
    UIImage* image = [UIImage imageNamed:@"searcher"];
    UIImageView* v = [[UIImageView alloc] initWithImage:image];
    v.frame = self.view.frame;
    v.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:v];
    [UIView animateWithDuration:1
                     animations:^{
                         v.transform = CGAffineTransformMakeRotation(3.14);
                     } completion:^(BOOL finished) {
                         [v removeFromSuperview];
                     }
     ];
}
/*
 位置が更新された
 */
- (void)locationManagerUpdate:(KMLocationManager*)locationManager
{
    CLLocationCoordinate2D newLocation = locationManager.curtLocation.coordinate;   //  stopしても値が残っているのが保証されているかわからないので
    [_locationManager stop];
    [UIView animateWithDuration:0.3 animations:^{
        _currentLocationButton.alpha = 1;
    }];
    [self showVirtualLeaver];
    if (coordinateInRegion(newLocation, _kyotoregion) == NO) {
        [self showOutOfBoundsAlert];
        return;
    }

    [_vaults search:locationManager.curtLocation.coordinate radiusMeter:1000];
    MKCoordinateRegion rgn = MKCoordinateRegionMakeWithDistance(locationManager.curtLocation.coordinate,
                                                      1000.0,  //  1km
                                                      1000.0);
    [_mapView setRegion:rgn animated:YES];

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self searchAnimation];
    });
    
}

#pragma mark - MKMapView delegate
/*
    MKMapViewデリゲート
 */
/*
 注釈ビューを返す
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // ユーザの位置の場合は、単にnilを返す。ただし、今回はユーザの位置は使わない
        return nil;
    }
    if ([annotation isKindOfClass:[KMTreasureHunterAnnotation class]]) {
        //  ハンタービュー
        KMTreasureHunterAnnotationView* pinView = (KMTreasureHunterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Hunter"];
        if (pinView == nil) {
            pinView = [[KMTreasureHunterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Hunter"];
        }
        pinView.annotation = annotation;
        pinView.hunterAnnotation = _hunterAnnotation;
        pinView.canShowCallout = NO;
        [pinView startAnimation];
        _hunterAnnotationView = pinView;
        return pinView;
    }
    if ([annotation isKindOfClass:[KMAreaAnnotation class]]) {
        //  エリアビュー
        KMAreaAnnotationView* pinView = (KMAreaAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Area"];
        if (pinView == nil) {
            pinView = [[KMAreaAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Area"];
            pinView.canShowCallout = NO;
        }
        pinView.annotation = annotation;
        return pinView;
    }
    //  ランドマークビュー
    KMTreasureAnnotationView* pinView = (KMTreasureAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (pinView == nil) {
        pinView = [[KMTreasureAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        pinView.canShowCallout = NO;
    }
    pinView.annotation = annotation;
    [pinView startAnimation];
    return pinView;
}

/*
 表示領域が変更された
 */
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [_hunterAnnotationView setRegion:_mapView.region];

    if (_returnLocationButton.alpha == 0) {
        MKCoordinateRegion region = mapView.region;
        region.span.latitudeDelta *= 0.1;
        region.span.longitudeDelta *= 0.1;
        if (coordinateInRegion(_hunterAnnotation.coordinate, region) == NO) {
            [UIView animateWithDuration:0.3 animations:^{
                _returnLocationButton.alpha = 1;
            }];
        }
    }
    
    _hunterAnnotation.coordinate = _mapView.region.center;
    
    NSMutableSet* treasureAnnotations = [[_vaults treasureAnnotationsInRegion:_mapView.region hunter: _hunterAnnotation.coordinate] mutableCopy];
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
}

#pragma mark - KMVaultViewController delegate
//  お宝表示デリゲート

- (void)setTargetMode:(BOOL)targetMode
{
    if (targetMode) {
        CGRect frame = self.view.bounds;
        frame.size.height = 44;
        _stopTargetModeButton = [[UIView alloc] initWithFrame:frame];
        _stopTargetModeButton.backgroundColor = [UIColor colorWithHue:0.6 saturation:1 brightness:0.2 alpha:0.8];
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopTargetMode)];
        [_stopTargetModeButton addGestureRecognizer:tapGestureRecognizer];
        [self.view addSubview:_stopTargetModeButton];

        frame = _stopTargetModeButton.bounds;
        frame.origin.y += 4;
        frame.size.height = 20;
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:frame];
        [_stopTargetModeButton addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"スポットモード";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor whiteColor];

        frame.origin.y += frame.size.height;
        frame.size.height = 16;
        UILabel* subtitleLabel = [[UILabel alloc] initWithFrame:frame];
        [_stopTargetModeButton addSubview:subtitleLabel];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.text = @"ここをタップすると通常モードに戻ります";
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.font = [UIFont systemFontOfSize:12];
        subtitleLabel.textColor = [UIColor whiteColor];
    
    } else {
        for (KMTreasureAnnotation* a in _targets) {
            a.target = NO;
            KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
            [v startAnimation];
        }
        [_stopTargetModeButton removeFromSuperview];
        _stopTargetModeButton = nil;
    }
}

- (void)stopTargetMode
{
    [self setTargetMode:NO];    
}

/*
 プロローグとして表示していたならズームインする。
 */
- (void)zoomInIfPrologue
{
    if (_prologue == NO)
        return;
    _prologue = NO;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        MKCoordinateRegion rgn = MKCoordinateRegionMakeWithDistance(_mapView.region.center,
                                                                    200.0,  //  200m
                                                                    200.0);
        
        [_mapView setRegion:rgn animated:YES];
    });
}

- (BOOL)isKyotoRgn
{
    MKCoordinateRegion krgn = [_mapView regionThatFits:_kyotoregion];
    MKCoordinateRegion mrgn = _mapView.region;
    
    printf("%f %f %f %f\n",
           fabs(krgn.center.latitude - mrgn.center.latitude),
           fabs(krgn.center.longitude - mrgn.center.longitude),
           fabs(krgn.span.latitudeDelta - mrgn.span.latitudeDelta),
           fabs(krgn.span.longitudeDelta - mrgn.span.longitudeDelta));
    
    if (fabs(krgn.center.latitude - mrgn.center.latitude) > 0.0001)
        return NO;
    if (fabs(krgn.center.longitude - mrgn.center.longitude) > 0.0001)
        return NO;
    if (fabs(krgn.span.latitudeDelta - mrgn.span.latitudeDelta) > 0.0001)
        return NO;
    if (fabs(krgn.span.longitudeDelta - mrgn.span.longitudeDelta) > 0.0001)
        return NO;
    return YES;
}
/*
 ターゲットを見せるため、ズームアウト
 */
- (void)zoomOut
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([self isKyotoRgn]) {
            MKCoordinateRegion tmpRgn = _kyotoregion;
            tmpRgn.span.longitudeDelta *= 0.75;
            tmpRgn.span.latitudeDelta *= 0.75;
            [_mapView setRegion:tmpRgn animated:NO];
        }
        [_mapView setRegion:_kyotoregion animated:YES];
    });
}

/*
 キャンセルでの切り替わり。プロローグとして表示していたならズームインする。
 */
-(void)vaultViewControllerDone:(KMVaultViewController*)viewController
{
    [self zoomInIfPrologue];
    [self dismissModalViewControllerAnimated:YES];
}

/*
 キャンセルでの切り替わり。プロローグとして表示していたならズームインする。
 */
-(void)landmarkViewControllerDone:(KMLandmarkViewController*)viewController
{
    [self zoomInIfPrologue];
    [self dismissModalViewControllerAnimated:YES];
}

/*
 選択されたランドマークに☆を付けて表示
 */
- (void)keywordListControllerShowLocation:(KMKeywordListController*)controller object:(id)object
{
    [self setTargetMode:NO];
    NSArray* landmarks = [_vaults landmarksForKey :object];
    for (KMTreasureAnnotation* a in landmarks) {
        a.target = YES;
        KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
        [v startAnimation];
    }
    _targets = [NSArray arrayWithArray:landmarks];
    [self setTargetMode:YES];
    [self dismissModalViewControllerAnimated:YES];
    [self zoomOut];
}

/*
 指定されたキーワード名を返す
 */
- (NSString*)keywordListControllerKeyword:(KMKeywordListController*)ViewController fromObject:(id)object
{
    Tag *t = object;
    return t.name;
}

/*
 指定されたキーワードに関連するKMTreasureAnnotation群を返す
 */
- (NSArray*)keywordListControllerLandmarks:(KMKeywordListController*)ViewController fromObject:(id)object
{
    return [_vaults landmarksForKey :object];
}

/*
 選択されたランドマークに☆を付けて表示
 */
- (void)landmarkListControllerShowLocation:(KMLandmarkListController*)controller object:(id)object
{
    [self setTargetMode:NO];
    KMTreasureAnnotation* a = (KMTreasureAnnotation*)object;
    a.target = YES;
    _targets = [NSArray arrayWithObject:a];
    [self setTargetMode:YES];
   KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
    [v startAnimation];
    [self dismissModalViewControllerAnimated:YES];
    [self zoomOut];
}

/*
 選択されたランドマークの名前を返す。
 */
- (NSString*)landmarkListControllerLandmark:(KMLandmarkListController*)controller fromObject:(id)object
{
    KMTreasureAnnotation* a = (KMTreasureAnnotation*)object;
    if (a.passed)
        return a.title;
    return nil;
}

#pragma mark - KMQuizeViewController delegate
//  クイズ用デリゲート

- (void)quizeViewControllerAnswer:(KMQuizeViewController*)controller
{
    float complite = _vaults.complite;
    float newComplite = complite;
    KMTreasureAnnotation* annotation = (KMTreasureAnnotation*)controller.userRef;
    if (controller.selectedIndex == annotation.correctAnswerIndex) {
        [_vaults setPassedAnnotation :annotation];
        newComplite = _vaults.complite;
        KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:annotation];
        [v startAnimation];
        for (id<MKAnnotation> a  in _mapView.annotations) {
            if ([a isKindOfClass:[KMTreasureAnnotation class]]) {
                KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
                [v startAnimation];
            }
        }
    }
    [self mapView:_mapView regionDidChangeAnimated:NO];
    [self dismissModalViewControllerAnimated:YES];
    annotation.lastAtackDate = [NSDate date];
    if (newComplite != complite) {
        [_hunterAnnotationView startAnimation];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            KMEventViewController* c = [[KMEventViewController alloc] init];
            c.complite = newComplite;
            c.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:c animated:YES];
        });
    }
}
@end

