//
//  MenuScene.m
//  word_warp
//
//  Created by Rory B. Bellows on 27/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"
#import "LoseScene.h"

@implementation MenuScene
-(void)didMoveToView:(SKView *)view {
  SKColor *bg_color = [SKColor colorWithRed:0.98
                                      green:0.55
                                       blue:0.67
                                      alpha:1.0];
  [self setBackgroundColor:bg_color];
  
  // [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
  
  settings = [GameSettings sharedSettings];
  NSArray* scores = @[
    @"total_easy_rounds",
    @"total_normal_rounds",
    @"total_hard_rounds",
    @"easy_rounds_streak",
    @"normal_rounds_streak",
    @"hard_rounds_streak",
    @"easy_timed_streak",
    @"normal_timed_streak",
    @"hard_timed_streak",
    @"total_words_easy",
    @"total_words_normal",
    @"total_words_hard"
  ];
  [scores enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:obj])
      [[NSUserDefaults standardUserDefaults] setInteger:0
                                                 forKey:obj];
    [[settings scores] setObject:[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:obj]]
                          forKey:obj];
  }];
  if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longest_word"])
    [[NSUserDefaults standardUserDefaults] setObject:@""
                                              forKey:@"longest_word"];
  [[settings scores] setObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"longest_word"]
                        forKey:@"longest_word"];
  
  bg_music = [[SKAudioNode alloc] initWithFileNamed:@"menu_bg.caf"];
  [bg_music setAutoplayLooped:YES];
  [bg_music runAction:[SKAction changeVolumeTo:0.2
                                      duration:0.0]];
  [self addChild:bg_music];
  
  logo = [SKSpriteNode spriteNodeWithImageNamed:@"logo"];
  logo.position = CGPointMake(0, [logo size].height);
  logo.alpha = 0.0;
  [self addChild:logo];
  [logo runAction:[SKAction fadeInWithDuration:0.8]];
  
  timed_unselected = [SKSpriteNode spriteNodeWithImageNamed:@"timed_unselected"];
  CGPoint timed_pos = CGPointMake(0, -([self size].height / 2) + [timed_unselected size].height + 10);
  timed_unselected.position = CGPointMake(0, -[self size].height);
  [self addChild:timed_unselected];
  [timed_unselected runAction:[SKAction moveTo:timed_pos
                                      duration:0.5]];
  timed_selected = [SKSpriteNode spriteNodeWithImageNamed:@"timed_selected"];
  timed_selected.position = timed_pos;
  enable_timed = NO;
  
  SKColor *red_border = [SKColor colorWithRed:0.98
                                        green:0.42
                                         blue:0.52
                                        alpha:1.0];
  SKShapeNode *box_template = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake([self size].width / 2, 100)];
  box_template.strokeColor = red_border;
  box_template.fillColor = red_border;
  box_template.alpha = 0.0;
  
  easy = [[Button alloc] initWithBox:box_template
                         andPosition:CGPointMake(0, 0)
                             andChar:@"EASY"];
  [[easy getLabelNode] setAlpha:0.0];
  [easy addObjects:self];
  [easy runAction:[SKAction sequence:@[
    [SKAction waitForDuration:0.2],
    [SKAction fadeInWithDuration:0.2]
  ]]];
  normal = [[Button alloc] initWithBox:box_template
                           andPosition:CGPointMake(0, -110)
                               andChar:@"NORMAL"];
  [[normal getLabelNode] setAlpha:0.0];
  [normal addObjects:self];
  [normal runAction:[SKAction sequence:@[
    [SKAction waitForDuration:0.4],
    [SKAction fadeInWithDuration:0.2]
  ]]];
  hard = [[Button alloc] initWithBox:box_template
                         andPosition:CGPointMake(0, -220)
                             andChar:@"HARD"];
  [[hard getLabelNode] setAlpha:0.0];
  [hard addObjects:self];
  [hard runAction:[SKAction sequence:@[
    [SKAction waitForDuration:0.6],
    [SKAction fadeInWithDuration:0.2]
  ]]];
  
  trophy = [SKSpriteNode spriteNodeWithImageNamed:@"trophy"];
  trophy.alpha = 0.0;
  trophy.position = CGPointMake([box_template frame].size.width / 2 - [trophy frame].size.width, [box_template frame].size.height / 2 + ([trophy frame].size.height / 2 - 5));
  [self addChild:trophy];
  [trophy runAction:[SKAction sequence:@[
    [SKAction waitForDuration:0.2],
    [SKAction fadeInWithDuration:0.2]
  ]]];
}

-(void)touchDownAtPoint:(CGPoint)pos {
  if ([trophy containsPoint:pos]) {
    [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                               waitForCompletion:NO]];
    [[settings dict] setObject:[NSNumber numberWithBool:NO]
                        forKey:@"loseScreen"];
    LoseScene *scene = (LoseScene*)[SKScene nodeWithFileNamed:@"LoseScene"];
    [[self view] presentScene:scene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
    return;
  }
  
  if (enable_timed) {
    if ([timed_unselected containsPoint:pos]) {
      [timed_selected removeFromParent];
      [self addChild:timed_unselected];
      enable_timed = NO;
      [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                                 waitForCompletion:NO]];
    }
  } else {
    if ([timed_unselected containsPoint:pos]) {
      [timed_unselected removeFromParent];
      [self addChild:timed_selected];
      enable_timed = YES;
      [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                                 waitForCompletion:NO]];
    }
  }

  NSInteger difficulty = -1;
  if ([easy containsPoint:pos])
    difficulty = 0;
  else if ([normal containsPoint:pos])
    difficulty = 1;
  else if ([hard containsPoint:pos])
    difficulty = 2;
  if (difficulty != -1) {
    [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                               waitForCompletion:NO]];
    [[settings dict] setObject:[NSNumber numberWithInteger:difficulty]
                        forKey:@"difficulty"];
    [[settings dict] setObject:[NSNumber numberWithBool:enable_timed]
                        forKey:@"timed"];
    [[settings dict] setObject:[NSNumber numberWithBool:NO]
                        forKey:@"newRecord"];
    [[settings dict] setObject:[NSNumber numberWithBool:YES]
                        forKey:@"loseScreen"];
    GameScene *scene = (GameScene*)[SKScene nodeWithFileNamed:@"GameScene"];
    [[self view] presentScene:scene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
  }
}

-(void)touchMovedToPoint:(CGPoint)pos {
}

-(void)touchUpAtPoint:(CGPoint)pos {
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
