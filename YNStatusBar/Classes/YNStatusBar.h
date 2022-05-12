//
//  YNStatusBar.h
//  YNStatusBar
//
//  Created by Ace on 2022/4/1.
//  Copyright © 2022 YNStatusBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef UIColorFromHex

#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif

NS_ASSUME_NONNULL_BEGIN

@interface YNStatusBar : UIView
// 刷新时间间隔，如果不设置不会自动定时刷新UI
@property (nonatomic, assign) NSTimeInterval refreshTime;
- (void)updateUI;
@end



NS_ASSUME_NONNULL_END
