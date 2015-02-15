//
//  IAPHelper.h
//  NumNao
//
//  Created by PRINYA on 8/6/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString * const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString * const IAPHelperProductRestoredNotification;
UIKIT_EXTERN NSString * const IAPHelperProductPurchasedFailedNotification;
UIKIT_EXTERN NSString * const IAPHelperProductRestoredFailedNotification;
typedef void (^RequestProductWithCompletinoHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject

@property (strong, nonatomic) NSArray *products;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductWithCompletinoHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (void)restorePurchasedProducts;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier fireNotification:(BOOL)flag;

@end
