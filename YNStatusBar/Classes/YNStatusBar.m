//
//  YNStatusBar.m
//  YNStatusBar
//
//  Created by Ace on 2022/4/1.
//  Copyright © 2022 YNStatusBar. All rights reserved.
//
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "YNStatusBar.h"
#import "YNUtilities.h"
@interface YNStatusBarTarget : NSProxy
@property (nonatomic, weak) id delegate;
@end

@implementation YNStatusBarTarget
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    return [self.delegate methodSignatureForSelector:sel];
}
- (void)forwardInvocation:(NSInvocation *)invocation{
    [invocation invokeWithTarget:self.delegate];
}
@end


@interface YNStatusBar()
@property (nonatomic, strong) UILabel *dateLabel;//时间
@property (nonatomic, strong) UIView *batteryView;//电池
@property (nonatomic, strong) UIImageView *batteryImageView;//充电标识
@property (nonatomic, strong) CAShapeLayer *batteryLayer;//充电层
@property (nonatomic, strong) CAShapeLayer *batteryBoundLayer;//电池边框
@property (nonatomic, strong) CAShapeLayer *batteryPositiveLayer;//电池正极
@property (nonatomic, strong) UILabel *batteryLabel;//电量百分比
@property (nonatomic, strong) UILabel *networkLabel;//网络状态
@property (nonatomic, strong) YNStatusBarTarget *weakTarget;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL is24H;
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation YNStatusBar
static CGFloat SafeAreaRight = 0;
static inline CGFloat YNStatusBarHeight() {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.top > 0.0) {
            return mainWindow.safeAreaInsets.top;
        }else{
            return 20;
        }
    }else{
        return 20;
    }
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.center = CGPointMake(self.bounds.size.width*0.5, 12);
    self.batteryView.frame =CGRectMake(self.bounds.size.width-35-SafeAreaRight, 7, 22, 10);
    self.batteryLabel.frame = CGRectMake(CGRectGetMinX(self.batteryView.frame)-40-2, 4, 40, 16);
    self.networkLabel.frame = CGRectMake(CGRectGetMinX(self.batteryLabel.frame) - 40, 4, 40, 16);
}

- (void)dealloc{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setup{
    SafeAreaRight= YNStatusBarHeight();
    /// 时间
    [self addSubview:self.dateLabel];
    [self addSubview:self.batteryView];
    /// 电池
    [self.batteryView.layer addSublayer:self.batteryBoundLayer];
    /// 正极
    [self.batteryView.layer addSublayer:self.batteryPositiveLayer];
    /// 是否在充电
    [self.batteryView.layer addSublayer:self.batteryLayer];
    [self.batteryView addSubview:self.batteryImageView];
    [self addSubview:self.batteryLabel];
    [self addSubview:self.networkLabel];
    [self updateUI];
    //默认不开启Timer
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)setRefreshTime:(NSTimeInterval)refreshTime{
    _refreshTime = refreshTime;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    _timer = [NSTimer timerWithTimeInterval:refreshTime>0?refreshTime:5 target:self.weakTarget selector:@selector(updateUI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
#pragma mark - update UI

- (void)updateUI{
    [self updateDate];
    [self updateBattery];
    self.networkLabel.text = [[self class] networkStatus];
}

- (void)updateDate{
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    if(self.is24H == YES){ // 24H制，直接显示
        self.dateLabel.text = dateString;
    }else{
        NSRange amRange = [dateString rangeOfString:[self.dateFormatter AMSymbol]];
        dateString = [dateString substringToIndex:dateString.length-3];
        if(amRange.location == NSNotFound){ // 显示 下午 hh:mm
            self.dateLabel.text = [NSString stringWithFormat:@"下午 %@",dateString];
        }else{ // 显示 上午 hh:mm
            self.dateLabel.text = [NSString stringWithFormat:@"上午 %@",dateString];
        }
    }
}

- (void)updateBattery{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    CGRect rect = CGRectMake(1.5, 1.5, (20-3)*batteryLevel, 10-3);
    UIBezierPath *batteryPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2];
    
    UIColor *batteryColor;
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    if(batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull){ // 在充电 绿色
        batteryColor = UIColorFromHex(0x37CB46);
        self.batteryImageView.hidden = NO;
    }else{
        if(batteryLevel <= 0.2){ // 电量低
            if([NSProcessInfo processInfo].lowPowerModeEnabled){ // 开启低电量模式 黄色
                batteryColor = UIColorFromHex(0xF9CF0E);
            }else{ // 红色
                batteryColor = UIColorFromHex(0xF02C2D);
            }
        }else{ // 电量正常 白色
            batteryColor = [UIColor whiteColor];
        }
        self.batteryImageView.hidden = YES;
    }
    
    self.batteryLayer.strokeColor = [UIColor clearColor].CGColor;
    self.batteryLayer.path = batteryPath.CGPath;
    self.batteryLayer.fillColor = batteryColor.CGColor;
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%",batteryLevel*100];
}

+ (NSString *)networkStatus{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    NSString *net = @"WIFI";
    switch (internetStatus) {
        case ReachableViaWiFi:
            net = @"WIFI";
            break;
        case ReachableViaWWAN:
            net = [self getNetType];   //判断具体类型
            break;
        case NotReachable:
            net = @"无网络";
        default:
            break;
    }
    return net;
}
 
+ (NSString *)getNetType
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    /// 注意：没有SIM卡，值为空
    NSString *currentStatus;
    NSString *currentNet = @"5G";
    if (@available(iOS 12.1, *)) {
        if (info && [info respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
            NSDictionary *radioDic = [info serviceCurrentRadioAccessTechnology];
            if (radioDic.allKeys.count) {
                currentStatus = [radioDic objectForKey:radioDic.allKeys[0]];
            }
        }
    }else{
        currentStatus = info.currentRadioAccessTechnology;
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
        currentNet = @"2G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
        currentNet = @"2G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]){
        currentNet = @"2G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
        currentNet = @"4G";
    }else if (@available(iOS 14.1, *)) {
        if ([currentStatus isEqualToString:CTRadioAccessTechnologyNRNSA]){
            currentNet = @"5G";
        }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyNR]){
            currentNet = @"5G";
        }
    }
    return currentNet;
}

#pragma mark - lazy property

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.bounds = CGRectMake(0, 0, 100, 16);
        _dateLabel.center = CGPointMake(self.bounds.size.width*0.5, 12);
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont boldSystemFontOfSize:12];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}

