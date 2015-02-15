//
//  QuizObject.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuizObject : NSObject

@property (strong) NSString *quizText;
@property (strong) NSString *ansChoice1;
@property (strong) NSString *ansChoice2;
@property (strong) NSString *ansChoice3;
@property (strong) NSString *ansChoice4;
@property NSInteger answerIndex;
@property NSInteger quizLevel;

- (QuizObject *)initWithQuizText:(NSString *)quizText
                      ansChoice1:(NSString *)choice1
                      ansChoice2:(NSString *)choice2
                      ansChoice3:(NSString *)choice3
                      ansChoice4:(NSString *)choice4
                     answerIndex:(NSInteger) index
                       quizLevel:(NSInteger) quizLevel;
- (QuizObject *)copyQuiz;
@end
