//
//  COLLADARoot+viewAdditions.m
//  SPEditor
//
//  Created by Erik Buck on 9/29/12.
//  Copyright (c) 2012 Erik Buck. All rights reserved.
//

#import "COLLADARoot+viewAdditions.h"
#import "COLLADANode.h"
#import "COLLADAMeshGeometry.h"
#import "COLLADAInstanceGeometry.h"
#import "COLLADAEffect.h"
#import "AGLKEffect.h"
#import "COLLADAImagePath.h"
#import "AGLKMesh+viewAdditions.h"

#undef __gl_h_
#import <GLKit/GLKit.h>


@implementation COLLADAMeshGeometry (viewAdditions)

- (void)prepareToDrawWithEffect:(AGLKEffect *)anEffect;
{
}


- (void)drawWithEffect:(AGLKEffect *)anEffect
   root:(COLLADARoot *)aRoot;
{
   [anEffect prepareToDraw];
   [self.mesh prepareToDraw];
   [self.mesh drawAllCommands];
}

@end


@implementation COLLADAInstance (viewAdditions)

- (void)prepareToDrawWithEffect:(AGLKEffect *)anEffect;
{
}


- (void)drawWithEffect:(AGLKEffect *)anEffect
   root:(COLLADARoot *)aRoot;
{
   id referencedNode =
      [aRoot.nodes objectForKey:self.url];
   
   if(nil == referencedNode)
   {
      NSLog(@"instance_node references unknown geometry");
      return;
   }
   
   [referencedNode drawWithEffect:anEffect
      root:aRoot];
}

@end


@implementation COLLADAInstanceGeometry (viewAdditions)

- (void)prepareToDrawWithEffect:(AGLKEffect *)anEffect;
{
}


- (void)drawWithEffect:(AGLKEffect *)anEffect
   root:(COLLADARoot *)aRoot;
{
   id referencedGeometry =
      [aRoot.geometries objectForKey:self.url];
   
   if(nil == referencedGeometry)
   {
      NSLog(@"instance_geometry references unknown geometry");
      return;
   }
   
   anEffect.texture2d0.name = 0;
   anEffect.texture2d0.target = 0;

   COLLADAInstance *bindMaterial =
      [self.bindMaterials anyObject];
   if(nil != bindMaterial)
   {
      COLLADAResource *referencedMaterial =
         [aRoot.materials objectForKey:bindMaterial.url];
      
      if(nil == referencedMaterial)
      {
         NSLog(@"instance_geometry references unknown material");
      }
      else
      {
         COLLADAInstance *instanceEffect =
            referencedMaterial.instances.anyObject;
         
         COLLADAEffect *referencedEffect =
            [aRoot.effects objectForKey:instanceEffect.url];
         
         if(nil == referencedEffect)
         {
            NSLog(@"instance_geometry references unknown effect");
         }
         else
         {
            COLLADAImagePath *referencedImagePath =
               [aRoot.imagePaths
                  objectForKey:referencedEffect.diffuseTextureImagePathURL];
            
            if(nil != referencedImagePath)
            {
               anEffect.texture2d0.name =
                  referencedImagePath.textureInfo.name;
               anEffect.texture2d0.target =
                  referencedImagePath.textureInfo.target;
               
//               NSLog(@"%@ %d", referencedImagePath.uid, anEffect.texture2d0.name);
            }
         }
      }
   }
   
   [referencedGeometry drawWithEffect:anEffect
      root:aRoot];
}

@end


@implementation COLLADANode (viewAdditions)

- (void)prepareToDrawWithEffect:(AGLKEffect *)anEffect;
{
}


- (void)drawWithEffect:(AGLKEffect *)anEffect
   root:(COLLADARoot *)aRoot;
{
   GLKMatrix4 savedMatrix =
      anEffect.transform.modelviewMatrix;

   anEffect.transform.modelviewMatrix =
      GLKMatrix4Multiply(savedMatrix, self.transform);
   
   for(COLLADAInstance *instance in self.instances)
   {
      [instance drawWithEffect:anEffect
         root:aRoot];
   }
   
   for(COLLADANode *subnode in self.subnodes)
   {
      [subnode drawWithEffect:anEffect
         root:aRoot];
   }
   
   anEffect.transform.modelviewMatrix =
      savedMatrix;
}

@end


@implementation COLLADARoot (viewAdditions)

- (void)prepareToDrawWithEffect:(AGLKEffect *)anEffect;
{
}


- (void)drawWithEffect:(AGLKEffect *)anEffect;
{
   GLKMatrix4 savedMatrix =
      anEffect.transform.modelviewMatrix;

   anEffect.transform.modelviewMatrix =
      GLKMatrix4Multiply(savedMatrix, self.transform);
   
   for(COLLADANode *scene in self.visualScenes.allValues)
   {
      [scene drawWithEffect:anEffect
         root:self];
   }
   
   anEffect.transform.modelviewMatrix =
      savedMatrix;
}

@end
