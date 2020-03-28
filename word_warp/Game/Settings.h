//
//  Settings.h
//  word_warp
//
//  Created by Rory B. Bellows on 27/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettings : NSObject {
  NSMutableDictionary *dict, *scores;
}
@property (nonatomic, retain) NSMutableDictionary *dict;
@property (nonatomic, retain) NSMutableDictionary *scores;
+(id)sharedSettings;
@end

void updateUserSettings(void);
void setScore(NSString *key, NSInteger val);
void incrementScore(NSString *key);
BOOL setScoreIfGreater(NSString *key, NSInteger val);
