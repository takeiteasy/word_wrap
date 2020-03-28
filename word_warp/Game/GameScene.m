//
//  GameScene.m
//  word_warp
//
//  Created by Rory B. Bellows on 24/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import "GameScene.h"
#include "Words.h"
#import "MenuScene.h"
#import "LoseScene.h"

@implementation GameScene
-(NSInteger)rdnIntMin:(NSInteger)min andMax:(NSInteger)max {
  return rand() % (max + 1 - min) + min;
}

-(NSRange)rndRangeWithMin:(int)min andMax:(int)max {
  return word_ranges[[self rdnIntMin:min - 3
                              andMax:max - 3]];
}

-(CGFloat)rndColor {
  return (CGFloat)rand() / (CGFloat)RAND_MAX;
}

-(NSMutableArray*)splitString:(NSString*)word {
  NSMutableArray *chars = [[NSMutableArray alloc] init];
  for (NSInteger i = 0; i < [word length]; ++i)
    [chars addObject:[word substringWithRange:NSMakeRange(i, 1)]];
  return chars;
}

-(NSMutableArray*)findAnagrams:(NSMutableArray*)chars maxRnage:(NSInteger)n {
  NSMutableArray *ret = [[NSMutableArray alloc] init];
  for (NSInteger i = 0; i < n; ++i) {
    NSString *word = [NSString stringWithUTF8String:words_list[i]];
    NSMutableArray *word_chars = [self splitString:word];
    NSMutableArray *chars_copy = [NSMutableArray arrayWithArray:chars];
    bool valid = true;
    for (NSInteger j = 0; j < [word_chars count]; ++j) {
      NSInteger idx = -1;
      for (NSInteger k = 0; k < [chars_copy count]; ++k)
        if ([chars_copy[k] characterAtIndex:0] == [word_chars[j] characterAtIndex:0]) {
          idx = k;
          break;
        }
      if (idx == -1) {
        valid = false;
        break;
      }
      [chars_copy removeObjectAtIndex:idx];
    }
    if (valid)
      [ret addObject:word];
  }
  return ret;
}

-(void)addNextBtn {
  if (level_passed)
    return;
  
  NSInteger difficulty_rel = difficulty - 1;
  switch (difficulty_rel) {
    default:
    case 0:
      incrementScore(@"total_easy_rounds");
      break;
    case 1:
      incrementScore(@"total_normal_rounds");
      break;
    case 2:
      incrementScore(@"total_hard_rounds");
      break;
  }
  
  NSInteger round_number_rel = round_number + 1;
  if (timed_game)
    switch (difficulty_rel) {
      default:
      case 0:
        setScoreIfGreater(@"easy_timed_streak", round_number_rel);
        break;
      case 1:
        setScoreIfGreater(@"normal_timed_streak", round_number_rel);
        break;
      case 2:
        setScoreIfGreater(@"hard_timed_streak", round_number_rel);
        break;
    }
  else {
    BOOL record = NO;
    switch (difficulty_rel) {
      default:
      case 0:
        record = setScoreIfGreater(@"easy_rounds_streak", round_number_rel);
        break;
      case 1:
        record = setScoreIfGreater(@"normal_rounds_streak", round_number_rel);
        break;
      case 2:
        record = setScoreIfGreater(@"hard_rounds_streak", round_number_rel);
        break;
    }
    if (record)
      [[settings dict] setObject:[NSNumber numberWithBool:YES] forKey:@"newRecord"];
  }
  
  level_passed = YES;
  [next addObjects:self];
  SKAction *grow = [SKAction scaleTo:0.9
                            duration:0.5];
  SKAction *reset = [SKAction scaleTo:1
                             duration:0.5];
  SKAction *shrink = [SKAction scaleTo:1.1
                              duration:0.5];
  [[next getShapeNode] runAction:[SKAction repeatActionForever:[SKAction sequence:@[grow, reset, shrink, reset]]]];
  
  SKAction *move_up = [SKAction moveByX:0
                                      y:10
                               duration:0.2];
  SKAction *move_down = [SKAction moveByX:0
                                        y:-10
                                 duration:0.2];
  SKAction *delay = [SKAction waitForDuration:2.0];
  [flag runAction:[SKAction repeatActionForever:[SKAction sequence:@[move_up, move_down, move_up, move_down, move_up, move_down, delay]]]];
}

