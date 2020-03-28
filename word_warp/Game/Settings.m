//
//  Settings.m
//  word_warp
//
//  Created by Rory B. Bellows on 27/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import "Settings.h"

@implementation GameSettings
@synthesize dict;
@synthesize scores;

+(id)sharedSettings {
  static GameSettings *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

-(id)init {
  if (self = [super init]) {
    dict = [[NSMutableDictionary alloc] init];
    scores = [[NSMutableDictionary alloc] init];
  }
  return self;
}
@end

void updateUserSettings() {
  GameSettings *settings = [GameSettings sharedSettings];
  [[settings scores] enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
  }];
}

void setScore(NSString *key, NSInteger val) {
  GameSettings *settings = [GameSettings sharedSettings];
  NSNumber *number = [NSNumber numberWithInteger:val];
  [[settings scores] setObject:number
                        forKey:key];
  [[NSUserDefaults standardUserDefaults] setObject:number forKey:key];
}

void incrementScore(NSString *key) {
  setScore(key, [[[[GameSettings sharedSettings] scores] objectForKey:key] integerValue] + 1);
}

BOOL setScoreIfGreater(NSString *key, NSInteger val) {
  if (val > [[[[GameSettings sharedSettings] scores] objectForKey:key] integerValue]) {
    setScore(key, val);
    return YES;
  }
  return NO;
}
