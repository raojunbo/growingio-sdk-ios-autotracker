//
// UIView+HitTest.h
// Example
//
//  Created by rjb on 2020/11/3.


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CircleHitTest)

- (UIView *)mj_hitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
