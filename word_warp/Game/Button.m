//
//  Button.m
//  word_warp
//
//  Created by Rory B. Bellows on 27/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import "Button.h"

@implementation Button
-(id)initWithBox:(SKShapeNode*)template andPosition:(CGPoint)pos andChar:(NSString*)value {
  box = [template copy];
  box.position = pos;
  box.zPosition = 1;
  letter = value;
  label = [SKLabelNode labelNodeWithText:value];
  label.fontName = @"Menlo-Regular";
  label.zPosition = 1;
  [self adjustFontSize:label withRect:[box frame]];
  selected = NO;
  action_running = NO;
  return [self init];
}

-(void)adjustFontSize:(SKLabelNode*)label withRect:(CGRect)rect {
  label.fontSize *= MIN(rect.size.width / label.frame.size.width, rect.size.height / label.frame.size.height);
  label.position = CGPointMake(rect.origin.x + rect.size.width / 2, (rect.origin.y + rect.size.height / 2) - label.frame.size.height / 2);
}

-(void)addObjects:(SKScene*)scene {
  [scene addChild:box];
  [scene addChild:label];
}

-(BOOL)containsPoint:(CGPoint)point {
  return [box containsPoint:point];
}

-(BOOL)isSelected {
  return selected;
}

-(void)setSelected:(BOOL)b {
  selected = b;
}

-(NSString*)string {
  return letter;
}

-(BOOL)isActionRunning {
  return action_running;
}

-(void)moveTo:(CGPoint)point {
  action_running = YES;
  [box runAction:[SKAction moveTo:point
                         duration:0.2]];
  [label runAction:[SKAction moveTo:CGPointMake(point.x, point.y - ([label frame].size.height / 2))
                           duration:0.2]
        completion:^{
    self->action_running = NO;
  }];
}

-(void)runAction:(SKAction*)action {
  action_running = YES;
  [box runAction:action];
  [label runAction:action
        completion:^{
    self->action_running = NO;
  }];
}

-(SKShapeNode*)getShapeNode {
  return box;
}

-(SKLabelNode*)getLabelNode {
  return label;
}
@end
