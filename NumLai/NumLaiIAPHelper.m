//
//  NumNaoIAPHelper.m
//  NumNao
//
//  Created by PRINYA on 8/7/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "NumLaiIAPHelper.h"

@implementation NumLaiIAPHelper
@synthesize retroCh3Purchased = _retroCh3Purchased;
@synthesize retroCh5Purchased = _retroCh5Purchased;
@synthesize retroCh7Purchased = _retroCh7Purchased;

+ (NumLaiIAPHelper *)sharedInstance {
  static dispatch_once_t once;
  static NumLaiIAPHelper *sharedInstance;
  dispatch_once(&once, ^{
    NSArray *productsArray = [NSArray arrayWithObjects:
                              @"com.thechappters.NumNao.retroch3",
                              @"com.thechappters.NumNao.retroch5",
                              @"com.thechappters.NumNao.retroch7",
                              nil];
    NSSet *productIdentifiers = [NSSet setWithArray:productsArray];
    sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    sharedInstance->_productIdentifiers = productsArray;
  });
  return sharedInstance;
}

- (void)setRetroCh3Purchased:(BOOL)flag {
  if (flag) {
    [self provideContentForProductIdentifier:self.productIdentifiers[0] fireNotification:YES];
  }
  self->_retroCh3Purchased = flag;
}

- (BOOL)isRetroCh3Purchased {
  BOOL flag = [self productPurchased:self.productIdentifiers[0]];
  self->_retroCh3Purchased = flag;
  return self->_retroCh3Purchased;
}

- (void)setRetroCh5Purchased:(BOOL)flag {
  if (flag) {
    [self provideContentForProductIdentifier:self.productIdentifiers[1] fireNotification:YES];
  }
  self->_retroCh5Purchased = flag;
}

- (BOOL)isRetroCh5Purchased {
  BOOL flag = [self productPurchased:self.productIdentifiers[1]];
  self->_retroCh5Purchased = flag;
  return self->_retroCh5Purchased;
}

- (void)setRetroCh7Purchased:(BOOL)flag {
  if (flag) {
    [self provideContentForProductIdentifier:self.productIdentifiers[2] fireNotification:YES];
  }
  self->_retroCh7Purchased = flag;
}

- (BOOL)isRetroCh7Purchased {
  BOOL flag = [self productPurchased:self.productIdentifiers[2]];
  self->_retroCh7Purchased = flag;
  return self->_retroCh7Purchased;
}
@end
