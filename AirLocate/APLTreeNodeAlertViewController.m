//
//  APLTreeNodeAlertViewController.m
//  AirLocate
//
//  Created by wwwins on 2016/2/18.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "APLTreeNodeAlertViewController.h"
#import "APLDefaults.h"

@interface APLTreeNodeAlertViewController ()

@property NSMutableDictionary *beacons;
@property NSMutableDictionary *rangedRegions;

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

  NSLog(@"allBeacon:%@",allBeacons);

/* 現階段用不到
  // 依四種距離分類
  for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)]) {
    NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity=%d",[range intValue]]];
    if ([proximityBeacons count]) {
      self.beacons[range] = proximityBeacons;
    }
  }
*/
  NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"minor=9 && (proximity=%d || proximity=%d)",CLProximityImmediate,CLProximityNear]];
  if ([proximityBeacons count]) {
    // green
    self.view.backgroundColor = [UIColor greenColor];
  }
  else {
    // red
    self.view.backgroundColor = [UIColor redColor];
  }
}


@end
