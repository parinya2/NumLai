//
//  NumNaoIAPHelper.h
//  NumNao
//
//  Created by PRINYA on 8/7/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "IAPHelper.h"

@interface NumLaiIAPHelper : IAPHelper

@property (strong, nonatomic) NSArray *productIdentifiers;
@property (assign, nonatomic, getter = isQuizMode2Purchased) BOOL quizMode2Purchased;
@property (assign, nonatomic, getter = isQuizMode3Purchased) BOOL quizMode3Purchased;
@property (assign, nonatomic, getter = isQuizMode4Purchased) BOOL quizMode4Purchased;

+ (NumLaiIAPHelper *)sharedInstance;

@end
