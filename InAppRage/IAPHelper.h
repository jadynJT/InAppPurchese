//
//  IAPHelper.h
//  InAppRage
//
//  Created by JS1-ZJT on 16/5/6.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kProductsLoadedNotification  @"ProductsLoaded" //产品列表加载通知名
#define kProductPurchasedNotification   @"ProductPurchased" //支付完成通知名
#define kProductPurchaseFailedNotification @"ProductPurchaseFailed" //支付失败通知名

#define KProductPurchaseProductNotification @"KProductPurchaseProductNotification"

// SKPaymentTransactionObserver 监测交易的整个过程
@interface IAPHelper : NSObject <SKPaymentTransactionObserver>

@property (nonatomic,strong)SKProductsRequest *request;
@property (nonatomic, strong)NSMutableSet *productIdentifiers ,*puchaseProducts;

@property (nonatomic, strong)NSArray *products;

@property (nonatomic,assign)NSInteger flag;

-(id)initWithProductIdentifiers:(NSMutableSet *)productIdentifiers;
-(void)requestProducts;


- (void)buyProductIdentifier:(SKProduct *)product  buyTag:(NSInteger)flag;
@end
