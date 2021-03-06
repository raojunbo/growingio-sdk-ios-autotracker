//
//  GrowingXPathManager.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/8/4.
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

#import "GrowingNodeManager.h"

#import "NSString+GrowingHelper.h"
#import "UIView+GrowingNode.h"

#define parentIndexNull NSUIntegerMax

@interface GrowingNodeManagerEnumerateContext ()
@property (nonatomic, assign) BOOL stopAll;
@property (nonatomic, assign) BOOL stopChilds;
@property (nonatomic, retain) NSMutableArray *didEndNodeBlocks;
@property (nonatomic, retain) GrowingNodeManager *manager;

@end

@interface GrowingNodeManagerDataItem : NSObject
/// all indexes display as [n]
@property (nonatomic, copy) NSString *nodeFullPath;
/// the last indexes display as [-]
@property (nonatomic, copy) NSString *nodePatchedPath;
/// up-to-date key index until this node
@property (nonatomic, assign) NSInteger keyIndex;

@property (nonatomic, retain) id<GrowingNode> node;
@property (nonatomic, retain) NSArray<GrowingNodeItemComponent *> *pathComponents;

@end

@implementation GrowingNodeManagerDataItem
- (NSString *)description {
    return NSStringFromClass([self.node class]);
}
@end

@interface GrowingNodeManager ()

@property (nonatomic, retain) id<GrowingNode> enumItem;
@property (nonatomic, retain) NSMutableArray<GrowingNodeManagerDataItem *> *allItems;//本节点及说有的父节点
@property (nonatomic, retain) NSMutableArray<id<GrowingNode>> *allNodes;

@property (nonatomic, copy) BOOL (^checkBlock)(id<GrowingNode> node);

@end

@implementation GrowingNodeManager

- (instancetype)init {
    return nil;
}
- (instancetype)initWithNodeAndParent:(id<GrowingNode>)aNode {
    return nil;
}

//初始化节点和其父节点
- (instancetype)initWithNodeAndParent:(id<GrowingNode>)aNode checkBlock:(BOOL (^)(id<GrowingNode>))checkBlock {
    self = [super init];
    if (self) {
        self.allItems = [[NSMutableArray alloc] initWithCapacity:7];
        self.checkBlock = checkBlock;

        //如果当前节点不为nil,将其放入节点的最前面
        id<GrowingNode> curNode = aNode;
        while (curNode) {
            [self addNodeAtFront:curNode];
            curNode = [curNode growingNodeParent];
        }

        if (!self.allItems.count) {
            return nil;
        }
        
        for (GrowingNodeManagerDataItem *item in self.allItems) {
            if (checkBlock && !checkBlock(item.node)) {
                return nil;
            }
        }
    }
    return self;
}

- (void)enumerateChildrenUsingBlock:(void (^)(id<GrowingNode>, GrowingNodeManagerEnumerateContext *))block {
    if (!block || self.allItems.count == 0) {
        return;
    }
    //取出当前节点工具的最后一个节点。也就是本节点
    self.enumItem = self.allItems.lastObject.node;
    [self _enumerateChildrenUsingBlock:block];
    self.enumItem = nil;
}

- (GrowingNodeManagerEnumerateContext *)_enumerateChildrenUsingBlock:
    (void (^)(id<GrowingNode>, GrowingNodeManagerEnumerateContext *))block {
    NSUInteger endIndex = self.allItems.count - 1;
    GrowingNodeManagerDataItem *endItem = self.allItems[endIndex];//取出最后一个节点

    GrowingNodeManagerEnumerateContext *context = [[GrowingNodeManagerEnumerateContext alloc] init];
    context.manager = self;         //上下文的manager是context
    block(endItem.node, context);   //执行外部的block

    if (context.stopAll || context.stopChilds) { //外部可能通过这个context去操纵
        return context;
    }
    
    //endItem基本是自己。遍历查看自己的子节点
    NSArray *childs = [endItem.node growingNodeChilds];
    for (int i = 0; i < childs.count; i++) {
        id<GrowingNode> node = childs[i];
        if (!self.checkBlock || self.checkBlock(node)) {
            [self addNodeAtEnd:node];//将当前节点的一个子节点加入allitems最后
            GrowingNodeManagerEnumerateContext *childContext = [self _enumerateChildrenUsingBlock:block];
            [self removeNodeItemAtEnd];

            if (childContext.stopAll) {
                context.stopAll = YES;
                return context;
            }
        }
    }

    return context;
}

#pragma mark - 添加删除

// 在前面添加
- (void)addNodeAtFront:(id<GrowingNode>)aNode {
    GrowingNodeManagerDataItem *item = [[GrowingNodeManagerDataItem alloc] init];
    item.node = aNode;
    [self.allItems insertObject:item atIndex:0];
}

// 在后面添加
- (void)addNodeAtEnd:(id<GrowingNode>)aNode {
    GrowingNodeManagerDataItem *dataItem = [[GrowingNodeManagerDataItem alloc] init];
    dataItem.node = aNode;
    [self.allItems addObject:dataItem];
}

// 移除最后一个节点
- (void)removeNodeItemAtEnd {
    [self.allItems removeLastObject];
}


- (NSUInteger)nodeCount {
    return self.allItems.count;
}


- (GrowingNodeManagerDataItem *)itemAtIndex:(NSUInteger)index {
    return self.allItems[index];
}

- (GrowingNodeManagerDataItem *)itemAtEnd {
    return self.allItems.lastObject;
}

- (GrowingNodeManagerDataItem *)itemAtFirst {
    return self.allItems.firstObject;
}

- (id<GrowingNode>)nodeAtFirst {
    return [[self itemAtFirst] node];
}

@end

@implementation GrowingNodeManagerEnumerateContext

- (NSArray<id<GrowingNode>> *)allNodes {
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    [self.manager.allItems
        enumerateObjectsUsingBlock:^(GrowingNodeManagerDataItem *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [nodes addObject:obj.node];
        }];
    return nodes;
}

- (id<GrowingNode>)startNode {
    return self.manager.enumItem;
}

- (void)stop {
    self.stopAll = YES;
}

- (void)skipThisChilds {
    self.stopChilds = YES;
}

- (void)onNodeFinish:(void (^)(id<GrowingNode>))finishBlock {
    if (!self.didEndNodeBlocks) {
        self.didEndNodeBlocks = [[NSMutableArray alloc] init];
    }
    [self.didEndNodeBlocks addObject:finishBlock];
}


@end
