//
//  GameScene.h
//  word_warp
//
//  Created by Rory B. Bellows on 24/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Button.h"
#import "Settings.h"

@interface GameScene : SKScene {
  SKShapeNode *box;
  NSMutableArray *boxes, *xpositions, *selected_row, *unselected_row;
  NSInteger top_row_y, bottom_row_y;
  NSString *selected;
  NSMutableArray *anagrams, *found_words;
  NSInteger longest_word, max_score, min_score, score;
  SKSpriteNode *flag;
  SKShapeNode *progress;
  Button *clear, *twist, *next;
  CGFloat left, right, top, bottom;
  CGFloat letter_size;
  SKAudioNode *bg_music;
  SKLabelNode *remaining_lbl, *score_lbl, *time_lbl;
  SKSpriteNode *quit_btn;
  NSInteger difficulty, round_number;
  SKLabelNode *round_number_lbl;
  BOOL timed_game, level_passed, win_played;
  NSInteger game_timer;
  BOOL game_timer_warning;
  GameSettings* settings;
}
@end
