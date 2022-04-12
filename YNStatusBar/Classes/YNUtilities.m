//
//  YNUtilities.m
//  YNStatusBar
//
//  Created by Ace on 2022/4/12.
//

#import "YNUtilities.h"

@implementation YNUtilities

+ (NSBundle *)bundle{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"YNStatusBar" ofType:@"bundle"]];
    });
    return bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name inBundle:[self bundle] compatibleWithTraitCollection:nil];
    return image;
}
@end
