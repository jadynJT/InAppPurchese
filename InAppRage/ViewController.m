//
//  ViewController.m
//  InAppRage
//
//  Created by JS1-ZJT on 16/5/6.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import "ViewController.h"
#import "KTableViewCell.h"
#import "InAppRageIAPHelper.h"
#import "Reachability.h"
#define IDENTIFIER @"IDENTIFIER"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

{

    UITableView *tableview;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self tableview];
    
    //产品列表加载通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name: kProductsLoadedNotification object:nil];
    
    //产品购买完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    
    //产品购买失败通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(giveProduct:) name:KProductPurchaseProductNotification object:nil];
    
    //检查网络状态
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        
        NSLog(@"无网络连接");
        
    }else{
        
        if ([InAppRageIAPHelper sharedHelper].products == nil) {
            
            [[InAppRageIAPHelper sharedHelper] requestProducts]; //进行查询
            
            _hud.label.text = @"Loading";
            //显示一个菊花器
            self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//            _hud.labelText = @"loading";
            //设置一个超时检测函数，当30秒过后，如果还没有加载完产品列表的话，我们就提示用户错误
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
            
        }
    
    }
    
}


//隐藏
-(void)dismissHUD:(id)arg{

    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
}

//超时
-(void)timeout:(id)arg{

  _hud.label.text = @"TimeOut";
  _hud.detailsLabel.text = @"请稍后再试";
  _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
  _hud.mode = MBProgressHUDModeCustomView;
    
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];

}

#pragma mark----tableView

-(void)tableview{
 
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableview.dataSource = self;
    tableview.delegate = self;
    [self.view addSubview:tableview];

    [tableview registerNib:[UINib nibWithNibName:@"KTableViewCell" bundle:nil] forCellReuseIdentifier:IDENTIFIER];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
    NSLog(@"count = %ld",[[InAppRageIAPHelper sharedHelper].products count]);
    
    return [[InAppRageIAPHelper sharedHelper].products count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 65;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

//    static NSString *IDENTIFIER = @"IDENTIFIER";
    
    KTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER forIndexPath:indexPath];
    
    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:indexPath.row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    //cell设置
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.texttitle.text = product.localizedTitle;
    cell.price.text = formattedString;
    cell.subtext.text = product.localizedDescription;
    
    [cell.btn addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn setTitle:@"购买" forState:UIControlStateNormal];
    cell.btn.tag = indexPath.row;
    
    //购买按钮  判断该产品标识符是否已经存在  存在则不再显示购买按钮
    if ([[InAppRageIAPHelper sharedHelper].puchaseProducts containsObject:product.productIdentifier]) {
       
        cell.btn.enabled = NO;
        cell.btn.backgroundColor = [UIColor grayColor];
        [cell.btn setTitle:@"已购买" forState:UIControlStateNormal];
        
    }
    
    return cell;

}

//购买按钮响应事件
-(void)buyButtonTapped:(UIButton *)sender{

    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:sender.tag];
    
    [[InAppRageIAPHelper sharedHelper] buyProductIdentifier:product buyTag:sender.tag];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    _hud.label.text = @"正在购买";
    
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:30];
    
}

//产品列表加载通知事件
- (void)productsLoaded:(NSNotification *)notification {
     
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    tableview.hidden = FALSE;
    
    [tableview reloadData];
    
}

//完成支付通知事件
-(void)productPurchased:(NSNotification *)sender{
   
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    [tableview reloadData];
    
}

//支付失败事件
-(void)productPurchaseFailed:(NSNotification *)sender{

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    SKPaymentTransaction *transaction = (SKPaymentTransaction *)sender.object;
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        
        //通知框
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"error" message:@"UIAlertController" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"通知框");
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }

}

-(void)giveProduct:(NSNotificationCenter *)sender{
 
    [self.navigationController.navigationBar setBarTintColor:[UIColor purpleColor]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
