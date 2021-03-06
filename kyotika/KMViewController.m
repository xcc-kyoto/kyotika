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

@interface KMViewController ()<MKMapViewDelegate, KMLocationManagerDelegate, KMQuizeViewControllerDelegate, KMVaultViewControllerDelegate, KMLandmarkViewControllerDelegate, KMEventViewControllerDelegate> {
    MKMapView*                      _mapView;
    MKCoordinateRegion              _kyotoregion;
    KMTreasureHunterAnnotation*     _hunterAnnotation;
    KMTreasureHunterAnnotationView* _hunterAnnotationView;
    KMLocationManager*              _locationManager;
    NSArray*                        _targets;
    UIView*                         _stopTargetModeButton;          /// 目的地表示
    UIButton*                       _currentLocationButton;         /// 現在地を探す
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
    //  self.viewをステータスバーの下にもぐり込ませる
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //  京都駅をデフォルト位置にする　latitude：35.0212466 longitude：135.7555968
    CLLocationCoordinate2D center = kyotoCenter;
    _kyotoregion = MKCoordinateRegionMakeWithDistance(center,
                                                      15000.0,  //  15km
                                                      15000.0);
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
    
    //  サーチボタン準備
    UIImage* roundrect = [[UIImage imageNamed:@"roundrect"] stretchableImageWithLeftCapWidth:6 topCapHeight:14];
    CGRect frame = CGRectMake(10, self.view.bounds.size.height - 60, 30, 30);
    _currentLocationButton = [self addButton:frame backgroundImage:roundrect image:[UIImage imageNamed:@"arrow"] action:@selector(startTracking)];
    _currentLocationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //  ハンター追加
    _hunterAnnotation = [[KMTreasureHunterAnnotation alloc] init];
    _hunterAnnotation.coordinate = kyotoCenter;
    [_mapView addAnnotation:_hunterAnnotation];

    _mapView.region = _kyotoregion;  //  アニメーション抜き
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_prologue) {
        [self showValuts];
    }
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
    [UIView animateWithDuration:0.3 animations:^{
        _currentLocationButton.alpha = 0;
    }];
    if ([CLLocationManager locationServicesEnabled]) {
        [_locationManager start];
    } else {
        [self showLocationMessage:NSLocalizedString(@"locationServices not enable", @"locationServices not enable")];
    }
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"started"] == NO) {
        //  最初の起動ではGPSチェックで移動させない。必ずJR京都駅に配置。
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"started"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
//  アプリのリジューム時にGPSサーチをおこなうなら1にする
#if AUTO_START_MAP_SEARCH
        [self startTracking];
#endif
    }
}

/*
 バックグラウンドに入った（ホームボタン押し下げ時、なぜか何回か呼ばれる）
 */
- (void)applicationDidEnterBackground
{
    [_locationManager stop];
    [_vaults save];
}


/*
 ハンターが持つ情報をみせる（ランドマーク、キーワード、アバウト）
 */
- (void)showValuts
{
    KMVaultViewController* c = [[KMVaultViewController alloc] init];
    c.vaultsDelegate = self;
    c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    c.keywords = [_vaults keywords];
    c.landmarks= [_vaults landmarks];
    c.totalLandmarkCount = _vaults.totalLandmarkCount;
    c.selectedIndex = _prologue ? 2 : 0;    
    [self presentViewController:c animated:YES completion:nil];
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
    if (self.modalViewController != nil) {
        return;
    }
    KMTreasureAnnotation* annotation = [notification.userInfo objectForKey:@"annotation"];

    if (annotation.passed) {
        //  キーワードを見る
        KMLandmarkViewController* viewController = [[KMLandmarkViewController alloc] init];
        viewController.title = annotation.title;
        viewController.keywords = annotation.keywords;
        viewController.urlString = annotation.landmark.url;
        viewController.landmarkDelegate = self;
        viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
        return;
    }
    
    KMQuizeViewController* viewController = [[KMQuizeViewController alloc] initWithStyle:UITableViewStyleGrouped];
    viewController.question = annotation.question;
    viewController.answers = annotation.answers;
    viewController.userRef = annotation;
    viewController.quizeDelegate = self;
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
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

#pragma mark - KMLocationManager delegate
// WiFi、GPS位置情報デリゲート


/*
    領域外アラート　自動消滅
 */
- (void)showLocationMessage:(NSString*)message
{
    CGRect frame = self.view.bounds;
    frame.size.height /= 5;
    frame.origin.y += frame.size.height;
    UILabel* alert = [[UILabel alloc] initWithFrame:CGRectInset(frame, 20, 0)];
    alert.text = message;
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
        [UIView animateWithDuration:0.3 animations:^{
            _currentLocationButton.alpha = 1;
        }];
    }];
}

