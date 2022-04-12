//
//  YNUtilities.h
//  YNStatusBar
//
//  Created by Ace on 2022/4/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define YNStatusBar_Image(file)                 [YNUtilities imageNamed:file]
NS_ASSUME_NONNULL_BEGIN

@interface YNUtilities : NSObject

+ (UIImage*)imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
