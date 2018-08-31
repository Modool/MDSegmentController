//
//  ViewController.m
//  MDSegmentController
//
//  Created by xulinfeng on 2018/8/24.
//  Copyright © 2018年 modool. All rights reserved.
//

#import "ViewController.h"
#import "MDHorizontalListView.h"

@interface ItemViewController : UIViewController
@end

@implementation ItemViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255. green:arc4random() % 255 / 255. blue:arc4random() % 255 / 255. alpha:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"will appear: %@", self.title);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"did appear: %@", self.title);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSLog(@"will disappear: %@", self.title);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    NSLog(@"did disappear: %@", self.title);
}

@end


@interface TableViewItemViewController : UITableViewController
@end

@implementation TableViewItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255. green:arc4random() % 255 / 255. blue:arc4random() % 255 / 255. alpha:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"will appear: %@", self.title);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"did appear: %@", self.title);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSLog(@"will disappear: %@", self.title);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    NSLog(@"did disappear: %@", self.title);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];

    cell.textLabel.text = @(indexPath.row).stringValue;
    return cell;
}

@end

@interface ViewController () <MDSegmentControllerDelegate>

@end

@implementation ViewController

- (instancetype)initWithStyle:(MDSegmentControllerStyle)style {
    if (self = [super initWithStyle:style]) {
        self.title = @"root";
        self.segmentControlSize = CGSizeMake(0, 30);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didClickSelectButton:)];

    self.delegate = self;
//    self.bounces = NO;
    self.segmentControl.fade = YES;
    self.segmentControl.spacing = 30;
//    self.segmentControl.minimumSpacing = 20;
    self.segmentControl.tintColor = [UIColor blueColor];
    self.segmentControl.textColor = [UIColor greenColor];
    self.segmentControl.selectedTextColor = [UIColor redColor];
    self.segmentControl.font = [UIFont systemFontOfSize:12];

    self.segmentControl.indicatorEnabled = YES;
    self.segmentControl.indicatorHeight = 30;
    self.segmentControl.indicatorInsets = UIEdgeInsetsMake(0, -10, 0, -10);
    self.segmentControl.indicatorLayer.backgroundColor = [[[UIColor greenColor] colorWithAlphaComponent:0.4] CGColor];
    self.segmentControl.indicatorLayer.cornerRadius = 15.f;

    ItemViewController *viewController1 = [[ItemViewController alloc] init];
    viewController1.title = @"item1";

    TableViewItemViewController *viewController2 = [[TableViewItemViewController alloc] init];
    viewController2.title = @"item222222";

    ItemViewController *viewController3 = [[ItemViewController alloc] init];
    viewController3.title = @"item33333333";

    ItemViewController *viewController4 = [[ItemViewController alloc] init];
    viewController4.title = @"item4";

    ItemViewController *viewController5 = [[ItemViewController alloc] init];
    viewController5.title = @"item5";

    ItemViewController *viewController6 = [[ItemViewController alloc] init];
    viewController6.title = @"item6";

    ItemViewController *viewController7 = [[ItemViewController alloc] init];
    viewController7.title = @"item7";

    ItemViewController *viewController8 = [[ItemViewController alloc] init];
    viewController8.title = @"item8";

    ItemViewController *viewController9 = [[ItemViewController alloc] init];
    viewController9.title = @"item9";

    ItemViewController *viewController10 = [[ItemViewController alloc] init];
    viewController10.title = @"item10";

    ItemViewController *viewController11 = [[ItemViewController alloc] init];
    viewController11.title = @"item11";

    ItemViewController *viewController12 = [[ItemViewController alloc] init];
    viewController12.title = @"item12";

    ItemViewController *viewController13 = [[ItemViewController alloc] init];
    viewController13.title = @"item13";

    self.viewControllers = @[viewController1, viewController2, viewController3, viewController4, viewController5,
                             viewController6, viewController7, viewController8, viewController9, viewController10,
                             viewController11, viewController12, viewController13];

//    self.viewControllers = @[viewController1, viewController2];
}

- (void)didClickSelectButton:(id)sender {
    static NSUInteger index = 0;

    index++;
    index %= self.viewControllers.count;

    [self setSelectedIndex:index animated:YES];
}

//- (BOOL)segmentController:(MDSegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController {
//    NSLog(@"should select view controller: %@ atIndex: %ld", viewController, [[segmentController viewControllers] indexOfObject:viewController]);
//    return YES;
//}
//
//- (void)segmentController:(MDSegmentController *)segmentController didSelectViewController:(UIViewController *)viewController {
//    NSLog(@"select view controller: %@ atIndex: %ld", viewController, [[segmentController viewControllers] indexOfObject:viewController]);
//}

@end
