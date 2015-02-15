//
//  IAPHelper.m
//  NumNao
//
//  Created by PRINYA on 8/6/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

NSString * const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString * const IAPHelperProductRestoredNotification = @"IAPHelperProductRestoredNotification";
NSString * const IAPHelperProductPurchasedFailedNotification = @"IAPHelperProductPurchasedFailedNotification";
NSString * const IAPHelperProductRestoredFailedNotification = @"IAPHelperProductRestoredFailedNotification";
NSString * const RetroCh3ProductPurchasedKey = @"QPRKJFJ";
NSString * const RetroCh5ProductPurchasedKey = @"MDJVKEO";
NSString * const RetroCh7ProductPurchasedKey = @"PPVIDUS";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper {
  
  SKProductsRequest *_productsRequest;
  
  RequestProductWithCompletinoHandler _completionHandler;
  NSSet *_productIdentifiers;
  NSMutableSet *_purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
  self = [super init];
  if (self) {
    _productIdentifiers = productIdentifiers;
    
    _purchasedProductIdentifiers = [NSMutableSet set];
    for (NSString *productIdentifier in _productIdentifiers) {
      
      NSString *productPurchasedKey = @"";
      if ([productIdentifier rangeOfString:@"retroch3"].location != NSNotFound) {
        productPurchasedKey = RetroCh3ProductPurchasedKey;
      } else if ([productIdentifier rangeOfString:@"retroch5"].location != NSNotFound) {
        productPurchasedKey = RetroCh5ProductPurchasedKey;
      } else if ([productIdentifier rangeOfString:@"retroch7"].location != NSNotFound) {
        productPurchasedKey = RetroCh7ProductPurchasedKey;
      }
      NSString *currentPurchasedKey = [[NSUserDefaults standardUserDefaults]
                                       stringForKey:productIdentifier];
      BOOL productPurchased = [currentPurchasedKey isEqualToString:productPurchasedKey];
      if (productPurchased) {
        [_purchasedProductIdentifiers addObject:productIdentifier];
      }
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductWithCompletinoHandler)completionHandler {
  _completionHandler = [completionHandler copy];
  
  _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
  _productsRequest.delegate = self;
  [_productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  NSLog(@"Get SK Response");
  _productsRequest = nil;
  
  NSArray *skProducts = response.products;
  for (SKProduct *skProduct in skProducts) {
    NSLog(@"Found product: %@ %@ %0.2f",
          skProduct.productIdentifier,
          skProduct.localizedTitle,
          skProduct.price.floatValue);
  }
  
  self.products = skProducts;
  _completionHandler(YES, skProducts);
  _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  NSLog(@"Fail SK request Full Reason: %@",[error description]);
  
  _completionHandler(NO, nil);
  _completionHandler = nil;
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
  return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
  SKPayment *payment = [SKPayment paymentWithProduct:product];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchasedProducts {
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
  NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
  
  NSLog(@"received restored transactions: %d", queue.transactions.count);
  for (SKPaymentTransaction *transaction in queue.transactions)
  {
    NSString *productID = transaction.payment.productIdentifier;
    [purchasedItemIDs addObject:productID];
  }
  
  for (NSString *productID in purchasedItemIDs) {
    NSLog(@"restored product : %@", productID);
    [self provideContentForProductIdentifier:productID fireNotification:NO];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredNotification object:nil userInfo:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"restored transactions failed");
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredFailedNotification object:nil userInfo:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    switch (transaction.transactionState) {
      
      case SKPaymentTransactionStatePurchased: {
        [self completeTransaction:transaction];
      } break;
      
      case SKPaymentTransactionStateFailed: {
        [self failedTransaction:transaction];
      } break;
        
      case SKPaymentTransactionStateRestored: {
        [self restoreTransaction:transaction];
      } break;
        
      default:
        break;
    }
  }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  NSLog(@"completeTransaction...");
  
  [self provideContentForProductIdentifier:transaction.payment.productIdentifier fireNotification:YES];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
  NSLog(@"restoreTransaction...");
  
  [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier fireNotification:YES];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  
  NSLog(@"failedTransaction...");
  if (transaction.error.code != SKErrorPaymentCancelled)
  {
    NSLog(@"Transaction error: %@", transaction.error.description);
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedFailedNotification object:nil userInfo:nil];
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier fireNotification:(BOOL)flag {

  NSString *productPurchasedKey = @"";
  if ([productIdentifier rangeOfString:@"retroch3"].location != NSNotFound) {
    productPurchasedKey = RetroCh3ProductPurchasedKey;
  } else if ([productIdentifier rangeOfString:@"retroch5"].location != NSNotFound) {
    productPurchasedKey = RetroCh5ProductPurchasedKey;
  } else if ([productIdentifier rangeOfString:@"retroch7"].location != NSNotFound) {
    productPurchasedKey = RetroCh7ProductPurchasedKey;
  }
  [_purchasedProductIdentifiers addObject:productIdentifier];
  [[NSUserDefaults standardUserDefaults] setObject:productPurchasedKey forKey:productIdentifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
  
}

@end
