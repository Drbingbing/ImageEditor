//
//  UIButton+DeprecationWorkaround.m
//  ImageEditor
//
//  Created by BingBing on 2025/6/13.
//

#import "UIButton+DeprecationWorkaround.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation UIButton (DeprecationWorkaround)

- (UIEdgeInsets)ie_contentEdgeInsets
{
    return self.contentEdgeInsets;
}

- (void)ie_setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    self.contentEdgeInsets = contentEdgeInsets;
}


@end

#pragma clang diagnostic pop

