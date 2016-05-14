//
//  KTableViewCell.h
//  InAppRage
//
//  Created by JS1-ZJT on 16/5/11.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *texttitle;
@property (weak, nonatomic) IBOutlet UILabel *subtext;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end
