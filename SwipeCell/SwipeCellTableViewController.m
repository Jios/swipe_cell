//
//  SwipeCellTableViewController.m
//  SwipeCell
//
//  Created by Jian on 6/10/18.
//  Copyright © 2018 Jian. All rights reserved.
//

#import "SwipeCellTableViewController.h"
//#import "SwipeTableViewCell.h"
#import "SwipeCell-Swift.h"



//static NSString * const kCellIdentifier = @"swipeCell";
static NSString * const kCellIdentifier = @"swiftSwipeCell";



@interface SwipeCellTableViewController ()
<
    SwipeCell
>

@end



@implementation SwipeCellTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Swipe Cell Demo";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// MARK: - # Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)   tableView:(UITableView *)tableView
            cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     // objc
    SwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier
                                                               forIndexPath: indexPath];
    
    NSString *title = [NSString stringWithFormat: @"# %ld", (long)indexPath.row];
    
    cell.textLabel.text       = title;
    cell.detailTextLabel.text = title;
    
    NSArray *options = @[@"Button 1", @"Button 2"];
    
    [cell addOptions: options
       buttonTouched: ^(UIButton *button) {
           
           NSLog(@"%ld: %@ - %ld", (long)indexPath.row, button.titleLabel.text, (long)button.tag);
       }];
//    */
    
    
    // swift
    SwiftSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier
                                                                    forIndexPath: indexPath];
    
    cell.delegate = self;
    
    NSString *title = [NSString stringWithFormat: @"# %ld", (long)indexPath.row];
    
    cell.textLabel.text       = title;
    cell.detailTextLabel.text = title;
    
    NSArray *options = @[@"Button 1", @"Button 2"];
    [cell addOptions: options
         atIndexPath: indexPath];
    
    return cell;
}

-(void)         tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath
                             animated: YES];
}

-(CGFloat)      tableView:(UITableView *)tableView
  heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (BOOL)        tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


// MARK: - # swift SwipeCell

-(void)cellButtonTouched:(UIButton *)sender
             atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"button: %@ (tag: %ld) at row %ld", sender.titleLabel.text, (long)sender.tag, (long)indexPath.row);
}



@end
