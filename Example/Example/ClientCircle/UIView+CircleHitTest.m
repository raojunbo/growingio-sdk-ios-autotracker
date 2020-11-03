//
// UIView+HitTest.m
// Example
//
//  Created by rjb on 2020/11/3.


#import "UIView+CircleHitTest.h"

@implementation UIView (CircleHitTest)

- (UIView *)mj_hitTest:(CGPoint)point withEvent:(UIEvent *)event {
   
    
    //1.判断自己能否接收事件
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) {
        //不能接收事件
        return nil;
    }
    //2.点在不在自己身上
    if (![self pointInside:point withEvent:event]) {
        return nil;
    }
    
    //3.从后往前遍历自己的子控件,把事件传递给子控件,调用子控件的hitTest,
    int count = (int)self.subviews.count;
    
    for (int i = count - 1; i >= 0; i--) {
        
        //获取子控件
        UIView *childView = self.subviews[i];
        
        //把当前点的坐标系转换成子控件的坐标系
        CGPoint childP = [self convertPoint:point toView:childView];
        
        UIView *fitView = [childView mj_hitTest:childP withEvent:event];
        
        if (fitView) {
            return fitView;
        }
        
    }
    //4.如果子控件没有找到最适合的View,那么自己就是最适合的View.
    return self;
}
@end
