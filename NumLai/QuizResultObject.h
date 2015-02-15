//
//  QuizResultObject.h
//  NumNao
//
//  Created by PRINYA on 9/1/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuizResultObject : NSObject

@property (assign, nonatomic) NSInteger scoreFrom;
@property (assign, nonatomic) NSInteger scoreTo;
@property (strong, nonatomic) NSString *resultText;

- (BOOL)matchForScore:(NSInteger)score;

@end
