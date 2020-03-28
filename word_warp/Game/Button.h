//
//  Button.h
//  word_warp
//
//  Created by Rory B. Bellows on 27/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Button : NSObject {
  SKShapeNode *box;
  SKLabelNode *label;
  NSString *letter;
  BOOL selected, action_running;
  NSUInteger box_idx;
}

-(id)initWithBox:(SKShapeNode*)template andPosition:(CGPoint)pos andChar:(NSString*)value;
-(void)adjustFontSize:(SKLabelNode*)label withRect:(CGRect)rect;
-(void)addObjects:(SKScene*)scene;
-(BOOL)containsPoint:(CGPoint)point;
-(BOOL)isSelected;
-(void)setSelected:(BOOL)b;
-(NSString*)string;
-(BOOL)isActionRunning;
-(void)moveTo:(CGPoint)point;
-(void)runAction:(SKAction*)action;
-(SKShapeNode*)getShapeNode;
-(SKLabelNode*)getLabelNode;
@end
