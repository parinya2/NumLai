//
//  QuizObject.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizObject.h"

@implementation QuizObject

- (QuizObject *)initWithQuizText:(NSString *)quizText
                      ansChoice1:(NSString *)choice1
                      ansChoice2:(NSString *)choice2
                      ansChoice3:(NSString *)choice3
                      ansChoice4:(NSString *)choice4
                     answerIndex:(NSInteger)index
                       quizLevel:(NSInteger)quizLevel {
  self = [super init];
  if (self) {
    self.quizText = quizText;
    self.ansChoice1 = choice1;
    self.ansChoice2 = choice2;
    self.ansChoice3 = choice3;
    self.ansChoice4 = choice4;
    self.answerIndex = index;
    self.quizLevel = quizLevel;
  }
  return self;
}

- (QuizObject *)copyQuiz {
  QuizObject *newQuiz = [[QuizObject alloc] initWithQuizText:self.quizText
                                                  ansChoice1:self.ansChoice1
                                                  ansChoice2:self.ansChoice2
                                                  ansChoice3:self.ansChoice3
                                                  ansChoice4:self.ansChoice4
                                                 answerIndex:self.answerIndex
                                                   quizLevel:self.quizLevel];
  return newQuiz;
}
@end
