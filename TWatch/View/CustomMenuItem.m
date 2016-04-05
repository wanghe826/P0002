//
//  CustomMenuItem.m
//  TWatch
//
//  Created by QFITS－iOS on 15/11/18.
//  Copyright © 2015年 ZeroSoft. All rights reserved.
//

#import "CustomMenuItem.h"

@implementation CustomMenuItem

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CustomMenuItem*)customMenuItem:(UITableView*)tableView
{
    static NSString* identifier = @"reuseId";
    CustomMenuItem* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[CustomMenuItem alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _menuTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.frame.size.height-40)/2, 100, 40)];
        _menuTitle.textAlignment = NSTextAlignmentLeft;
        _menuTitle.textColor = RGBColor(0xfd, 0xfd, 0xfd);
        
        _connectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        _connectLabel.textAlignment = NSTextAlignmentCenter;
        _connectLabel.textColor = HexRGBAlpha(0xfdfdfd, 0.5);
        _connectLabel.center = self.center;
        [self.contentView addSubview:_connectLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HexRGBAlpha(0x111, 0);
        [self.contentView addSubview:_menuTitle];
    }
    return self;
}

#pragma delegate

- (UIView*) animatedContent
{
    return self.menuTitle;
}

- (UIView*)animatedIcon
{
    return nil;
}
    
                

@end