- (NSDateFormatter*)dateFormatter{
    if (!_dateFormatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        _dateFormatter = formatter;
    }
    return _dateFormatter;
}

- (UIView *)batteryView{
    if (!_batteryView) {
        _batteryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 10)];
    }
    return _batteryView;
}

- (UIImageView *)batteryImageView{
    if (!_batteryImageView) {
        _batteryImageView = [[UIImageView alloc]init];
        _batteryImageView.bounds = CGRectMake(0, 0, 8, 12);
        _batteryImageView.center = CGPointMake(10, 5);
        _batteryImageView.image = YNStatusBar_Image(@"status_lightning");
    }
    return _batteryImageView;
}

- (CAShapeLayer *)batteryLayer{
    if (!_batteryLayer) {
        // 当前的电池电量
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
        UIBezierPath *batteryPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1.5, 1.5, (20-3)*batteryLevel, 10-3) cornerRadius:2];
        
        _batteryLayer = [CAShapeLayer layer];
        _batteryLayer.lineWidth = 1;
        _batteryLayer.strokeColor = [UIColor clearColor].CGColor;
        _batteryLayer.path = batteryPath.CGPath;
        _batteryLayer.fillColor = [UIColor whiteColor].CGColor;
        
    }
    return _batteryLayer;
}
    
- (CAShapeLayer *)batteryBoundLayer{
    if (!_batteryBoundLayer) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 20, 10) cornerRadius:2.5];
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.lineWidth = 1;
        lineLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor;
        lineLayer.path = bezierPath.CGPath;
        lineLayer.fillColor = nil; // 默认为blackColor
        _batteryBoundLayer = lineLayer;
    }
    return _batteryBoundLayer;
}

- (CAShapeLayer *)batteryPositiveLayer{
    if (!_batteryPositiveLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20+2, 3, 1, 3) byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomRight) cornerRadii:CGSizeMake(2, 2)];
        CAShapeLayer *lineLayer2 = [CAShapeLayer layer];
        lineLayer2.lineWidth = 0.5;
        lineLayer2.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor;
        lineLayer2.path = path.CGPath;
        lineLayer2.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor;
        _batteryPositiveLayer = lineLayer2;
    }
    return _batteryPositiveLayer;
}

- (UILabel *)batteryLabel{
    if (!_batteryLabel) {
        UILabel *batteryLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width-35-40-2-SafeAreaRight, 4, 40, 16)];
        batteryLabel.textColor = [UIColor whiteColor];
        batteryLabel.font = [UIFont systemFontOfSize:12];
        batteryLabel.textAlignment = NSTextAlignmentRight;
        _batteryLabel = batteryLabel;
    }
    return _batteryLabel;
}

- (YNStatusBarTarget *)weakTarget {
    if (!_weakTarget) {
        _weakTarget = [YNStatusBarTarget alloc];
        _weakTarget.delegate = self;
    }
    return _weakTarget;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:5 target:self.weakTarget selector:@selector(updateUI) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (UILabel *)networkLabel{
    if (!_networkLabel) {
        _networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.batteryLabel.frame) - 40, 4, 40, 16)];
        _networkLabel.layer.cornerRadius = 8;
        _networkLabel.layer.borderWidth = 1;
        _networkLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _networkLabel.textColor = [UIColor whiteColor];
        _networkLabel.font = [UIFont systemFontOfSize:11];
        _networkLabel.text = @"WIFI";
        _networkLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _networkLabel;
}

- (BOOL)is24H{
    if(!_is24H){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
        NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
        _is24H = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    }
    return _is24H;
}
@end


