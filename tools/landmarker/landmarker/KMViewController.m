//
//  KMViewController.m
//  landmarker
//
//  Created by kunii on 2013/01/24.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KMViewController.h"

@interface KMPointAnnotationView : MKAnnotationView {
    UILabel*    _label;
}
@end

@implementation KMPointAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame = CGRectMake(0,0,40, 20);
        self.bounds = frame;
        _label = [[UILabel alloc] initWithFrame:frame];
        _label.font = [UIFont boldSystemFontOfSize:12];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor redColor];
        _label.layer.borderColor = [UIColor whiteColor].CGColor;
        _label.layer.borderWidth = 2;
        _label.layer.cornerRadius = frame.size.height / 2;
        [self addSubview:_label];
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeZero;
        
        _label.text = annotation.title;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    _label.backgroundColor = selected?[UIColor blackColor]:[UIColor redColor];
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    _label.text = annotation.title;
}
@end

@interface KMViewController ()<MKMapViewDelegate> {
    MKMapView* _mapView;
}
@end

@implementation KMViewController

- (NSString*)documentPath
{
    static NSString* documentPath = nil;
    if (documentPath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [paths objectAtIndex:0];
        documentPath = [documentPath stringByAppendingPathComponent:@"landmarks.plist"];
    }
    return documentPath;
}

- (void)restore
{
    NSArray* a = [NSArray arrayWithContentsOfFile:self.documentPath];
    for (id dic in a) {
        double latitude = [[dic valueForKey:@"latitude"] doubleValue];
        double longitude = [[dic valueForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKPointAnnotation* pin = [[MKPointAnnotation alloc] init];
        pin.title = [dic valueForKey:@"title"];
        pin.coordinate = coordinate;
        [_mapView addAnnotation:pin];
    }
}

- (void)store
{
    NSMutableArray* a = [NSMutableArray arrayWithCapacity:[_mapView.annotations count]];
    for (MKPointAnnotation* pin in _mapView.annotations) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithDouble:pin.coordinate.latitude], @"latitude",
                             [NSNumber numberWithDouble:pin.coordinate.longitude], @"longitude",
                             pin.title, @"title",
                             
                             [NSArray arrayWithObjects:
                                                  [NSNumber numberWithInt:rand() % 100],
                                                  [NSNumber numberWithInt:rand() % 100],
                                                  [NSNumber numberWithInt:rand() % 100],
                                                  nil], @"keywords",
                             
                             nil];
        [a addObject:dic];
    }
    [a writeToFile:self.documentPath atomically:YES];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(store) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [super viewDidLoad];
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    [self restore];
    [self.view addSubview:_mapView];
    //  長押し見張り
    UILongPressGestureRecognizer* tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_mapView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //  京都　latitude：35.0212466 longitude：135.7555968
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(35.0212466, 135.7555968);
    MKCoordinateRegion kyotoregion = MKCoordinateRegionMakeWithDistance(center,
                                                                        10000.0,  //  10km
                                                                        10000.0);
    _mapView.region = kyotoregion;  //  アニメーション抜き
}

//  地図タップ対応
- (void)tap:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint pt = [gestureRecognizer locationInView:gestureRecognizer.view];
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:pt toCoordinateFromView:gestureRecognizer.view];
    MKPointAnnotation* pin = [[MKPointAnnotation alloc] init];
    pin.title = [NSString stringWithFormat:@"%d", [_mapView.annotations count]];
    pin.coordinate = coordinate;
    [_mapView addAnnotation:pin];
    [self store];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString* Identifier = @"PinAnnotationIdentifier";
    KMPointAnnotationView* pinView = (KMPointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
    if (pinView == nil) {
        pinView = [[KMPointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
        pinView.draggable = YES;
        return pinView;
    }
    pinView.annotation = annotation;
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (KMPointAnnotationView* a in views) {
        a.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.25 animations:^{
            a.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
        [self store];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
