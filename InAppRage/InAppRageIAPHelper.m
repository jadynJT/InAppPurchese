//
//  InAppRageIAPHelper.m
//  InAppRage
//
//  Created by JS1-ZJT on 16/5/6.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import "InAppRageIAPHelper.h"

@interface InAppRageIAPHelper ()

@end

@implementation InAppRageIAPHelper

//单例
static InAppRageIAPHelper *_sharedHelper;

+(InAppRageIAPHelper *)sharedHelper{
 
    if (_sharedHelper == nil) {
        
        _sharedHelper = [[InAppRageIAPHelper alloc] init];

    }

    return _sharedHelper;
    
}

-(id)init{
  
    //硬编码了一组产品标识符的字符串数组，然后调用了基类的初始化方式
    
#pragma mark---字符串名字必须保持和之前在iTunes Connect里面定义的名称要一致。
    NSMutableSet *productIdentifiers = [NSMutableSet setWithObjects:
                                 @"com.nenglong.purchaseDemo.Test1",
                                 @"com.nenglong.purchaseDemo.Test2",
                                 @"com.nenglong.purchaseDemo.procuct1",
                                 @"com.nenglong.purchaseDemo.procuct2",
                                 @"com.nenglong.purchaseDemo.procuct3",
                                 nil];
    
    
    if (self = [super initWithProductIdentifiers:productIdentifiers]) {
        
        
        
    }
    
    
    return self;

}

@end
