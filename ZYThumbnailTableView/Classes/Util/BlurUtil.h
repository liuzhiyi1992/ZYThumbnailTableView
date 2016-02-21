//
//  BlurUtil.h
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/21.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@interface BlurUtil : NSObject

+ (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur
                   withRadius:(CGFloat)blurRadius;

@end
