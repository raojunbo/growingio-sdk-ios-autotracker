//
//  GrowingAutoTracker.m
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2018/5/14.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "GrowingAutoTracker.h"
#import "GrowingInstance.h"
#import "GrowingMediator+GrowingDeepLink.h"
#import "NSString+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingIMPTrack.h"
#import "UIView+GrowingNode.h"
#import <objc/runtime.h>
#import "GrowingPageEvent.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingSwizzle.h"
#import "UIViewController+GrowingAutoTrack.h"
#import "UIApplication+GrowingAutoTrack.h"
#import "UISegmentedControl+GrowingAutoTrack.h"
#import "UIView+GrowingAutoTrack.h"
#import "NSNotificationCenter+GrowingAutoTrack.h"
#import "WKWebView+GrowingAutoTrack.h"
#import "UITableView+GrowingAutoTrack.h"
#import "UICollectionView+GrowingAutoTrack.h"
#import "UITapGestureRecognizer+GrowingAutoTrack.h"
#import "GrowingConfiguration+GrowingAutoTrack.h"
#import "UIAlertController+GrowingAutoTrack.h"
#import "UIViewController+GrowingNode.h"
#import "GrowingBroadcaster.h"
#import "GrowingMessageProtocol.h"

@GrowingBroadcasterRegister(GrowingTrackerConfigurationMessage, Growing)
@interface Growing (AutoTrackKit) <GrowingTrackerConfigurationMessage>

@end

@implementation Growing (AutoTrackKit)

+ (void)growingTrackerConfigurationDidChanged:(GrowingConfiguration *)configuration {
//    [self addAutoTrackSwizzles];//添加自动追踪交换
   
}

+ (void)addAutoTrackSwizzles {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = NULL;
        // UIViewController
        [UIViewController growing_swizzleMethod:@selector(viewDidAppear:)
                                     withMethod:@selector(growing_viewDidAppear:)
                                          error:&error];

        [UIViewController growing_swizzleMethod:@selector(viewDidDisappear:)
                                     withMethod:@selector(growing_viewDidDisappear:)
                                          error:&error];
        if (error) {
            GIOLogError(@"Failed to swizzle UIViewController. Details: %@", error);
            error = NULL;
        }
        
        // UIApplication
        NSError *applicatonError = NULL;
        [UIApplication growing_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                                  withMethod:@selector(growing_sendAction:to:from:forEvent:)
                                       error:&applicatonError];
        if (applicatonError) {
            GIOLogError(@"Failed to swizzle UIApplication. Details: %@", applicatonError);
        }
        
        // UISegmentControl
        NSError *segmentControlError = NULL;
        [UISegmentedControl growing_swizzleMethod:@selector(initWithCoder:)
                                       withMethod:@selector(growing_initWithCoder:)
                                            error:&segmentControlError];
        [UISegmentedControl growing_swizzleMethod:@selector(initWithFrame:)
                                       withMethod:@selector(growing_initWithFrame:)
                                            error:&segmentControlError];
        [UISegmentedControl growing_swizzleMethod:@selector(initWithItems:)
                                       withMethod:@selector(growing_initWithItems:)
                                            error:&segmentControlError];
        if (segmentControlError) {
            GIOLogError(@"Failed to swizzle UISegmentControl. Details: %@", segmentControlError);
        }
        
        // UIView
        NSError *viewError = NULL;
        [UIView growing_swizzleMethod:@selector(didMoveToSuperview)
                           withMethod:@selector(growing_didMoveToSuperview)
                                error:&viewError];
        if (viewError) {
            GIOLogError(@"Failed to swizzle UIView. Details: %@", viewError);
        }
        
        // NSNotificationCenter
        NSError *notiError = NULL;
        [NSNotificationCenter growing_swizzleMethod:@selector(postNotificationName:object:userInfo:)
                                         withMethod:@selector(growing_postNotificationName:object:userInfo:)
                                              error:&notiError];
        if (notiError) {
            GIOLogError(@"Failed to swizzle NSNotificationCenter. Details: %@", notiError);
        }
        
        // WKWebView
        NSError *webViewError = NULL;
        [WKWebView growing_swizzleMethod:@selector(initWithFrame:configuration:)
                              withMethod:@selector(growing_initWithFrame:configuration:)
                                   error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView. Details: %@", webViewError);
        }
        
        // ListView
        NSError *listViewError = NULL;
        [UITableView growing_swizzleMethod:@selector(setDelegate:)
                                withMethod:@selector(growing_setDelegate:)
                                     error:&listViewError];

        [UICollectionView growing_swizzleMethod:@selector(setDelegate:)
                                     withMethod:@selector(growing_setDelegate:)
                                          error:&listViewError];
        if (listViewError) {
            GIOLogError(@"Failed to swizzle ListView. Details: %@", listViewError);
        }
        
        // UITapGesture
        NSError *gestureError = NULL;
        [UITapGestureRecognizer growing_swizzleMethod:@selector(initWithCoder:)
                                           withMethod:@selector(growing_initWithCoder:)
                                                error:&gestureError];
        [UITapGestureRecognizer growing_swizzleMethod:@selector(initWithTarget:action:)
                                           withMethod:@selector(growing_initWithTarget:action:)
                                                error:&gestureError];
        if (gestureError) {
            GIOLogError(@"Failed to swizzle UITapGesture. Details: %@", listViewError);
        }
        
        // UIAlertController
        SEL oldDismissActionSEL = NSSelectorFromString([NSString stringWithFormat:@"_%@:%@:",
                                                        @"dismissAnimated",
                                                        @"triggeringAction"]);

        NSString *dismissActionStr = [NSString stringWithFormat:@"_%@:%@:%@:%@:",
                                      @"dismissAnimated",
                                      @"triggeringAction",
                                      @"triggeredByPopoverDimmingView",
                                      @"dismissCompletion"];
        SEL dismissActionSELFromIOS11 = NSSelectorFromString(dismissActionStr);

        NSError *alertError = NULL;
        [UIAlertController growing_swizzleMethod:oldDismissActionSEL
                                      withMethod:@selector(growing_dismissAnimated:triggeringAction:)
                                           error:&alertError];
        
        [UIAlertController growing_swizzleMethod:dismissActionSELFromIOS11
                                      withMethod:@selector(growing_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:dismissCompletion:)
                                           error:&alertError];
        
        if (alertError) {
            GIOLogError(@"Failed to swizzle UIAlertController. Details: %@", alertError);
        }
    });
}

@end

@implementation UIView (GrowingImpression)

- (void)growingTrackImpression:(NSString *)eventName {
    [self growingTrackImpression:eventName attributes:nil];
}

- (void)growingTrackImpression:(NSString *)eventName
                    attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    
    if (eventName.length == 0) {
        return;
    }
    
    if ([eventName isEqualToString:self.growingIMPTrackEventName]) {
        if ((attributes && [attributes isEqualToDictionary:self.growingIMPTrackVariable]) ||
            attributes == self.growingIMPTrackVariable) {
            return;
        }
    }
    
    [GrowingIMPTrack shareInstance].impTrackActive = YES;
    
    self.growingIMPTrackEventName = eventName;
    self.growingIMPTrackVariable = attributes;
    self.growingIMPTracked = NO;
    [[GrowingIMPTrack shareInstance] addNode:self inSubView:NO];
}

- (void)growingStopTrackImpression {
    [[GrowingIMPTrack shareInstance] clearNode:self];
}

@end
