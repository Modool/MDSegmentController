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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didClickRightBarButton:)];
}

- (void)didClickRightBarButton:(id)sender {
    MDSegmentController *controller = [[MDSegmentController alloc] initWithStyle:MDSegmentControllerStyleDefault];
    controller.delegate = self;
    controller.segmentControlSize = CGSizeMake(0, 30);

    controller.segmentControl.fade = YES;

    // 全屏小横条，标题动态宽度，固定边距，所有标题整体居中
    controller.segmentControl.spacing = 30;
    controller.segmentControl.homodisperse = YES; // 内容超出屏幕时失效

    controller.segmentControl.font = [UIFont systemFontOfSize:12];
    controller.segmentControl.tintColor = [UIColor blueColor];
    controller.segmentControl.textColor = [UIColor greenColor];
    controller.segmentControl.selectedTextColor = [UIColor redColor];
    controller.segmentControl.scrollContentInset = UIEdgeInsetsMake(0, 30, 0, 30);

    controller.segmentControl.indicatorEnabled = YES;
    controller.segmentControl.indicatorHeight = 2.f; // 默认 2.f
    controller.segmentControl.indicatorLayer.backgroundColor = [[[UIColor greenColor] colorWithAlphaComponent:0.4] CGColor];

    TableViewItemViewController *viewController1 = [[TableViewItemViewController alloc] init];
    viewController1.title = @"item1";

    ItemViewController *viewController2 = [[ItemViewController alloc] init];
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

    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];

    controller.view.frame = self.view.bounds;

    controller.viewControllers = @[viewController1, viewController2, viewController3, viewController4, viewController5,
                                   viewController6, viewController7, viewController8, viewController9, viewController10,
                                   viewController11, viewController12, viewController13];
    controller.selectedIndex = 0;
}

#pragma mark - MDSegmentControlDelegate

- (void)segmentControl:(MDSegmentControl *)segmentControl didSelectAtIndex:(NSUInteger)index {
    NSLog(@"did select at index: %ld", (unsigned long)index);
}

#pragma mark - MDSegmentControllerDelegate

- (BOOL)segmentController:(MDSegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController {
    NSLog(@"should select view controller: %@ atIndex: %ld", viewController, (unsigned long)[[segmentController viewControllers] indexOfObject:viewController]);
    return YES;
}

- (void)segmentController:(MDSegmentController *)segmentController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"select view controller: %@ atIndex: %ld", viewController, (unsigned long)[[segmentController viewControllers] indexOfObject:viewController]);
}

- (void)segmentController:(MDSegmentController *)segmentController didScrollToIndex:(NSUInteger)index {
    NSLog(@"did scroll to index: %ld", (unsigned long)index);
}

@end
