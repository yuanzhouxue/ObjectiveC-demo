//
//  PlainTableViewCell.m
//  OCDemo
//
//  Created by ByteDance on 2023/7/7.
//

#import "PlainTableViewCell.h"

@implementation PlainTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    NSString *cellID = @"cell";
    PlainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[PlainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initWithView];
    }
    return self;
}
// 在这个方法里面添加各种控件,但是不要在这个方法里面设置控件的尺寸大小
- (void)initWithView {
    
}
// 在这个方法里面设置尺寸大小
- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