-(NSString*)gameTimerString {
  return [NSString stringWithFormat:@"%02ld:%02ld", (NSInteger)floorf((float)game_timer / 60.f), game_timer % 60];
}

-(void)shuffle:(NSMutableArray*)array {
  for (NSInteger i = [array count] - 1; i >= 0; --i)
    [array exchangeObjectAtIndex:i
               withObjectAtIndex:(random() % ([array count] - i) + i)];
}

-(void)didMoveToView:(SKView *)view {
  settings = [GameSettings sharedSettings];
  if (![[settings dict] objectForKey:@"firstGame"]) {
    srand((unsigned int)time(NULL));
    [[settings dict] setObject:@"" forKey:@"firstGame"];
  }
  
  NSRange range;
  switch ((difficulty = [[[settings dict] objectForKey:@"difficulty"] integerValue])) {
    default:
    case 0:
      range = [self rndRangeWithMin:4
                             andMax:5];
      break;
    case 1:
      range = [self rndRangeWithMin:4
                             andMax:6];
      break;
    case 2:
      range = [self rndRangeWithMin:6
                             andMax:9];
      break;
  }
  difficulty += 1;
  timed_game = [[[settings dict] objectForKey:@"timed"] boolValue];
  
  NSString *word = [NSString stringWithUTF8String:words_list[[self rdnIntMin:(NSInteger)range.location
                                                                      andMax:(NSInteger)range.length]]];
  NSMutableArray *chars = [self splitString:word];
  [self shuffle:chars];
  anagrams = [self findAnagrams:chars
                       maxRnage:range.length];
  found_words = [[NSMutableArray alloc] init];
  max_score = 0;
  [anagrams enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
    max_score += [obj length];
  }];
  min_score = max_score * 0.33333f;
  score = 0;
  
  CGFloat w2 = [self size].width / 2, h2 = [self size].height / 2;
  left = w2;
  right = -w2;
  top = h2;
  bottom = -h2;
  
  SKColor *bg_color = [SKColor colorWithRed:0.95
                                      green:0.95
                                       blue:0.95
                                      alpha:1.0];
  [self setBackgroundColor:bg_color];
  
  SKColor *red_border = [SKColor colorWithRed:0.98
                                        green:0.42
                                         blue:0.52
                                        alpha:1.0];
  SKColor *red_fill = [SKColor colorWithRed:0.98
                                      green:0.55
                                       blue:0.67
                                      alpha:1.0];
  SKColor *black_border = [SKColor colorWithRed:0.8
                                          green:0.8
                                           blue:0.8
                                          alpha:1.0];
  SKColor *black_fill = [SKColor colorWithRed:0.90
                                        green:0.90
                                         blue:0.90
                                        alpha:1.0];
  
  quit_btn = [SKSpriteNode spriteNodeWithImageNamed:@"quit_btn"];
  quit_btn.position = CGPointMake(w2 - 35, h2 - 35);
  [self addChild:quit_btn];
  
  flag = [SKSpriteNode spriteNodeWithImageNamed:@"flag"];
  // ((float)min_score / (float)max_score) * [self size].width
  flag.position = CGPointMake(-w2 + ([self size].width * 0.33333f), -h2 + [flag size].width / 2);
  [self addChild:flag];
  
  progress = [SKShapeNode shapeNodeWithRect:CGRectMake(-[self size].width - w2, -h2 - 2, [self size].width, 5)];
  progress.strokeColor = red_border;
  progress.fillColor = red_fill;
  [self addChild:progress];
  
  bg_music = [[SKAudioNode alloc] initWithFileNamed:@"bg.caf"];
  [bg_music setAutoplayLooped:YES];
  [bg_music runAction:[SKAction changeVolumeTo:0.1
                                      duration:0.0]];
  [self addChild:bg_music];
  
  round_number = [[settings dict] objectForKey:@"roundNumber"] ? [[[settings dict] objectForKey:@"roundNumber"] integerValue] : 0;
  round_number_lbl = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"Round: %ld", round_number]];
  round_number_lbl.position = CGPointMake(-w2 + ([round_number_lbl frame].size.width / 2) + 10, h2 - ([round_number_lbl frame].size.height * 2) + 5);
  round_number_lbl.fontColor = [SKColor grayColor];
  [self addChild:round_number_lbl];
  
  if (timed_game) {
    game_timer = [[settings dict] objectForKey:@"gameTimer"] ? [[[settings dict] objectForKey:@"gameTimer"] integerValue] : difficulty * 60;
    game_timer_warning = NO;
    time_lbl = [SKLabelNode labelNodeWithText:[self gameTimerString]];
    time_lbl.fontColor = [SKColor blackColor];
    time_lbl.position = CGPointMake(0, -h2 + [time_lbl frame].size.height + 100);
    [self addChild:time_lbl];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                      [SKAction runBlock:^{
                        self->game_timer -= 1;
                        [self->time_lbl setText:[self gameTimerString]];
                        if (self->game_timer <= 0) {
                          [self removeActionForKey:@"timer"];
                          [self->time_lbl setText:@"00:00"];
                          [self runAction:[SKAction playSoundFileNamed:@"lose.caf"
                                                     waitForCompletion:NO] completion:^{
                            LoseScene *scene = (LoseScene*)[SKScene nodeWithFileNamed:@"LoseScene"];
                            [[self view] presentScene:scene transition:[SKTransition doorsCloseVerticalWithDuration:1.0]];
                          }];
                        } else if (self->game_timer <= 60) {
                          if (!self->game_timer_warning) {
                            self->game_timer_warning = YES;
                            self->time_lbl.fontColor = [SKColor redColor];
                            SKAction *grow = [SKAction scaleTo:0.9
                                                      duration:0.5];
                            SKAction *reset = [SKAction scaleTo:1
                                                       duration:0.5];
                            SKAction *shrink = [SKAction scaleTo:1.1
                                                        duration:0.5];
                            [self->time_lbl runAction:[SKAction repeatActionForever:[SKAction sequence:@[grow, reset, shrink]]]
                                              withKey:@"timerWarning"];
                          }
                          
                        } else {
                          if (self->game_timer_warning) {
                            self->game_timer_warning = NO;
                            self->time_lbl.fontColor = [SKColor blackColor];
                            [self->time_lbl removeActionForKey:@"timerWarning"];
                            [self->time_lbl runAction:[SKAction scaleTo:1
                                                               duration:0.5]];
                          }
                        }
                      }],
                      [SKAction waitForDuration:1.0]
                    ]]]
            withKey:@"timer"];
  }
  
  SKShapeNode *btn_template = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w2 - 40, [self size].height * 0.05)];
  btn_template.strokeColor = red_border;
  btn_template.fillColor = red_fill;
  CGFloat btn_y = -h2 + ([self size].height * 0.2);
  clear = [[Button alloc] initWithBox:btn_template
                          andPosition:CGPointMake(20 + [btn_template frame].size.width / 2, btn_y)
                              andChar:@"CLEAR"];
  [clear addObjects:self];
  twist = [[Button alloc] initWithBox:btn_template
                          andPosition:CGPointMake(-w2 + (20 + [btn_template frame].size.width / 2), btn_y)
                              andChar:@"TWIST"];
  [twist addObjects:self];
  next = [[Button alloc] initWithBox:btn_template
                         andPosition:CGPointMake(0, h2 / 2)
                             andChar:@"NEXT"];
  
  remaining_lbl = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%ld remaining!", [anagrams count]]];
  remaining_lbl.fontColor = [SKColor blackColor];
  remaining_lbl.position = CGPointMake(0, -h2 / 2);
  remaining_lbl.fontSize = 36;
  [self addChild:remaining_lbl];
  SKAction *grow = [SKAction scaleTo:0.9
                            duration:0.5];
  SKAction *reset = [SKAction scaleTo:1
                             duration:0.5];
  SKAction *shrink = [SKAction scaleTo:1.1
                              duration:0.5];
  [remaining_lbl runAction:[SKAction repeatActionForever:[SKAction sequence:@[grow, reset, shrink, reset]]]];
  
  score_lbl = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"SCORE: %ld/%ld/%ld", score, min_score, max_score]];
  score_lbl.fontColor = [SKColor blackColor];
  score_lbl.fontSize = 24;
  score_lbl.position = CGPointMake(0, -(h2 - 10));
  [self addChild:score_lbl];
  
  NSLog(@"POSSIBLE WORDS:");
  [anagrams enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
    NSLog(@"%@", str);
  }];
  
  NSInteger n_letters = longest_word = [chars count];
  NSInteger padding = 20;
  NSInteger padding_half = padding / 2;
  NSInteger box_w = letter_size = ([self size].width - padding * n_letters) / n_letters;
  NSInteger box_w_half = box_w / 2;
  bottom_row_y = -box_w_half - padding_half;
  top_row_y = box_w_half + padding_half;
  
  box = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(box_w, box_w)
                                cornerRadius:box_w * .05f];
  box.fillColor = red_fill;
  box.strokeColor = red_border;
  
  boxes = [[NSMutableArray alloc] init];
  selected_row = [[NSMutableArray alloc] init];
  unselected_row = [[NSMutableArray alloc] init];
  xpositions = [[NSMutableArray alloc] init];
  
  NSInteger xoff = -w2 + box_w_half + padding_half;
  for (NSInteger i = 0; i < n_letters; ++i) {
    [xpositions addObject:[NSNumber numberWithInteger:xoff]];
    
    CGPoint obj_pos = CGPointMake(xoff, bottom_row_y);
    Button *obj = [[Button alloc] initWithBox:box
                                  andPosition:obj_pos
                                      andChar:chars[i]];
    [obj addObjects:self];
    [boxes addObject:obj];
    [unselected_row addObject:obj];
    
    SKShapeNode *a = [box copy];
    a.position = CGPointMake(xoff, top_row_y);
    a.strokeColor = black_border;
    a.fillColor = black_fill;
    [self addChild:a];
    
    SKShapeNode *b = [a copy];
    b.position = obj_pos;
    [self addChild:b];
    
    xoff += box_w + padding;
  }
  
  level_passed = win_played = NO;
}

