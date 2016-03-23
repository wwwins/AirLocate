//
//  APLTreeNodeAlertViewController.m
//  AirLocate
//
//  Created by wwwins on 2016/2/18.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "APLTreeNodeAlertViewController.h"
#import "APLDefaults.h"
#import "ALDot.h"
#import <ChameleonFramework/Chameleon.h>

#define ENABLE_CUSTOM_DOT  YES
#define DOT_RADIUS  20

@interface APLTreeNodeAlertViewController ()

@property NSMutableDictionary *beacons;
@property NSMutableDictionary *rangedRegions;
@property NSMutableDictionary *dots;

@property CLLocationManager *locationManager;

@end

@implementation APLTreeNodeAlertViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // init beacons
  self.beacons = [[NSMutableDictionary alloc] init];
  self.rangedRegions = [[NSMutableDictionary alloc] init];

  // init location manager
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;

  // 有哪些 beacon 區域
  for (NSUUID *uuid in [APLDefaults sharedDefaults].supportedProximityUUIDs) {
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:uuid.UUIDString];
    self.rangedRegions[region] = [[NSArray alloc] init];
  }

  // 圖形化
  //[self lazyAddDot:CGPointMake(arc4random_uniform(self.view.frame.size.width-20)+10.0,arc4random_uniform(self.view.frame.size.height-200)+100.0)];
  self.dots = [[NSMutableDictionary alloc] init];

}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  // 開始監控 beacon 區域
  NSLog(@"Start Monitoring");
  for (CLBeaconRegion *region in self.rangedRegions) {
    [self.locationManager startRangingBeaconsInRegion:region];

  }

}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  // 停止監控
  NSLog(@"Stop Monitoring");
  for (CLBeaconRegion *region in self.rangedRegions) {
    [self.locationManager stopRangingBeaconsInRegion:region];

  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.

}


#pragma mark - Location manager delegate


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
  self.rangedRegions[region] = beacons;
  [self.beacons removeAllObjects];

  NSMutableArray *allBeacons = [[NSMutableArray alloc] init];
  // 取得所有 beacon
  for (NSArray *regionResult in [self.rangedRegions allValues]) {
    [allBeacons addObjectsFromArray:regionResult];
  }

//  NSLog(@"allBeacon:%@",allBeacons);
  // 圖形化
  for (CLBeacon *beacon in allBeacons) {
//    NSLog(@"beacon:%@,%f",[beacon.proximityUUID UUIDString],beacon.accuracy);
    if ([self.dots objectForKey:[beacon.proximityUUID UUIDString]]) {
      CALayer *dot = [self.dots objectForKey:[beacon.proximityUUID UUIDString]];
      CGPoint p = dot.position;
      p.y = self.view.frame.size.height - (int)self.view.frame.size.height*(beacon.accuracy/15.0) - 10;
      dot.position = p;
    }
    else {
      CALayer *dot = [self lazyAddDot:CGPointMake(arc4random_uniform(self.view.frame.size.width-20)+10.0,arc4random_uniform(self.view.frame.size.height-200)+100.0)];
      [self.dots setObject:dot forKey:[beacon.proximityUUID UUIDString]];
    }
  }

/* 現階段用不到
  // 依四種距離分類
  for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)]) {
    NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity=%d",[range intValue]]];
    if ([proximityBeacons count]) {
      self.beacons[range] = proximityBeacons;
    }
  }
*/
  NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"major=1 && (proximity=%d || proximity=%d)",CLProximityImmediate,CLProximityNear]];
  if ([proximityBeacons count]) {
    // green
    [UIView animateWithDuration:0.5 animations:^{
      self.view.backgroundColor = [UIColor flatGreenColor];
    }];
  }
  else {
    // red
    [UIView animateWithDuration:0.5 animations:^{
      self.view.backgroundColor = [UIColor flatRedColor];
    }];

  }
}

- (CALayer *)addPlaneToLayer:(CALayer*)container size:(CGSize)size position:(CGPoint)point color:(UIColor*)color
{
  CALayer *plane = [CALayer layer];
//  Define position,size and colors
  plane.backgroundColor = [color CGColor];
//  plane.opacity = 0.6;
  plane.frame = CGRectMake(0, 0, size.width, size.height);
  plane.position = point;
  plane.anchorPoint = CGPointMake(0.5, 0.5);
  plane.borderColor = [[UIColor flatRedColorDark] CGColor];
  plane.borderWidth = 1;
  plane.cornerRadius = size.width*0.5;
//  Add the layer to the container layer
  [container addSublayer:plane];

  return plane;
}

- (CALayer *)lazyAddDot:(CGPoint)point {

#if ENABLE_CUSTOM_DOT
  ALDot *myLayer = [ALDot layer];
  myLayer.position = point;
  [self.view.layer addSublayer:myLayer];
  return myLayer;
#else
  //  return [self addPlaneToLayer:self.view.layer size:CGSizeMake(16, 16) position:point color:[UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1.0]];
  return [self addPlaneToLayer:self.view.layer size:CGSizeMake(DOT_RADIUS,DOT_RADIUS) position:point color:[UIColor randomFlatColor]];
#endif

}

@end
