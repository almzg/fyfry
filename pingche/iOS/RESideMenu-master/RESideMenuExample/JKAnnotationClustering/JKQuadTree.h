//
//  JKQuadTree.h
//  RESideMenuExample
//
//  Created by Albert Gu on 1/6/14.
//  Copyright (c) 2014 New Life. All rights reserved.
//

#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////

typedef struct JKQuadTreeNodeData
{
    double x;
    double y;
    void   *data;
}JKQuadTreeNodeData;

JKQuadTreeNodeData JKQuadTreeNodeDataMake(double x, double y, void* data);

typedef struct JKBoundingBox
{
    double xMin; double yMin;
    double xMax; double yMax;
}JKBoundingBox;

JKBoundingBox JKBoundingBoxMake(double xMin, double yMin, double xMax, double yMax);

//////////////////////////////////////////////////////////////////////////////////

typedef struct JKQuadTreeNode
{
    struct JKQuadTreeNode *northWest;
    struct JKQuadTreeNode *northEast;
    struct JKQuadTreeNode *southWest;
    struct JKQuadTreeNode *southEast;
    
    JKBoundingBox boundingBox;
    int bucketCapacity;
    
    JKQuadTreeNodeData *points;
    int count;
}JKQuadTreeNode;

JKQuadTreeNode* JKQuadTreeNodeMake(JKBoundingBox boundary, int bucketCapacity);

//////////////////////////////////////////////////////////////////////////////////

void JKFreeQuadTreeNode(JKQuadTreeNode *node);

bool JKBoundingBoxContainsData(JKBoundingBox box, JKQuadTreeNodeData data);
bool JKBoundingBoxIntersectsBoundingBox(JKBoundingBox b1, JKBoundingBox b2);

typedef void (^JKQuadTreeTraverseBlock) (JKQuadTreeNode *currentNode);
void JKQuadTreeTraverse(JKQuadTreeNode *node, JKQuadTreeTraverseBlock block);

typedef void (^JKDataReturnBlock) (JKQuadTreeNodeData data);
void JKQuadTreeGatherDataInRange(JKQuadTreeNode *node, JKBoundingBox range, JKDataReturnBlock block);

bool JKQuadTreeNodeInsertData(JKQuadTreeNode *node, JKQuadTreeNodeData data);
JKQuadTreeNode* JKQuadTreeBuildWithData(JKQuadTreeNodeData *data, int count, JKBoundingBox boundingBox, int capacity);






















