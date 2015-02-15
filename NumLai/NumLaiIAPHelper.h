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
@property (assign, nonatomic, getter = isRetroCh3Purchased) BOOL retroCh3Purchased;
@property (assign, nonatomic, getter = isRetroCh5Purchased) BOOL retroCh5Purchased;
@property (assign, nonatomic, getter = isRetroCh7Purchased) BOOL retroCh7Purchased;

+ (NumLaiIAPHelper *)sharedInstance;

@end
