//
//  SwipeTableViewCell.m
//  SwipeCell
//
//  Created by Jian on 6/10/18.
//  Copyright © 2018 Jian. All rights reserved.
//

#import "SwipeTableViewCell.h"



static NSString * const kNotificationName = @"SwipeCellSlide";

#define kMinSlide   -CGRectGetWidth(self.frame) * 0.1
#define kMaxSlide    CGRectGetWidth(self.frame) * 0.5



@interface SwipeTableViewCell ()
<
    UIGestureRecognizerDelegate
>

@property (nonatomic, strong) NSMutableArray *arrOptions;

@property (weak, nonatomic) IBOutlet UIView  *slideView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;

@property (nonatomic, copy) ButtonBlock buttonBlock;

@end



@implementation SwipeTableViewCell

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        [self setupGestures];
        
        // notification
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receiveNotification:)
                                                     name: kNotificationName
                                                   object: nil];
    }
    
    return self;
}

-(void)setupGestures
{
    // pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget: self
                                                                          action: @selector(handlePan:)];
    pan.delegate = self;
    [self addGestureRecognizer: pan];
}

-(void)setSelected:(BOOL)selected
          animated:(BOOL)animated
{
    if (selected)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationName
                                                            object: nil
                                                          userInfo: nil];
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self showOptions: NO
             animated: NO];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


// MARK: - # option button

-(void)addOptions: (NSArray <NSString *>*)arrOptions
    buttonTouched: (ButtonBlock _Nonnull)buttonBlock
{
    self.buttonBlock = buttonBlock;
    
    [self.arrOptions removeAllObjects];
    for (id subview in self.contentView.subviews)
    {
        if ([subview isKindOfClass: [UIButton class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    NSArray *arrColors = @[[UIColor redColor], [UIColor blueColor], [UIColor grayColor]];
    
    for (NSInteger i = 0; i < arrOptions.count; i++)
    {
        NSString *title = arrOptions[i];
        
        CGRect frame = CGRectMake(CGRectGetWidth(self.frame), 0,
                                  0, CGRectGetHeight(self.frame));
        
        UIButton *button = [[UIButton alloc] initWithFrame: frame];
        button.tag                      = i;
        button.backgroundColor          = arrColors[i % arrColors.count];
        button.titleLabel.lineBreakMode = NSLineBreakByClipping;
        
        [button setTitle: title
                forState: UIControlStateNormal];
        [button addTarget: self
                   action: @selector(optionButtonTouched:)
         forControlEvents: UIControlEventTouchUpInside];
        
        [self.contentView addSubview: button];
        [self.arrOptions addObject: button];
    }
}

-(void)optionButtonTouched: (UIButton *)sender
{
    [self showOptions: NO
             animated: YES];
    
    if (self.buttonBlock)
    {
        self.buttonBlock(sender);
    }
}


// MARK: - # notification

- (void)receiveNotification:(NSNotification *) notification
{
    if (![notification.userInfo[@"cell"] isEqual: @(self.hash)])
    {
        [self showOptions: NO
                 animated: YES];
    }
}


// MARK: - # getter

-(NSMutableArray *)arrOptions
{
    if (!_arrOptions)
    {
        _arrOptions = [NSMutableArray new];
    }
    
    return _arrOptions;
}

-(UILabel *)textLabel
{
    return self.lblTitle;
}

-(UILabel *)detailTextLabel
{
    return self.lblDetail;
}


// MARK: - # gesture

-(void)handlePan: (UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        NSDictionary *userInfo = @{@"cell": @(self.hash)};
        [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationName
                                                            object: nil
                                                          userInfo: userInfo];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGesture translationInView: self];
        [panGesture setTranslation: CGPointZero
                            inView: self];
        
        [self translateViewByX: self.slideView.center.x + translation.x];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded    ||
             panGesture.state == UIGestureRecognizerStateCancelled  )
    {
        BOOL show = (self.slideView.center.x <= self.center.x * 0.5);
        
        [self showOptions: show
                 animated: YES];
    }
}


// MARK: - # slide & option

-(void)translateViewByX: (CGFloat)x
{
    if (x < kMinSlide || x > kMaxSlide)
    {
        return;
    }
    
    self.slideView.center = CGPointMake(x, self.slideView.center.y);
    
    // slide option views
    CGFloat xMin   = CGRectGetMaxX(self.slideView.frame);
    CGFloat width  = (CGRectGetWidth(self.frame) - xMin) / self.arrOptions.count;
    CGFloat height = CGRectGetHeight(self.frame);
    
    for (UIButton *button in self.arrOptions)
    {
        button.frame = CGRectMake(xMin, 0,
                                  width, height);
        
        xMin = CGRectGetMaxX(button.frame);
    }
}

-(void)showOptions: (BOOL)show
          animated: (BOOL)animated
{
    CGFloat x = show ? 0 : CGRectGetWidth(self.frame) * 0.5;
    
    if (self.slideView.center.x == x)
    {
        return;
    }
    
    if (animated)
    {
        CGFloat damping  = show ? 0.5 : 1.0;
        CGFloat velocity = show ? 0.5 : 1.0;
        
        [UIView animateWithDuration: 0.3
                              delay: 0
             usingSpringWithDamping: damping
              initialSpringVelocity: velocity
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             
                             [self translateViewByX: x];
                         }
                         completion: nil];
    }
    else
    {
        [self translateViewByX: x];
    }
}


// MARK: - # UIGestureRecognizerDelegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        UIView *cell = [panGestureRecognizer view];
        CGPoint translation = [panGestureRecognizer translationInView: [cell superview]];
        
        // Check for horizontal gesture
        if (fabs(translation.x) > fabs(translation.y))
        {
            return YES;
        }
    }
    
    return NO;
}

@end
