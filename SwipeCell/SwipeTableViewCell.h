//
//  SwipeTableViewCell.h
//  SwipeCell
//
//  Created by Jian on 6/10/18.
//  Copyright © 2018 Jian. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void(^ButtonBlock)(UIButton * _Nullable button);



@interface SwipeTableViewCell : UITableViewCell

-(void)addOptions: (NSArray <NSString *>*_Nullable)arrOptions
    buttonTouched: (ButtonBlock _Nonnull)buttonBlock;

-(void)showOptions: (BOOL)show
          animated: (BOOL)animated;

@end
