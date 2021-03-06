//
//  GrowingEvent.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/11/27.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingEvent.h"

#import "GrowingCustomField.h"
#import "GrowingDeviceInfo.h"
#import "GrowingEventManager.h"
#import "GrowingInstance.h"
#import "GrowingNetworkInterfaceManager.h"
#import "NSString+GrowingHelper.h"
#import "UIApplication+GrowingNode.h"

@interface GrowingEvent ()

@property (nonatomic, copy, readwrite) NSString *_Nonnull eventTypeKey;
@property (nonatomic, copy, readwrite) NSString *_Nonnull domain;
@property (nonatomic, copy, readwrite) NSString *_Nullable userId;
@property (nonatomic, copy, readwrite) NSString *_Nonnull deviceId;
@property (nonatomic, strong, readwrite) NSNumber *_Nonnull appState;
@property (nonatomic, copy, readwrite) NSString *_Nonnull uuid;

@end

// base
@implementation GrowingEvent

- (instancetype)initWithUUID:(NSString *)uuid data:(NSDictionary *_Nullable)data {
    if (self = [super init]) {
        self.uuid = uuid;
    }
    return self;
}

- (_Nullable instancetype)initWithUUID:(NSString *_Nonnull)uuid
                              withType:(GrowingEventType)type
                                  data:(NSDictionary *_Nullable)data {
    self = [self initWithUUID:uuid data:data];
    return self;
}

- (instancetype)initWithTimestamp:(NSNumber *)tm {
    self = [self initWithUUID:[[NSUUID UUID] UUIDString] data:nil];
    if (self) {
        GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
        self.sessionId = deviceInfo.sessionID ?: @"";
        self.timestamp = tm ?: GROWGetTimestamp();
        self.eventTypeKey = [self eventTypeKey];
        self.domain = [GrowingDeviceInfo currentDeviceInfo].bundleID;

        if ([GrowingCustomField shareInstance].userId.length > 0) {
            self.userId = [GrowingCustomField shareInstance].userId;
        }
        self.deviceId = [GrowingDeviceInfo currentDeviceInfo].deviceIDString ?: @"";
        self.appState = [NSNumber numberWithInteger:[UIApplication sharedApplication].applicationState];
        self.urlScheme = deviceInfo.urlScheme;
    }
    return self;
}

- (instancetype)init {
    return [self initWithTimestamp:nil];
}

+ (instancetype)event {
    return [[self alloc] init];
}

+ (instancetype)eventWithTimestamp:(NSNumber *)tm {
    return [[self alloc] initWithTimestamp:tm];
}

- (NSString *)description {
    return self.toDictionary.description;
}

- (NSString *)eventTypeKey {
    return @"";
}

#pragma mark GrowingEventCountable

- (NSInteger)nextGlobalSequenceWithBase:(NSInteger)base andStep:(NSInteger)step {
    NSInteger baseSeq = (base > 0) ? base : 0;
    NSInteger baseStep = (step > 0) ? step : 1;

    NSInteger result = baseSeq + baseStep;
    self.globalSequenceId = [NSNumber numberWithInteger:result];
    return result;
}

- (NSInteger)nextEventSequenceWithBase:(NSInteger)base andStep:(NSInteger)step {
    NSInteger baseSeq = (base > 0) ? base : 0;
    NSInteger baseStep = (step > 0) ? step : 1;

    NSInteger result = baseSeq + baseStep;
    self.eventSequenceId = [NSNumber numberWithInteger:result];
    return result;
}

#pragma mark GrowingEventSendPolicyDelegate

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyNormal;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithCapacity:5];
    dataDict[@"sessionId"] = self.sessionId;
    dataDict[@"timestamp"] = self.timestamp;
    dataDict[@"eventType"] = self.eventTypeKey;
    dataDict[@"domain"] = self.domain;
    dataDict[@"userId"] = self.userId;
    dataDict[@"deviceId"] = self.deviceId;

    dataDict[@"globalSequenceId"] = self.globalSequenceId;
    dataDict[@"eventSequenceId"] = self.eventSequenceId;
    dataDict[@"appState"] = (self.appState.intValue == 0) ? @"FOREGROUND" : @"BACKGROUND";
    dataDict[@"urlScheme"] = self.urlScheme;
    return [dataDict copy];
}

- (NSMutableDictionary *)dataDict {
    return [NSMutableDictionary dictionaryWithDictionary:[self toDictionary]];
}

@end

#pragma mark - GrowingEventPersistence

@interface GrowingEventPersistence ()

@property (nonatomic, copy, readwrite) NSString *_Nonnull eventUUID;
@property (nonatomic, copy, readwrite) NSString *_Nonnull eventTypeKey;
@property (nonatomic, copy, readwrite) NSString *_Nonnull rawJsonString;

@end

@implementation GrowingEventPersistence

- (instancetype)initWithUUID:(NSString *)uuid eventType:(NSString *)evnetType jsonString:(NSString *)jsonString {
    if (self = [super init]) {
        self.eventUUID = uuid;
        self.eventTypeKey = evnetType;
        self.rawJsonString = jsonString;
    }
    return self;
}

+ (instancetype)persistenceEventWithEvent:(GrowingEvent *)event {
    NSString *eventJsonString = [[NSString alloc] initWithJsonObject_growingHelper:event.toDictionary];

    return [[GrowingEventPersistence alloc] initWithUUID:event.uuid
                                               eventType:event.eventTypeKey
                                              jsonString:eventJsonString];
}

+ (NSArray<NSString *> *)buildRawEventsFromEvents:(NSArray<GrowingEventPersistence *> *)events {
    NSMutableArray *raws = [NSMutableArray array];
    for (GrowingEventPersistence *e in events) {
        [raws addObject:e.rawJsonString];
    }
    return raws;
}

@end
