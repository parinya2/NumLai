//
//  NumNaoIAPHelper.m
//  NumNao
//
//  Created by PRINYA on 8/7/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "NumLaiIAPHelper.h"

@implementation NumLaiIAPHelper
@synthesize quizMode2Purchased = _quizMode2Purchased;
@synthesize quizMode3Purchased = _quizMode3Purchased;
@synthesize quizMode4Purchased = _quizMode4Purchased;

+ (NumLaiIAPHelper *)sharedInstance {
  static dispatch_once_t once;
  static NumLaiIAPHelper *sharedInstance;
  dispatch_once(&once, ^{
    NSArray *productsArray = [NSArray arrayWithObjects:
                              @"com.thechappters.NumLai.quizMode2",
                              @"com.thechappters.NumLai.quizMode3",
                              @"com.thechappters.NumLai.quizMode4",
                              nil];
    NSSet *productIdentifiers = [NSSet setWithArray:productsArray];
    sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    sharedInstance->_productIdentifiers = productsArray;
  });
  return sharedInstance;
}

- (void)setQuizMode2Purchased:(BOOL)flag {
  if (flag) {
    [self provideContentForProductIdentifier:self.productIdentifiers[0] fireNotification:YES];
  }
  self->_quizMode2Purchased = flag;
}

- (BOOL)isQuizMode2Purchased {
  BOOL flag = [self productPurchased:self.productIdentifiers[0]];
  self->_quizMode2Purchased = flag;
  return self->_quizMode2Purchased;
}

- (void)setQuizMode3Purchased:(BOOL)flag {
  if (flag) {
    [self provideContentForProductIdentifier:self.productIdentifiers[1] fireNotification:YES];
  }
  self->_quizMode3Purchased = flag;
}

- (BOOL)isQuizMode3Purchased {
  BOOL flag = [self productPurchased:self.productIdentifiers[1]];
  self->_quizMode3Purchased = flag;
  return self->_quizMode3Purchased;
}

- (void)setQuizMode4Purchased:(BOOL)flag {
  if (flag) {
    [self provideContentForProductIdentifier:self.productIdentifiers[2] fireNotification:YES];
  }
  self->_quizMode4Purchased = flag;
}

- (BOOL)isQuizMode4Purchased {
  BOOL flag = [self productPurchased:self.productIdentifiers[2]];
  self->_quizMode4Purchased = flag;
  return self->_quizMode4Purchased;
}
@end
