//
//  KTableViewCell.m
//  InAppRage
//
//  Created by JS1-ZJT on 16/5/11.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import "KTableViewCell.h"

@implementation KTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btn.layer.cornerRadius = 5;
    self.btn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