-(void)touchDownAtPoint:(CGPoint)pos {
  if ([quit_btn containsPoint:pos]) {
    [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                               waitForCompletion:NO]];
    MenuScene *scene = (MenuScene*)[SKScene nodeWithFileNamed:@"MenuScene"];
    [[self view] presentScene:scene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
  }
  
  if ([clear containsPoint:pos]) {
    [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                               waitForCompletion:NO]];
    SKAction *move_back = [SKAction moveBy:CGVectorMake(-5, 5)
                                  duration:0.05];
    SKAction *move_fwd = [SKAction moveBy:CGVectorMake(5, -5)
                                 duration:0.05];
    [clear runAction:[SKAction sequence:@[move_back, move_fwd]]];
    
    [boxes enumerateObjectsUsingBlock:^(Button *obj, NSUInteger idx, BOOL *stop) {
      if (![obj isSelected])
        return;
      NSUInteger obj_idx = [selected_row indexOfObject:obj];
      NSUInteger to_idx = [unselected_row count];
      [obj moveTo:CGPointMake([[xpositions objectAtIndex:to_idx] integerValue], bottom_row_y)];
      [obj setSelected:NO];
      [selected_row removeObjectAtIndex:obj_idx];
      [unselected_row addObject:obj];
    }];
    return;
  }
  
  if ([twist containsPoint:pos]) {
    [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                               waitForCompletion:NO]];
    SKAction *move_back = [SKAction moveBy:CGVectorMake(-5, 5)
                                  duration:0.05];
    SKAction *move_fwd = [SKAction moveBy:CGVectorMake(5, -5)
                                 duration:0.05];
    [twist runAction:[SKAction sequence:@[move_back, move_fwd]]];
    
    [self shuffle:unselected_row];
    [unselected_row enumerateObjectsUsingBlock:^(Button *obj, NSUInteger idx, BOOL *stop) {
      [obj moveTo:CGPointMake([[xpositions objectAtIndex:idx] integerValue], bottom_row_y)];
    }];
    return;
  }
  
  if (level_passed && [next containsPoint:pos]) {
    [self runAction:[SKAction playSoundFileNamed:@"switch.caf"
                               waitForCompletion:NO]];
    SKAction *move_back = [SKAction moveBy:CGVectorMake(-5, 5)
                                  duration:0.05];
    SKAction *move_fwd = [SKAction moveBy:CGVectorMake(5, -5)
                                 duration:0.05];
    [next runAction:[SKAction sequence:@[move_back, move_fwd]]];
    
    [[settings dict] setObject:[NSNumber numberWithInteger:round_number + 1] forKey:@"roundNumber"];
    if (timed_game)
      [[settings dict] setValue:[NSNumber numberWithInteger:game_timer] forKey:@"gameTimer"];
    GameScene *scene = (GameScene*)[SKScene nodeWithFileNamed:@"GameScene"];
    [[self view] presentScene:scene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
    return;
  }
  
  [boxes enumerateObjectsUsingBlock:^(Button *obj, NSUInteger idx, BOOL *stop) {
    if (![obj containsPoint:pos])
      return;
    if ([obj isActionRunning]) {
      *stop = YES;
      return;
    }
    [self runAction:[SKAction playSoundFileNamed:@"click.caf"
                               waitForCompletion:NO]];
    
    NSMutableArray *to = nil, *from = nil;
    NSInteger to_y = 0, from_y = 0;
    if ([obj isSelected]) {
      to = unselected_row;
      from = selected_row;
      to_y = bottom_row_y;
      from_y = top_row_y;
    } else {
      to = selected_row;
      from = unselected_row;
      to_y = top_row_y;
      from_y = bottom_row_y;
    }
    
    NSUInteger obj_idx = [from indexOfObject:obj];
    NSUInteger to_idx = [to count];
    [obj moveTo:CGPointMake([[xpositions objectAtIndex:to_idx] integerValue], to_y)];
    [obj setSelected:![obj isSelected]];
    [from removeObjectAtIndex:obj_idx];
    [to addObject:obj];
    for (NSUInteger i = obj_idx; i < [from count]; ++i)
      [from[i] moveTo:CGPointMake([[xpositions objectAtIndex:i] integerValue], from_y)];
    
    selected = @"";
    for (NSUInteger i = 0; i < [selected_row count]; ++i)
      selected = [selected stringByAppendingString:[selected_row[i] string]];
    
    NSUInteger found_match_idx = [found_words indexOfObject:selected];
    if (found_match_idx != NSNotFound) {
      [self runAction:[SKAction playSoundFileNamed:@"error.caf"
                                 waitForCompletion:YES]];
       
      SKLabelNode *found_word_lbl = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"\"%@\" already found!", selected]];
      found_word_lbl.position = CGPointMake(0, bottom - 100);
      found_word_lbl.alpha = 0.0;
      found_word_lbl.fontColor = [SKColor blackColor];
      [self addChild:found_word_lbl];
      
      SKAction *fade_in = [SKAction fadeInWithDuration:0.3];
      SKAction *move_to = [SKAction moveTo:CGPointMake(0, bottom + letter_size / 2)
                                  duration:0.3];
      SKAction *fade_out = [SKAction fadeOutWithDuration:0.3];
      SKAction *delay = [SKAction waitForDuration:1.0];
      SKAction *remove_lbl = [SKAction removeFromParent];
      [found_word_lbl runAction:fade_in];
      [found_word_lbl runAction:[SKAction sequence:@[move_to, delay, fade_out, remove_lbl]]];
      
      *stop = YES;
      return;
    }
    
    NSUInteger match_idx = [anagrams indexOfObject:selected];
    if (match_idx == NSNotFound) {
      *stop = YES;
      return;
    }
    
    switch (difficulty - 1) {
      default:
      case 0:
        incrementScore(@"total_words_easy");
        break;
      case 1:
        incrementScore(@"total_words_normal");
        break;
      case 2:
        incrementScore(@"total_words_hard");
        break;
    }
    
    if ([selected length] >= [[[settings scores] objectForKey:@"longest_word"] length]) {
      [[settings dict] setObject:[NSNumber numberWithBool:YES] forKey:@"newRecord"];
      [[settings scores] setObject:selected
                            forKey:@"longest_word"];
      [[NSUserDefaults standardUserDefaults] setObject:selected
                                                forKey:@"longest_word"];
    }
    
    [found_words addObject:selected];
    NSInteger add_score = [selected length] * difficulty;
    score += add_score;
    if (timed_game)
      game_timer += add_score + 1;
    [anagrams removeObjectAtIndex:match_idx];
    NSTimeInterval __block delay_n = 0.0;
    [selected_row enumerateObjectsUsingBlock:^(Button *obj, NSUInteger idx, BOOL *stop) {
      SKAction *wait = [SKAction waitForDuration:delay_n];
      SKAction *move_up = [SKAction moveByX:0
                                          y:10
                                   duration:0.2];
      SKAction *move_down = [SKAction moveByX:0
                                            y:-10
                                     duration:0.2];
      delay_n += 0.2;
      [obj runAction:[SKAction sequence:@[wait, move_up, move_down]]];
    }];
    [progress runAction:[SKAction moveByX:([selected length] / (float)max_score) * [self size].width
                                        y:0
                                 duration:0.1]];
    
    [remaining_lbl setText:[NSString stringWithFormat:@"%ld remaining!", [anagrams count]]];
    [score_lbl setText:[NSString stringWithFormat:@"SCORE: %ld/%ld/%ld", score, min_score, max_score]];
    
    SKLabelNode *score_lbl = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"+%ld", add_score]];
    score_lbl.position = CGPointMake(0, bottom - 100);
    score_lbl.alpha = 0.0;
    score_lbl.fontColor = [SKColor blackColor];
    [self addChild:score_lbl];
    SKAction *fade_in = [SKAction fadeInWithDuration:0.3];
    SKAction *move_to = [SKAction moveTo:CGPointMake(0, bottom + letter_size / 2)
                                duration:0.3];
    SKAction *fade_out = [SKAction fadeOutWithDuration:0.3];
    SKAction *delay = [SKAction waitForDuration:0.5];
    SKAction *remove_lbl = [SKAction removeFromParent];
    [score_lbl runAction:fade_in];
    [score_lbl runAction:[SKAction sequence:@[move_to, delay, fade_out, remove_lbl]]];
    
    SKLabelNode *found_lbl = [SKLabelNode labelNodeWithText:selected];
    found_lbl.position = CGPointMake(0, bottom - 100);
    found_lbl.alpha = 0.0;
    found_lbl.fontColor = [SKColor colorWithRed:[self rndColor]
                                          green:[self rndColor]
                                           blue:[self rndColor]
                                          alpha:1.0];
    [self addChild:found_lbl];
    [found_lbl runAction:[SKAction fadeInWithDuration:0.2]];
    [found_lbl runAction:[SKAction moveTo:CGPointMake([self rdnIntMin:self->right + letter_size andMax:self->left - letter_size], [self rdnIntMin:self->letter_size + letter_size andMax:self->top - letter_size])
                                 duration:0.2]];
    [found_lbl runAction:[SKAction rotateByAngle:[self rdnIntMin:0 andMax:360] * (M_PI / 180)
                                        duration:0.2]];
    
    [self runAction:[SKAction playSoundFileNamed:@"success.caf"
                               waitForCompletion:NO]];
    
    if ([selected length] == longest_word || ![anagrams count]) {
      [self runAction:[SKAction playSoundFileNamed:@"wow.caf"
                                 waitForCompletion:NO]];
      [self addNextBtn];
    }
    
    if (score >= min_score && !win_played) {
      [bg_music removeFromParent];
      [self runAction:[SKAction playSoundFileNamed:@"win.caf"
                                 waitForCompletion:YES]
           completion:^{
        [self addChild:self->bg_music];
      }];
      win_played = YES;
      [self addNextBtn];
    }
    
    *stop = YES;
  }];
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
