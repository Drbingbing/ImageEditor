//
//  UIButton+DeprecationWorkaround.h
//  ImageEditor
//
//  Created by BingBing on 2025/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (DeprecationWorkaround)

@property (nonatomic, setter=ie_setContentEdgeInsets:) UIEdgeInsets ie_contentEdgeInsets;

@end

NS_ASSUME_NONNULL_END
