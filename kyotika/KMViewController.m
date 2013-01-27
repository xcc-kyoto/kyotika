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
#import "KMTreasureHunterAnnotationView.h"
#import "KMTreasureAnnotationView.h"
#import "KMVaults.h"
#import "KMQuizeViewController.h"
#import "KMLandmarkViewController.h"
#import "KMVaultViewController.h"
#import "KMLandmarkListController.h"

@interface KMViewController ()<MKMapViewDelegate, KMQuizeViewControllerDelegate, KMVaultViewControllerDelegate, KMLandmarkViewControllerDelegate> {
    MKMapView* _mapView;
    KMLever* _virtualLeaver;
    MKCoordinateRegion _kyotoregion;
    KMTreasureHunterAnnotation* _hunterAnnotation;
    KMTreasureHunterAnnotationView* _hunterAnnotationView;
    NSTimer*    _timer;
    KMVaults*    _vaults;
    BOOL        _firstLoad;
}
@end

@implementation KMViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tap:) name:@"KMTreasureAnnotationViewTapNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(huntertap:) name:@"KMTreasureHunterAnnotationViewTapNotification" object:nil];
    
    for (id < MKAnnotation > a  in _mapView.annotations) {
        if ([a isKindOfClass:[KMTreasureAnnotation class]]) {
            KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
            [v startAnimation];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)huntertap:(NSNotification*)notification
{
    KMVaultViewController* c = [[KMVaultViewController alloc] init];
    c.keywords = [_vaults keywords];
    c.landmarks= [_vaults landmarks];
    c.vaultsDelegate = self;
    c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:c animated:YES];
}
- (void)tap:(NSNotification*)notification
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _firstLoad = YES;
    
    _vaults = [[KMVaults alloc]init];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    CGRect frame = CGRectMake(10, self.view.bounds.size.height - 50, 100, 20);
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
    
    float radius = 150;
    frame = CGRectMake(self.view.bounds.size.width - radius - 20,
                       self.view.bounds.size.height - radius - 20, radius, radius);
    _virtualLeaver = [[KMLever alloc] initWithFrame:frame];
    _virtualLeaver.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _virtualLeaver.hidden = YES;
    [_virtualLeaver addTarget:self action:@selector(move) forControlEvents:UIControlEventTouchDragInside];
    [self.view addSubview:_virtualLeaver];
    
    //  京都　latitude：35.0212466 longitude：135.7555968
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(35.0212466, 135.7555968);
    _kyotoregion = MKCoordinateRegionMakeWithDistance(center,
                                                                        10000.0,  //  10km
                                                                        10000.0);
    _mapView.region = _kyotoregion;  //  アニメーション抜き
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow  animated:YES];
    _mapView.showsUserLocation = YES;   //  ユーザー位置表示
}

- (void)move
{
    CGPoint vector = _virtualLeaver.vector;
    CGPoint pt = [_mapView convertCoordinate:_hunterAnnotation.coordinate toPointToView:_mapView];
    
    float dx = 15 * vector.x;
    float dy = 15 * vector.y;
    CGPoint point = CGPointMake(pt.x + dx, pt.y + dy);
    CLLocationCoordinate2D centerCoordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    _hunterAnnotation.coordinate = centerCoordinate;
    [_mapView setCenterCoordinate:centerCoordinate animated:NO];
    
    KMTreasureHunterAnnotationView* view = (KMTreasureHunterAnnotationView*)[_mapView viewForAnnotation:_hunterAnnotation];
    [view direction:vector];

}

- (void)virtualSwitch:(UISwitch*)virtualSwitch
{
    if (virtualSwitch.on) {
        [_mapView setUserTrackingMode:MKUserTrackingModeNone  animated:YES];
        _mapView.showsUserLocation = NO;   //  ユーザー位置表示
        _hunterAnnotation = [[KMTreasureHunterAnnotation alloc] init];
        _hunterAnnotation.coordinate = CLLocationCoordinate2DMake(35.0212466 + 0.000, 135.7555968 + 0.000);
        [_mapView addAnnotation:_hunterAnnotation];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_kyotoregion.center,
                                                          500.0,  //  500m
                                                          500.0);
        
        _virtualLeaver.transform = CGAffineTransformMakeScale(0.1, 0.1);
        _virtualLeaver.hidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
            _virtualLeaver.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         }
         completion:^(BOOL finished) {
             [UIView animateWithDuration:0.3
                              animations:^{
                                  _virtualLeaver.transform = CGAffineTransformMakeScale(0.8, 0.8);
                              }
                              completion:^(BOOL finished) {
                                                       _virtualLeaver.transform = CGAffineTransformIdentity;
                                                        [_mapView setRegion:region animated:YES];
                              }];

         }];
    } else {
        _virtualLeaver.hidden = YES;
        [_mapView removeAnnotation:_hunterAnnotation];
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow  animated:YES];
        _mapView.showsUserLocation = YES;   //  ユーザー位置表示
    }
}

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

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_firstLoad) {
        return;
    }
    if (_mapView.region.span.latitudeDelta > 0.0050)
        _hunterAnnotationView.backgroundColor = [UIColor clearColor];
    else
        _hunterAnnotationView.backgroundColor = [UIColor redColor];
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

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if (_firstLoad) {
        _firstLoad = NO;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_kyotoregion.center,
                                                                       500.0,  //  500m
                                                                       500.0);
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_mapView setRegion:region animated:YES];
            
        });
        
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _hunterAnnotation.coordinate = userLocation.coordinate;
}
@end

