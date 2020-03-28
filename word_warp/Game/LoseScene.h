//
//  LoseScene.h
//  word_warp
//
//  Created by Rory B. Bellows on 28/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Button.h"
#import "Settings.h"

@interface LoseScene : SKScene {
  SKSpriteNode *title;
  Button *menu_btn;
  GameSettings *settings;
}
@end
