//
//  JKQuadTree.m
//  RESideMenuExample
//
//  Created by Albert Gu on 1/6/14.
//  Copyright (c) 2014 New Life. All rights reserved.
//

#import "JKQuadTree.h"

#pragma mark - Constructors

JKQuadTreeNodeData JKQuadTreeNodeDataMake(double x, double y, void* data)
{
    JKQuadTreeNodeData nodeData;
    nodeData.x = x;
    nodeData.y = y;
    nodeData.data = data;
    
    return nodeData;
}

JKBoundingBox JKBoundingBoxMake(double xMin, double yMin, double xMax, double yMax)
{
    JKBoundingBox box;
    box.xMin = xMin;
    box.yMin = yMin;
    box.xMax = xMax;
    box.yMax = yMax;
    
    return box;
}

JKQuadTreeNode* JKQuadTreeNodeMake(JKBoundingBox boundary, int bucketCapacity)
{
    JKQuadTreeNode* node = malloc(sizeof(JKQuadTreeNode));
    node->northWest = node->northEast = node->southWest = node->southEast = NULL;
    
    node->boundingBox = boundary;
    node->bucketCapacity = bucketCapacity;
    node->count = 0;
    node->points = malloc(sizeof(JKQuadTreeNodeData) * bucketCapacity);
    
    return node;
}

#pragma mark - Bounding Box Functions

bool JKBoundingBoxContainsData(JKBoundingBox box, JKQuadTreeNodeData data)
{
    bool containsX = box.xMin <= data.x && data.x <= box.xMax;
    bool containsY = box.yMin <= data.y && data.y <= box.yMax;
    
    return containsX && containsY;
}

bool JKBoundingBoxIntersectsBoundingBox(JKBoundingBox b1, JKBoundingBox b2)
{
    return (b1.xMin <= b2.xMax && b1.xMax >= b2.xMin && b1.yMin <= b2.yMax && b1.yMax >= b2.yMin);
}

#pragma mark - Quad Tree Functions

void JKQuadTreeNodeSubdivide(JKQuadTreeNode* node)
{
    JKBoundingBox box = node->boundingBox;
    
    double xMid = (box.xMax + box.xMin) / 2.0;
    double yMid = (box.yMax + box.yMin) / 2.0;
    
    JKBoundingBox northWest = JKBoundingBoxMake(box.xMin, box.yMin, xMid, yMid);
    node->northWest = JKQuadTreeNodeMake(northWest, node->bucketCapacity);
    
    JKBoundingBox northEast = JKBoundingBoxMake(xMid, box.yMin, box.xMax, yMid);
    node->northEast = JKQuadTreeNodeMake(northEast, node->bucketCapacity);
    
    JKBoundingBox southWest = JKBoundingBoxMake(box.xMin, yMid, xMid, box.yMax);
    node->southWest = JKQuadTreeNodeMake(southWest, node->bucketCapacity);
    
    JKBoundingBox southEast = JKBoundingBoxMake(xMid, yMid, box.xMax, box.yMax);
    node->southEast = JKQuadTreeNodeMake(southEast, node->bucketCapacity);
}

bool JKQuadTreeNodeInsertData(JKQuadTreeNode* node, JKQuadTreeNodeData data)
{
    if (!JKBoundingBoxContainsData(node->boundingBox, data))
    {
        return false;
    }
    
    if (node->count < node->bucketCapacity)
    {
        node->points[node->count++] = data;
        
        return true;
    }
    
    if (node->northWest == NULL)
    {
        JKQuadTreeNodeSubdivide(node);
    }
    
    if (JKQuadTreeNodeInsertData(node->northWest, data)) return true;
    if (JKQuadTreeNodeInsertData(node->northEast, data)) return true;
    if (JKQuadTreeNodeInsertData(node->southWest, data)) return true;
    if (JKQuadTreeNodeInsertData(node->southEast, data)) return true;
    
    return false;
}

void JKQuadTreeGatherDataInRange(JKQuadTreeNode* node, JKBoundingBox range, JKDataReturnBlock block)
{
    if (!JKBoundingBoxIntersectsBoundingBox(node->boundingBox, range))
    {
        return;
    }
    
    for (int i = 0; i < node->count; i++)
    {
        if (JKBoundingBoxContainsData(range, node->points[i]))
        {
            block(node->points[i]);
        }
    }

    if (node->northWest == NULL)
    {
        return;
    }

    JKQuadTreeGatherDataInRange(node->northWest, range, block);
    JKQuadTreeGatherDataInRange(node->northEast, range, block);
    JKQuadTreeGatherDataInRange(node->southWest, range, block);
    JKQuadTreeGatherDataInRange(node->southEast, range, block);
}

void JKQuadTreeTraverse(JKQuadTreeNode* node, JKQuadTreeTraverseBlock block)
{
    block(node);
    
    if (node->northWest == NULL)
    {
        return;
    }
    
    JKQuadTreeTraverse(node->northWest, block);
    JKQuadTreeTraverse(node->northEast, block);
    JKQuadTreeTraverse(node->southWest, block);
    JKQuadTreeTraverse(node->southEast, block);
}

JKQuadTreeNode* JKQuadTreeBuildWithData(JKQuadTreeNodeData *data, int count, JKBoundingBox boundingBox, int capacity)
{
    JKQuadTreeNode* root = JKQuadTreeNodeMake(boundingBox, capacity);
    
    for (int i = 0; i < count; i++)
    {
        JKQuadTreeNodeInsertData(root, data[i]);
    }
    
    return root;
}

void JKFreeQuadTreeNode(JKQuadTreeNode* node)
{
    if (node->northWest != NULL) JKFreeQuadTreeNode(node->northWest);
    if (node->northEast != NULL) JKFreeQuadTreeNode(node->northEast);
    if (node->southWest != NULL) JKFreeQuadTreeNode(node->southWest);
    if (node->southEast != NULL) JKFreeQuadTreeNode(node->southEast);
    
    for (int i = 0; i < node->count; i++)
    {
        free(node->points[i].data);
    }
    
    free(node->points);
    free(node);
}

