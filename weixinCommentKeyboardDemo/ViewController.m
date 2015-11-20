//
//  ViewController.m
//  weixinCommentKeyboardDemo
//
//  Created by mobile_dev01 on 15/11/19.
//  Copyright © 2015年 sipsd. All rights reserved.
//

#import "ViewController.h"
#import <UIViewController-KeyboardAdditions/UIViewController+KeyboardAdditions.h>
#import "CellBtn.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomContstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottomContstrain;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic) CGFloat selectedCellY;
@property (nonatomic) CGFloat selectedContentOffsetY;
@property (nonatomic) CGFloat selectedCellHeight;
@property (nonatomic) BOOL keyboardOpened;
@property (nonatomic) CGFloat deltaY;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // register to keyboard notifications
    [self ka_startObservingKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // unregister from keyboard notifications
    [self ka_stopObservingKeyboardNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *identify = @"head";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        return cell;
    }
    
    
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    CellBtn *btn = [cell viewWithTag:101];
    btn.cellIndexPath = indexPath;
    [btn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)commentBtnClicked:(CellBtn *)sender {
    if (_keyboardOpened) {
        [self.commentTextField resignFirstResponder];
        _keyboardOpened = NO;
        return;
    }
    
    UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:sender.cellIndexPath];
    CGRect cellFrame = cell.frame;
    _selectedCellY = cellFrame.origin.y;
    _selectedContentOffsetY = self.tableview.contentOffset.y;
    _selectedCellHeight = CGRectGetHeight(cellFrame);
//    NSLog(@"cell y:%f",_selectedCellY);
    
    [self.commentTextField becomeFirstResponder];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return;
    }
    if (_keyboardOpened) {
        [self.commentTextField resignFirstResponder];
        _keyboardOpened = NO;
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 278;
    }
    return 120;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_keyboardOpened) {
        [self.commentTextField resignFirstResponder];
    }
}

#pragma mark - KAKeyboardAdditions

- (void)ka_keyboardWillShowOrHideWithHeight:(CGFloat)height
                          animationDuration:(NSTimeInterval)animationDuration
                             animationCurve:(UIViewAnimationCurve)animationCurve {
    _keyboardOpened = NO;
    NSLog(@"Will %@ with height = %f, duration = %f",
          self.ka_isKeyboardPresented ? @"show" : @"hide",
          height,
          animationDuration);
    
    if (height == 0) {
        CGPoint contentOffset = self.tableview.contentOffset;
        contentOffset.y = _selectedContentOffsetY;
        self.tableview.contentOffset = contentOffset;
        
        self.containerViewBottomContstrain.constant = -50;
        
        return;
    }
}

- (void)ka_keyboardShowOrHideAnimationDidFinishedWithHeight:(CGFloat)height {
    
    if (height == 0) {
        return;
    }
    _keyboardOpened = YES;
}

- (void)ka_keyboardShowOrHideAnimationWithHeight:(CGFloat)height
                               animationDuration:(NSTimeInterval)animationDuration
                                  animationCurve:(UIViewAnimationCurve)animationCurve {
    if (height == 0) {
        return;
    }

    self.containerViewBottomContstrain.constant = height;
    
    CGPoint contentOffset = self.tableview.contentOffset;
    CGFloat screenY = _selectedCellY - contentOffset.y;
    CGFloat keyboardY = [UIScreen mainScreen].bounds.size.height - (height + CGRectGetHeight(self.containerView.frame) + _selectedCellHeight + 2);
    self.deltaY = screenY - keyboardY;
    NSLog(@"delat Y: %f",self.deltaY);
    contentOffset.y += self.deltaY;
    self.tableview.contentOffset = contentOffset;
    [self.view layoutIfNeeded];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
