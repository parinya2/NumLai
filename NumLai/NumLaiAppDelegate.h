//
//  AppDelegate.h
//  FBShareSample
//
//  Created by PRINYA on 6/17/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "QuizResultController.h"

@interface NumLaiAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) QuizResultController *quizResultController;
@property (strong, nonatomic) NSDictionary *refererAppLink;

@end
