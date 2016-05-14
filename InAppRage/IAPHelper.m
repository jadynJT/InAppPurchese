//
//  IAPHelper.m
//  InAppRage
//
//  Created by JS1-ZJT on 16/5/6.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import "IAPHelper.h"

@interface IAPHelper()<SKProductsRequestDelegate>

@end

@implementation IAPHelper     

-(void)requestProducts {

    if ([SKPaymentQueue canMakePayments]) {
       
        //通过一串产品标识符，可从iTunes Connect里面查询产品
        self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
        
        self.request.delegate = self;
        
        [self.request start];
        
    }else{
        
        NSLog(@"不允许程序内付费");
    
    }
    
}

//代理方法
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{

    NSLog(@"收到产品列表的结果");
    self.products = response.products;
    self.request = nil;
    
    NSLog(@"%@",self.products);
    
    if (self.products.count > 0) {
       
        //发布通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:self.products];
        
    }
    
}

//初始化代码将检测哪些产品已经被购买，哪些还没有
-(id)initWithProductIdentifiers:(NSMutableSet *)productIdentifiers{
   
    if (self = [super init]) {
        
        _productIdentifiers = productIdentifiers;
        
        NSMutableSet *puchaseProducts = [NSMutableSet set];
        
        for (NSString *productIdentifier in _productIdentifiers) {
            
            NSUserDefaults *userDefault = [[NSUserDefaults alloc] init];
            BOOL productPuchase = [userDefault boolForKey:productIdentifier];
            
            if (productPuchase) {
                
                [puchaseProducts addObject:productIdentifier];
                
            }
            
        }
        
        self.puchaseProducts = puchaseProducts;
        
    }

    return self;
    
}

#pragma mark----支付处理方面///

-(void)recordTransaction:(SKPaymentTransaction *)transaction{

}

-(void)provideContent:(NSString *)productIdentifier{

    if (self.flag > 1) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.puchaseProducts addObject:productIdentifier];
    }
    
     [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:productIdentifier];
    
}

//完成支付
-(void)completeTransaction:(SKPaymentTransaction *)transaction{

    [self verifyPruchase]; //支付凭据
    
    [self recordTransaction:transaction];
    
    [self provideContent:transaction.payment.productIdentifier];

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

//恢复支付
-(void)restoreTransaction:(SKPaymentTransaction *)transaction{

    [self recordTransaction:transaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

}

//支付失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

#pragma mark---支付队列 SKPaymentTransactionObserver 的代理方法
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                
                [self completeTransaction:transaction];
                
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                
                [self failedTransaction:transaction];
                
            }
                break;
            case SKPaymentTransactionStateRestored:
            {
                
                [self restoreTransaction:transaction];
                
            }
                break;
            default:
                break;
        }
        
    }
    
}

#pragma mark 验证购买凭据

- (void)verifyPruchase {
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    // 发送网络POST请求，对购买凭据进行验证
    //测试验证地址:https://sandbox.itunes.apple.com/verifyReceipt
    //正式验证地址:https://buy.itunes.apple.com/verifyReceipt
    NSURL *url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    urlRequest.HTTPMethod = @"POST";
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPBody = payloadData;
    
    // 提交验证请求，并获得官方的验证JSON结果 iOS9后更改了另外的一个方法
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        NSData *result = data;
        // 官方验证结果为空
        if (result == nil) {
            NSLog(@"验证失败");
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        
        if (dict != nil) {
            // 比对字典中以下信息基本上可以保证数据安全
            // bundle_id , application_version , product_id , transaction_id
            NSLog(@"验证成功！购买的商品是：%@",dict);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KProductPurchaseProductNotification object:nil userInfo:nil];
            
        }
        
    }] resume];
}

//购买
-(void)buyProductIdentifier:(SKProduct *)product
                     buyTag:(NSInteger)flag{
  
    self.flag = flag;
    
    NSLog(@"Buying %@...", product);
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

@end
