//
//  GameViewController.m
//  word_warp
//
//  Created by Rory B. Bellows on 24/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import "GameViewController.h"
#import "MenuScene.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Load the SKScene from 'GameScene.sks'
  //GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];
  MenuScene *scene = (MenuScene *)[SKScene nodeWithFileNamed:@"MenuScene"];
  
  // Set the scale mode to scale to fit the window
  scene.scaleMode = SKSceneScaleModeAspectFill;
  
  SKView *skView = (SKView *)self.view;
  
  // Present the scene
  [skView presentScene:scene];
  
  //skView.showsFPS = YES;
  //skView.showsNodeCount = YES;
}

- (BOOL)shouldAutorotate {
  return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
