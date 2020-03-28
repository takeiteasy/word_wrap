//
//  LoseScene.m
//  word_warp
//
//  Created by Rory B. Bellows on 28/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import "LoseScene.h"
#import "MenuScene.h"
#import "Settings.h"

@implementation LoseScene
-(void)didMoveToView:(SKView *)view {
  settings = [GameSettings sharedSettings];
  
  [self setBackgroundColor:[SKColor blackColor]];
  
  if ([[[settings dict] objectForKey:@"loseScreen"] boolValue])
    title = [SKSpriteNode spriteNodeWithImageNamed:@"time_up"];
  else
    title = [SKSpriteNode spriteNodeWithImageNamed:@"records"];
  [self addChild:title];
  [title runAction:[SKAction sequence:@[
    [SKAction waitForDuration:0.5],
    [SKAction moveTo:CGPointMake(0, [self size].height / 3)
            duration:0.5]
  ]]];
  
  SKColor *red_border = [SKColor colorWithRed:0.98
                                        green:0.42
                                         blue:0.52
                                        alpha:1.0];
  SKShapeNode *box_template = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake([self size].width / 2, 100)];
  box_template.strokeColor = red_border;
  box_template.fillColor = red_border;
  box_template.alpha = 0.0;
  menu_btn = [[Button alloc] initWithBox:box_template andPosition:CGPointMake(0, -([self size].height / 2) + [box_template frame].size.height) andChar:@"RETURN"];
  [[menu_btn getLabelNode] setAlpha:0.0];
  [menu_btn addObjects:self];
  [menu_btn runAction:[SKAction sequence:@[
    [SKAction waitForDuration:1.5],
    [SKAction fadeInWithDuration:0.5]
  ]]];
  
  NSInteger left = [self size].width / 2;
  NSTimeInterval __block delay = 1.5;
  NSInteger __block ypos = [self size].height / 6;
  [[settings scores] enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
    SKAction *fade = [SKAction sequence:@[
      [SKAction waitForDuration:delay],
      [SKAction fadeInWithDuration:0.2]
    ]];
    
    SKLabelNode *key_lbl = [SKLabelNode labelNodeWithText:[[key capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    key_lbl.position = CGPointMake(-left + ([key_lbl frame].size.width / 2) + 50, ypos);
    key_lbl.alpha = 0.0;
    [self addChild:key_lbl];
    [key_lbl runAction:fade];
    
    SKLabelNode *val_lbl = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%@", obj]];
    val_lbl.position = CGPointMake(left - ([val_lbl frame].size.width / 2) - 50, ypos);
    val_lbl.alpha = 0.0;
    [self addChild:val_lbl];
    [val_lbl runAction:fade];
    
    ypos -= [key_lbl frame].size.height + 10;
    delay += 0.1;
  }];
  
  if ([[[settings dict] objectForKey:@"newRecord"] boolValue]) {
    [[settings dict] setObject:[NSNumber numberWithBool:YES] forKey:@"newRecord"];
    SKSpriteNode *new_record = [SKSpriteNode spriteNodeWithImageNamed:@"new_record"];
    new_record.alpha = 0.0;
    new_record.xScale = 0.0;
    new_record.yScale = 0.0;
    [self addChild:new_record];
    [new_record runAction:[SKAction waitForDuration:1.0] completion:^{
      [new_record runAction:[SKAction fadeInWithDuration:0.5]];
      [new_record runAction:[SKAction scaleTo:1.0 duration:0.5]];
      [new_record runAction:[SKAction rotateByAngle:6.28319 duration:0.5] completion:^{
        [new_record runAction:[SKAction sequence:@[
          [SKAction waitForDuration:1.0],
          [SKAction fadeOutWithDuration:0.5],
          [SKAction removeFromParent]
        ]]];
      }];
    }];
  }
}

-(void)touchDownAtPoint:(CGPoint)pos {
}

-(void)touchMovedToPoint:(CGPoint)pos {
}

-(void)touchUpAtPoint:(CGPoint)pos {
  if ([menu_btn containsPoint:pos]) {
    [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                               waitForCompletion:NO]];
    GameSettings* settings = [GameSettings sharedSettings];
    [[settings dict] removeAllObjects];
    MenuScene *scene = (MenuScene*)[SKScene nodeWithFileNamed:@"MenuScene"];
    [[self view] presentScene:scene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
  }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *t in touches) {[self touchDownAtPoint:[t locationInNode:self]];}
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
  for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}

-(void)update:(CFTimeInterval)currentTime {
}
@end
