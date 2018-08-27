//
//  MDSegmentController.m
//  MDSegmentController
//
//  Created by xulinfeng on 2018/8/27.
//  Copyright © 2018年 modool. All rights reserved.
//

#import "MDSegmentController.h"

@interface MDSegmentController () {
    __weak id<MDSegmentControllerDelegate> _delegate;
    NSMutableArray<UIViewController *> *_viewControllers;
    NSUInteger _selectedIndex;

    UIView *_wrapperView;
    NSRecursiveLock *_lock;
}

@end

@implementation MDSegmentController

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _viewControllers = [NSMutableArray array];
    _lock = [[NSRecursiveLock alloc] init];
}

- (void)loadView {
    [super loadView];

    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    _wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];

    [_contentView addSubview:_wrapperView];
    [self.view addSubview:_contentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [self _unloadViewControllers];
}

#pragma mark - accessor

- (id<MDSegmentControllerDelegate>)delegate {
    id<MDSegmentControllerDelegate> delegate = nil;
    [_lock lock];
    delegate = _delegate;
    [_lock unlock];
    return delegate;
}

- (void)setDelegate:(id<MDSegmentControllerDelegate>)delegate {
    [_lock lock];
    if (_delegate != delegate) {
        _delegate = delegate;
    }
    [_lock unlock];
}

- (NSArray<UIViewController *> *)viewControllers {
    NSArray<UIViewController *> *viewControllers = nil;
    [_lock lock];
     viewControllers = [_viewControllers copy];
    [_lock unlock];
    return viewControllers;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    [_lock lock];
    [self _unloadViewControllers];
    _viewControllers.array = viewControllers;
    [self _loadViewControllers];
    [_lock unlock];
}

- (UIViewController *)selectedViewController {
    UIViewController *viewController = nil;
    [_lock lock];
    if (_selectedIndex < _viewControllers.count) viewController = _viewControllers[_selectedIndex];
    [_lock unlock];
    return viewController;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    [_lock lock];
    NSUInteger index = [_viewControllers indexOfObject:selectedViewController];
    if (index == NSNotFound || index == _selectedIndex) return;

    self.selectedIndex = index;
    [_lock unlock];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [_lock lock];

    if (selectedIndex < _viewControllers.count && selectedIndex != _selectedIndex) {
        [self _prepareToSelectIndex:selectedIndex];
    }
    [_lock unlock];
}

#pragma mark - private

- (void)_loadViewControllers {
    for (UIViewController *viewController in _viewControllers) {
        [viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        [self _loadViewController:viewController];
    }
}

- (void)_unloadViewControllers {
    for (UIViewController *viewController in _viewControllers) {
        [viewController removeObserver:self forKeyPath:@"title"];
        [self _unloadViewController:viewController];
    }
}

- (void)_prepareToSelectIndex:(NSUInteger)selectedIndex {
    UIViewController *viewController = _viewControllers[selectedIndex];
    BOOL shouldSelect = [self _shouldSelectViewController:viewController];
    if (shouldSelect) return;

    UIViewController *previousViewController = [self selectedViewController];
    [self _transitFromViewController:previousViewController toViewController:viewController];

    _selectedIndex = selectedIndex;
}

- (BOOL)_shouldSelectViewController:(UIViewController *)viewController {
    if ([_delegate respondsToSelector:@selector(segmentController:shouldSelectViewController:)]) {
        return [_delegate segmentController:self shouldSelectViewController:viewController];
    }
    return YES;
}

- (void)_didSelectViewController:(UIViewController *)selectedCiewController {
    if ([_delegate respondsToSelector:@selector(segmentController:didSelectViewController:)]) {
        [_delegate segmentController:self didSelectViewController:selectedCiewController];
    }
}

- (id<MDSegmentControllerTransitioning>)_transitioningFromViewController:(UIViewController *)fromViewController
                                                        toViewController:(UIViewController *)toViewController {
    if ([_delegate respondsToSelector:@selector(segmentController:transitioningFromViewController:toViewController:)]) {
        return [_delegate segmentController:self transitioningFromViewController:fromViewController toViewController:toViewController];
    }
    return nil;
}

- (void)_transitFromViewController:(UIViewController *)fromViewController
                  toViewController:(UIViewController *)toViewController {
    id<MDSegmentControllerTransitioning> transitioning = [self _transitioningFromViewController:fromViewController toViewController:toViewController];
    if (transitioning) {
        [transitioning transitionWithContainerView:_wrapperView];
    } else {
        [self _unloadViewController:fromViewController];
        [self _loadViewController:toViewController];
    }
}

- (void)_loadViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:self];

    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];

    [viewController didMoveToParentViewController:self];
}

- (void)_unloadViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];

    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];

    [viewController didMoveToParentViewController:nil];
}

- (void)_didUpdateViewControllerAtIndex:(NSUInteger)index title:(NSString *)title {
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) return;

    UIViewController *viewController = [object isKindOfClass:[UIViewController class]] ? object : nil;
    if (!viewController) return;

    NSUInteger index = [_viewControllers indexOfObject:viewController];
    if (index == NSNotFound) return;

    [self _didUpdateViewControllerAtIndex:index title:change[NSKeyValueChangeNewKey]];
}

@end
