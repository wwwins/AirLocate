//
//  ALDot.m
//  AirLocate
//
//  Created by wwwins on 2016/3/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "ALDot.h"
#import <ChameleonFramework/Chameleon.h>

@implementation ALDot

-(id)init {
  self = [super init];
  if (self) {
    self.fillColor = [UIColor colorWithRandomFlatColorExcludingColorsInArray:@[FlatBlack, FlatBlackDark, FlatGray, FlatGrayDark, FlatRedDark, FlatRed, FlatGreen]];
    self.lineColor = [UIColor flatRedColorDark];
    self.lineWidth = 0.0;
    self.dotWidth = 20;
    // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/CoreAnimationBasics/CoreAnimationBasics.html
    // 中心點在中間(預設值)
    self.anchorPoint = CGPointMake(0.5, 0.5);
    // 中心點在左上
    //self.anchorPoint = CGPointMake(0, 0);
    // 設定 bounds 不然不會執行 drawInContext
    self.bounds = CGRectMake(0, 0, self.dotWidth, self.dotWidth);
    //self.bounds = CGRectMake(0, 0, 100, 100);

    // 設定 setNeedsDisplay 不然不會執行 drawInContext
    [self setNeedsDisplay];
  }
  return self;
}

-(void)drawInContext:(CGContextRef)ctx {

  UIGraphicsPushContext(ctx);

  CGContextSetFillColorWithColor(ctx,[self.fillColor CGColor]);
  CGContextSetLineWidth(ctx, self.lineWidth);
  CGContextSetStrokeColorWithColor(ctx, [self.lineColor CGColor]);
  // 加入矩形
  //CGContextAddRect(ctx, CGRectMake(2, 2, 20, 50));
  // 加入圓形
  CGContextAddArc(ctx, self.dotWidth*0.5, self.dotWidth*0.5, self.dotWidth*0.5, 0, M_PI*2, 1);
  // 只填色不畫線
  CGContextDrawPath(ctx, kCGPathEOFill);

  UIGraphicsPopContext();

}

@end