/*
 位置が更新された
 新しい位置を中心に2kmx2km園内を表示、レーダーアニメーション開始
 */
- (void)locationManagerUpdate:(KMLocationManager*)locationManager
{
    CLLocationCoordinate2D newLocation = locationManager.curtLocation.coordinate;   //  stopしても値が残っているのが保証されているかわからないので
    [_locationManager stop];
    if (coordinateInRegion(newLocation, _kyotoregion) == NO) {
        [self showLocationMessage:NSLocalizedString(@"Out of bounds Kyoto Region", @"Out of bounds Kyoto Region")];
        return;
    }
    MKCoordinateRegion rgn = MKCoordinateRegionMakeWithDistance(locationManager.curtLocation.coordinate,
                                                      1000.0,  //  1km
                                                      1000.0);
    [_mapView setRegion:rgn animated:YES];

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_hunterAnnotationView searchAnimationOnView:self.view target:self action:@selector(searchFinished)];
    });
}

- (void)locationManager:(KMLocationManager *)locationManager didFailWithError:(NSError *)error
{
    [self showLocationMessage:NSLocalizedString(@"locationServices not enable", @"locationServices not enable")];
}
/*
    レーダーアニメーション終了
    2kmx2km園内のランドマークを発見済みにする
 */
- (void)searchFinished
{    
    [UIView animateWithDuration:0.3 animations:^{
        _currentLocationButton.alpha = 1;
    }];
    [_vaults search:_mapView.region.center radiusMeter:1000];
    [self mapView:_mapView regionDidChangeAnimated:NO];
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
        [_hunterAnnotationView setStandbyNero:_vaults.progress.isTogetherWithNero];
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
    [_hunterAnnotationView setSearcherHidden:[KMVaults gropuIndexForRegion:_mapView.region] >= 0];
    _hunterAnnotation.coordinate = _mapView.region.center;
    
    KMTreasureAnnotation* hitAnnotation = nil;
    NSMutableSet* treasureAnnotations = [[_vaults treasureAnnotationsInRegion:_mapView.region
                                                                       hunter: _hunterAnnotation.coordinate
                                                        hitTreasureAnnotation:&hitAnnotation] mutableCopy];
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

    if (hitAnnotation) {
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [hitAnnotation notificationHitIfNeed];
        });
    }
}

#pragma mark - KMVaultViewController delegate
//  お宝表示デリゲート

/*
    スポットモードの切り替え
        ON：指定されたランドマークの強調表示
 */
- (void)setTargetMode:(NSString*)title
{
    if (title) {
        //  ターゲットモード解除用のビューを画面上部に貼付ける。
        CGRect frame = self.view.bounds;
        frame.size.height = 44;
        CGFloat topBarOffset = 0;   //  iOS 7のステータスバー対応
        if ([self respondsToSelector:@selector(topLayoutGuide)]) {
            topBarOffset = self.topLayoutGuide.length;
            frame.size.height += topBarOffset;
        }
        _stopTargetModeButton = [[UIView alloc] initWithFrame:frame];
        _stopTargetModeButton.backgroundColor = [UIColor colorWithHue:0.6 saturation:1 brightness:0.2 alpha:0.8];
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopTargetMode)];
        [_stopTargetModeButton addGestureRecognizer:tapGestureRecognizer];
        [self.view addSubview:_stopTargetModeButton];

        frame = _stopTargetModeButton.bounds;
        frame.origin.y += 4;
        frame.origin.y += topBarOffset;
        frame.size.height = 20;
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:frame];
        [_stopTargetModeButton addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Spot mode(%@)", @"Spot mode(%@)"), title];
        
                frame.origin.y += frame.size.height;
        frame.size.height = 16;
        UILabel* subtitleLabel = [[UILabel alloc] initWithFrame:frame];
        [_stopTargetModeButton addSubview:subtitleLabel];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.text = NSLocalizedString(@"Return normal mode", @@"Return normal mode");
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
    [self setTargetMode:nil];
}

/*
 プロローグとして表示していたならズームインする。
 */
- (void)zoomInIfPrologue
{
    if (_prologue == NO)
        return;
    _prologue = NO;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        MKCoordinateRegion rgn = MKCoordinateRegionMakeWithDistance(_mapView.region.center,
                                                                    200.0,  //  200m
                                                                    200.0);
        
        [_mapView setRegion:rgn animated:YES];
    });
}

