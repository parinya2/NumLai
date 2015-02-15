//
//  QuizRankObject.h
//  NumNao
//
//  Created by PRINYA on 11/30/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuizRankObject : NSObject

@property (assign, nonatomic) NSInteger rankNo;
@property (assign, nonatomic) NSInteger quizMode;
@property (assign, nonatomic) NSInteger score;
@property (assign, nonatomic) BOOL isActivePlayer;
@property (strong, nonatomic) NSString *playerName;
@property (strong, nonatomic) NSString *deviceOS;

@end
