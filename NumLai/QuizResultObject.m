//
//  QuizResultObject.m
//  NumNao
//
//  Created by PRINYA on 9/1/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizResultObject.h"

@implementation QuizResultObject

- (BOOL)matchForScore:(NSInteger)score {
  if (score >= self.scoreFrom && score <= self.scoreTo) {
    return YES;
  } else {
    return NO;
  }
}

@end