- (BOOL)isSameRgn:(MKCoordinateRegion)region
{
    MKCoordinateRegion krgn = [_mapView regionThatFits:region];
    MKCoordinateRegion mrgn = _mapView.region;
    
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
 すべてのターゲットを見せるため、必要なズームアウトをおこなう。
 */
- (void)showAllTarget
{
    //  必要な領域を決める
    MKCoordinateRegion curtRegion = _mapView.region;
    //  地図中心が京都チカチカのエリア外なら修正
    KMRegion hr = KMRegionFromMKCoordinateRegion(_kyotoregion);    //  _kyotoregionで指定された範囲を決定
    if (MKCoordinateInKMRegion(curtRegion.center, hr) == NO) {
        curtRegion = _kyotoregion;
    }
    //  現在地を中心に、ターゲットに合わせて範囲を広げる。
    static const CLLocationDegrees startDelta = 0.001;    //  中心から最大この範囲から開始。ターゲットに合わせて広げていく
    if (curtRegion.span.latitudeDelta > startDelta) curtRegion.span.latitudeDelta = startDelta;
    if (curtRegion.span.longitudeDelta > startDelta) curtRegion.span.longitudeDelta = startDelta;
    
    CLLocationCoordinate2D coordinate = curtRegion.center;
    CLLocationDegrees minlatitude = coordinate.latitude - curtRegion.span.latitudeDelta / 2;
    CLLocationDegrees maxlatitude = minlatitude + curtRegion.span.latitudeDelta / 2;
    CLLocationDegrees minlongitude = coordinate.longitude - curtRegion.span.longitudeDelta / 2;
    CLLocationDegrees maxlongitude = minlongitude + curtRegion.span.longitudeDelta / 2;;
    for (KMTreasureAnnotation* a in _targets) {
        coordinate = a.coordinate;
        if (minlatitude > coordinate.latitude)
            minlatitude = coordinate.latitude;
        else if (maxlatitude < coordinate.latitude)
            maxlatitude = coordinate.latitude;
        if (minlongitude > coordinate.longitude)
            minlongitude = coordinate.longitude;
        else if (maxlongitude < coordinate.longitude)
            maxlongitude = coordinate.longitude;
    }
    MKCoordinateRegion tmpRgn;  //  設定する領域
    tmpRgn.span.longitudeDelta = maxlongitude - minlongitude;
    tmpRgn.span.latitudeDelta = maxlatitude - minlatitude;
    tmpRgn.center.longitude = minlongitude + (tmpRgn.span.longitudeDelta / 2);
    tmpRgn.center.latitude = minlatitude + (tmpRgn.span.latitudeDelta / 2);
    static const float ExpandCoefficient = 1.3;         //  領域がギリギリだとマークが切れてしまうので、4インチも考慮して大きめにする
    tmpRgn.span.longitudeDelta *= ExpandCoefficient;
    tmpRgn.span.latitudeDelta *= ExpandCoefficient;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([self isSameRgn:tmpRgn]) {
            [self mapView:_mapView regionDidChangeAnimated:NO];
        } else {
            [_mapView setRegion:tmpRgn animated:YES];
        }
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
    _prologue = NO;
    [self setTargetMode:nil];
    NSArray* landmarks = [_vaults landmarksForKey:object];
    for (KMTreasureAnnotation* a in landmarks) {
        a.target = YES;
        KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
        [v startAnimation];
    }
    _targets = [NSArray arrayWithArray:landmarks];
    Tag *t = object;
    [self setTargetMode:t.name];
    [self dismissModalViewControllerAnimated:YES];
    [self showAllTarget];
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
    _prologue = NO;
    [self setTargetMode:nil];
    KMTreasureAnnotation* a = (KMTreasureAnnotation*)object;
    a.target = YES;
    _targets = [NSArray arrayWithObject:a];
    [self setTargetMode:a.passed ? a.title : @"？"];
   KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
    [v startAnimation];
    [self dismissModalViewControllerAnimated:YES];
    [self showAllTarget];
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
    float complete = _vaults.progress.complete;
    float newcomplete = complete;
    __weak KMTreasureAnnotation* annotation = (KMTreasureAnnotation*)controller.userRef;
    annotation.lastAtackDate = [NSDate date];
    KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:annotation];
    if (controller.selectedIndex == annotation.correctAnswerIndex) {
        [_vaults setPassedAnnotation :annotation];
        newcomplete = _vaults.progress.complete;
    } else {
        double delayInSeconds = KMTreasureAnnotationPenaltyDuration + 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:annotation];
            [v startAnimation];
        });
    }
    [v startAnimation];
    [self mapView:_mapView regionDidChangeAnimated:NO];
    [self dismissModalViewControllerAnimated:YES];
    if (newcomplete != complete) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            KMEventViewController* c = [[KMEventViewController alloc] init];
            c.delegate = self;
            c.progress = _vaults.progress;
            c.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:c animated:YES completion:nil];
        });
    }
}

- (void)eventViewControllerDone:(KMEventViewController*)vc
{
    if (vc.progress.canStandbyNero)
        [_hunterAnnotationView setStandbyNero:YES];
    [self dismissModalViewControllerAnimated:YES];
}
@end

