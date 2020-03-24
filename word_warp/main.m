//
//  main.m
//  word_warp
//
//  Created by Rory B. Bellows on 24/03/2020.
//  Copyright © 2020 Rory B. Bellows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
  NSString * appDelegateClassName;
  @autoreleasepool {
      // Setup code that might create autoreleased objects goes here.
      appDelegateClassName = NSStringFromClass([AppDelegate class]);
  }
  return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
