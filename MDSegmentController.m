//
//  MDSegmentController.m
//  MDSegmentController
//
//  Created by xulinfeng on 2018/8/27.
//  Copyright © 2018年 modool. All rights reserved.
//

#import "MDSegmentController.h"

#import "MDHorizontalListView.h"

const CGFloat MDSegmentControllerSegmentControlMinimumHeight = 20.f;
const CGFloat MDSegmentControllerSegmentSpacingDynamic = CGFLOAT_MAX;

@interface MDSegmentItemCell : MDHorizontalListViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, assign) BOOL fade;

@end

@implementation MDSegmentItemCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;

        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _titleLabel.frame = self.contentView.bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    _titleLabel.textColor = selected ? _selectedTextColor : _textColor;
}

- (void)setSelectedProgress:(CGFloat)progress animated:(BOOL)animated {
    [super setSelectedProgress:progress animated:animated];

    if (!_fade) return;

    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    [_textColor getRed:&red green:&green blue:&blue alpha:&alpha];

    CGFloat red2 = 0, green2 = 0, blue2 = 0, alpha2 = 0;
    [_selectedTextColor getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];

    CGFloat r = red + (red2 - red) * progress;
    CGFloat g = green + (green2 - green) * progress;
    CGFloat b = blue + (blue2 - blue) * progress;
    CGFloat a = alpha + (alpha2 - alpha) * progress;

    _titleLabel.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end

@protocol MDSegmentControlContainer <NSObject>

@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

- (BOOL)segmentControl:(MDSegmentControl *)segmentControl shouldSelectAtIndex:(NSUInteger)index;
- (void)segmentControl:(MDSegmentControl *)segmentControl didSelectAtIndex:(NSUInteger)index;

@end

@interface MDSegmentControl () <MDHorizontalListViewDataSource, MDHorizontalListViewDelegate> {
    CGFloat _spacing;
    CGFloat _actualSpacing;
}

@property (nonatomic, weak, readonly) id<MDSegmentControlContainer> container;

@property (nonatomic, assign, readonly) MDSegmentControllerStyle style;
@property (nonatomic, strong, readonly) MDHorizontalListView *horizontalListView;
@property (nonatomic, strong, readonly) UISegmentedControl *segmentControl;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

@end

@implementation MDSegmentControl
@dynamic tintColor;

- (instancetype)initWithStyle:(MDSegmentControllerStyle)style container:(id<MDSegmentControlContainer>)container {
    NSParameterAssert(container);

    if (self = [super initWithFrame:CGRectZero]) {
        _style = style;
        _container = container;
        _spacing = MDSegmentControllerSegmentSpacingDynamic;

        if (style & MDSegmentControllerStyleSegmentControl) {
            _segmentControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
            [_segmentControl addTarget:self action:@selector(didSegmentValueChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:_segmentControl];
        } else {
            _horizontalListView = [[MDHorizontalListView alloc] initWithFrame:CGRectZero];
            _horizontalListView.dataSource = self;
            _horizontalListView.delegate = self;
            _horizontalListView.allowsNoneSelection = NO;
            _horizontalListView.allowsMultipleSelection = NO;
            _horizontalListView.selectionStyle = MDHorizontalListViewCellSelectionStyleNone;

            _horizontalListView.showsVerticalScrollIndicator = NO;
            _horizontalListView.showsHorizontalScrollIndicator = NO;

            [self addSubview:_horizontalListView];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithStyle:MDSegmentControllerStyleDefault container:nil]) {
        self.frame = frame;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _segmentControl.frame = self.bounds;
    _horizontalListView.frame = self.bounds;

    [self _updateSpacing];
}

#pragma mark - accessor

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    _viewControllers = viewControllers;

    [self _updateSpacing];
}

- (void)setItemWidth:(CGFloat)itemWidth {
    if (_itemWidth != itemWidth) {
        _itemWidth = itemWidth;

        [self _reloadData];
    }
}

- (void)setFont:(UIFont *)font {
    if (_font != font) {
        _font = font;

        [self _reloadData];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;

        [self _reloadData];
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    if (_selectedTextColor != selectedTextColor) {
        _selectedTextColor = selectedTextColor;

        [self _reloadData];
    }
}

- (void)setSpacing:(CGFloat)spacing {
    if (_spacing != spacing) {
        _spacing = spacing;

        [self _updateSpacing];
        [self _reloadData];
    }
}

- (void)setMinimumSpacing:(CGFloat)minimumSpacing {
    if (_minimumSpacing != minimumSpacing) {
        _minimumSpacing = minimumSpacing;

        [self _updateSpacing];
        [self _reloadData];
    }
}

- (CGFloat)spacing {
    return _spacing;
}

- (void)setHomodisperse:(BOOL)homodisperse {
    if (_homodisperse != homodisperse) {
        _homodisperse = homodisperse;

        [self _reloadData];
    }
}

- (void)setIndicatorEnabled:(BOOL)indicatorEnabled {
    _horizontalListView.indicatorEnabled = indicatorEnabled;
}

- (BOOL)isIndicatorEnabled {
    return _horizontalListView.indicatorEnabled;
}

- (CALayer *)indicatorLayer {
    return _horizontalListView.indicatorLayer;
}

- (void)setIndicatorInsets:(UIEdgeInsets)indicatorInsets {
    _horizontalListView.indicatorInsets = indicatorInsets;
}

- (UIEdgeInsets)indicatorInsets {
    return _horizontalListView.indicatorInsets;
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight {
    _horizontalListView.indicatorHeight = indicatorHeight;
}

- (CGFloat)indicatorHeight {
    return _horizontalListView.indicatorHeight;
}

- (void)setIndicatorWidth:(CGFloat)indicatorWidth {
    _horizontalListView.indicatorWidth = indicatorWidth;
}

- (CGFloat)indicatorWidth {
    return _horizontalListView.indicatorWidth;
}

#pragma mark - private

- (void)_updateSpacing {
    if (_style & MDSegmentControllerStyleSegmentControl) return;

    CGFloat spacing = _minimumSpacing;
    CGFloat edgeInsets = spacing;

    CGFloat contentWidth = CGRectGetWidth(self.frame);
    CGFloat width = [self _overallWidth];

    BOOL dynamic = _spacing == MDSegmentControllerSegmentSpacingDynamic;
    if (!dynamic) spacing = _spacing;

    CGFloat length = width + spacing * (_viewControllers.count - 1) + spacing;
    if (length < contentWidth && _viewControllers.count) {
        if (dynamic) {
            spacing = (contentWidth - width) / _viewControllers.count;
            length = width + spacing * (_viewControllers.count - 1);
        }
        edgeInsets = (contentWidth - length) / 2.;
    } else {
        edgeInsets = spacing / 2.;
    }
    
    _actualSpacing = spacing;
    _horizontalListView.cellSpacing = _actualSpacing;
    _horizontalListView.contentInset = UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

- (CGFloat)_overallWidth {
    CGFloat width = 0;
    for (UIViewController *viewController in _viewControllers) {
        width += [self _widthForTitle:viewController.title];
    }
    return width;
}

- (CGFloat)_widthForTitle:(NSString *)title {
    CGSize size = _horizontalListView.bounds.size;
    NSDictionary *attributes = @{NSFontAttributeName: _font ?: [UIFont systemFontOfSize:[UIFont labelFontSize]]};
    return [title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
}

- (void)_selectIndexProgress:(CGFloat)indexProgress animated:(BOOL)animated {
    if (_style & MDSegmentControllerStyleSegmentControl) return;

    [_horizontalListView selectIndexProgress:indexProgress animated:animated nearestPosition:MDHorizontalListViewPositionCenter];
}

- (BOOL)_selectAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (_style & MDSegmentControllerStyleSegmentControl) {
        _segmentControl.selectedSegmentIndex = index;
    } else {
        return [_horizontalListView selectCellAtIndex:index animated:animated];
    }
    return YES;
}

- (void)_scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    if (!(_style & MDSegmentControllerStyleSegmentControl)) {
        [_horizontalListView scrollToIndex:index animated:animated nearestPosition:MDHorizontalListViewPositionCenter];
    }
}

- (void)_reloadCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (_style & MDSegmentControllerStyleSegmentControl) {
        _segmentControl.selectedSegmentIndex = index;
    } else {
        [_horizontalListView reloadCellAtIndex:index animated:animated];
    }
}

- (void)_reloadData {
    if (_style & MDSegmentControllerStyleSegmentControl) {
        UIColor *color = _textColor ?: [UIColor grayColor];
        UIColor *selectedColor = _selectedTextColor ?: color;
        UIFont *font = _font ?: [UIFont systemFontOfSize:[UIFont labelFontSize]];

        NSDictionary *noramlAttributes = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
        [_segmentControl setTitleTextAttributes:noramlAttributes forState:UIControlStateNormal];

        NSDictionary *selectedAttributes = @{NSForegroundColorAttributeName: selectedColor, NSFontAttributeName: font};
        [_segmentControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];

        [_segmentControl removeAllSegments];
        [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger index, BOOL *stop) {
            [self _insertSegmentItemWithTitle:viewController.title atIndex:index];
        }];
    } else {
        [_horizontalListView reloadData];
    }
}

- (void)_insertSegmentItemWithTitle:(NSString *)title atIndex:(NSUInteger)index {
    [_segmentControl insertSegmentWithTitle:title atIndex:index animated:NO];
}

#pragma mark - MDHorizontalListViewDelegate, MDHorizontalListViewDataSource

- (NSInteger)horizontalListViewNumberOfCells:(MDHorizontalListView *)horizontalListView {
    return [_viewControllers count];
}

- (CGFloat)horizontalListView:(MDHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index {
    if (_itemWidth != 0) return _itemWidth;

    UIViewController *viewController = _viewControllers[index];
    NSString *title = viewController.title;

    return [self _widthForTitle:title];
}

- (MDHorizontalListViewCell *)horizontalListView:(MDHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index {
    MDSegmentItemCell *cell = (MDSegmentItemCell *)[horizontalListView dequeueCellWithReusableIdentifier:NSStringFromClass([MDSegmentItemCell class])];
    if (!cell) cell = [[MDSegmentItemCell alloc] initWithReuseIdentifier:NSStringFromClass([MDSegmentItemCell class])];

    UIViewController *viewController = _viewControllers[index];
    cell.titleLabel.text = viewController.title;
    cell.titleLabel.font = _font;
    cell.textColor = _textColor;
    cell.selectedTextColor = _selectedTextColor;
    cell.fade = _fade;

    return cell;
}

- (BOOL)horizontalListView:(MDHorizontalListView *)horizontalListView shouldSelectCellAtIndex:(NSInteger)index {
    return [_container segmentControl:self shouldSelectAtIndex:index];
}

- (void)horizontalListView:(MDHorizontalListView *)horizontalListView didSelectCellAtIndex:(NSInteger)index {
    [_container segmentControl:self didSelectAtIndex:index];
}

#pragma mark - actions

- (IBAction)didSegmentValueChanged:(UISegmentedControl *)segmentedControl {
    NSUInteger index = segmentedControl.selectedSegmentIndex;
    BOOL shouldSelect = [_container segmentControl:self shouldSelectAtIndex:index];
    if (shouldSelect) {
        [_container segmentControl:self didSelectAtIndex:index];
    } else {
        segmentedControl.selectedSegmentIndex = _container.selectedIndex;
    }
}
@end

@interface MDSegmentController () <MDSegmentControlContainer, MDHorizontalListViewDelegate, UIScrollViewDelegate> {
    __weak id<MDSegmentControllerDelegate> _delegate;

    NSMutableArray<UIViewController *> *_viewControllers;
    NSMutableDictionary<NSNumber *, UIViewController *> *_preparedViewControllers;
    NSUInteger _selectedIndex;

    UIScrollView *_contentView;
    NSRecursiveLock *_lock;
}

@end

@implementation MDSegmentController

- (instancetype)initWithStyle:(MDSegmentControllerStyle)style {
    NSAssert(style >= 0 && style <= 3, @"Unsupport style with %lu", style);
    if (self = [super initWithNibName:nil bundle:nil]) {
        _style = style;

        [self initialize];
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:MDSegmentControllerStyleDefault];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithStyle:MDSegmentControllerStyleDefault];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithStyle:MDSegmentControllerStyleDefault];
}

- (void)initialize {
    self.automaticallyAdjustsScrollViewInsets = NO;

    _viewControllers = [NSMutableArray<UIViewController *> array];
    _preparedViewControllers = [NSMutableDictionary<NSNumber *, UIViewController *> dictionary];

    _bounces = YES;
    _segmentControlSize = CGSizeMake(0, MDSegmentControllerSegmentControlMinimumHeight);
    _lock = [[NSRecursiveLock alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _contentView.delegate = self;
    _contentView.pagingEnabled = YES;
    _contentView.showsVerticalScrollIndicator = NO;
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.contentSize = self.view.bounds.size;

    [self.view addSubview:_contentView];

    _segmentControl = [[MDSegmentControl alloc] initWithStyle:_style container:self];
    _segmentControl.viewControllers = _viewControllers;

    if (_style & MDSegmentControllerStyleEmbededTitleView) {
        self.navigationItem.titleView = _segmentControl;
    } else {
        [self.view addSubview:_segmentControl];
    }
    [self _loadDefaultSelectedViewController];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self _updateContentViewlayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self _updateContentViewlayout];
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
    _segmentControl.viewControllers = viewControllers;

    if (self.viewLoaded) [self _loadViewControllers];
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
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    [_lock lock];
    if (selectedIndex < _viewControllers.count && selectedIndex != _selectedIndex) {
        if (self.viewLoaded) {
            [self _prepareToSelectIndex:selectedIndex animated:animated];
        } else {
            _selectedIndex = selectedIndex;
        }
    }
    [_lock unlock];
}

- (void)setSegmentControlSize:(CGSize)segmentControlSize {
    [_lock lock];
    segmentControlSize.height = MAX(segmentControlSize.height, MDSegmentControllerSegmentControlMinimumHeight);
    _segmentControlSize = segmentControlSize;

    if (self.viewLoaded) [self _updateContentViewlayout];
    [_lock unlock];
}

- (UIView *)contentView {
    UIView *contentView = nil;
    [_lock lock];
    contentView = _contentView;
    [_lock unlock];
    return contentView;
}

- (void)setBounces:(BOOL)bounces {
    if (_bounces != bounces) {
        _bounces = bounces;

        _contentView.bounces = bounces;
        _segmentControl.horizontalListView.bounces = bounces;
    }
}

#pragma mark - private

- (void)_loadDefaultSelectedViewController {
    UIViewController *selectedViewController = self.selectedViewController;
    if (!selectedViewController) return;

    [self _loadViewController:selectedViewController atIndex:_selectedIndex];
}

- (void)_loadViewControllers {
    for (UIViewController *viewController in _viewControllers) {
        [viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }

    [_segmentControl _reloadData];
    [_segmentControl _selectAtIndex:_selectedIndex animated:NO];
    [self _loadDefaultSelectedViewController];
}

- (void)_unloadViewControllers {
    for (UIViewController *viewController in _viewControllers) {
        [viewController removeObserver:self forKeyPath:@"title"];
    }
    [self _reloadViewControllersAtIndexes:nil];
}

- (void)_reloadViewControllersAtIndexes:(NSIndexSet *)indexes {
    NSArray<UIViewController *> *viewControllers = [_viewControllers copy];
    NSDictionary<NSNumber *, UIViewController *> *preparedViewControllers = [_preparedViewControllers copy];

    [preparedViewControllers enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UIViewController *viewController, BOOL *stop) {
        if (![indexes containsIndex:key.unsignedIntegerValue]) {
            [viewController beginAppearanceTransition:NO animated:NO];

            [self _unloadViewController:viewController atIndex:key.unsignedIntegerValue];

            [viewController endAppearanceTransition];
        }
    }];

    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger index, BOOL *stop) {
        if ([indexes containsIndex:index] && ![preparedViewControllers.allKeys containsObject:@(index)]) {
            [viewController beginAppearanceTransition:YES animated:NO];

            [self _loadViewController:viewController atIndex:index];
        }
    }];
}

- (void)_prepareToSelectIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    UIViewController *viewController = _viewControllers[selectedIndex];
    BOOL shouldSelect = [self _shouldSelectViewController:viewController];
    if (!shouldSelect) return;

    [self _didSelectAtIndex:selectedIndex animated:animated];
}

- (void)_didSelectAtIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    _selectedIndex = selectedIndex;
    
    [self _selectAtIndex:selectedIndex animated:animated];
    [self _didSelectViewController:_viewControllers[selectedIndex]];
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

- (void)_loadViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if ([[_preparedViewControllers allKeys] containsObject:@(index)]) return;

    [viewController willMoveToParentViewController:self];

    [self addChildViewController:viewController];
    [self.contentView addSubview:viewController.view];
    [self _layoutViewController:viewController atIndex:index];

    [viewController didMoveToParentViewController:self];

    _preparedViewControllers[@(index)] = viewController;
}

- (void)_unloadViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    [viewController willMoveToParentViewController:nil];

    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];

    [viewController didMoveToParentViewController:nil];

    [_preparedViewControllers removeObjectForKey:@(index)];
}

- (void)_didFinishViewControllerAtIndex:(NSUInteger)index {
    UIViewController *viewController = _viewControllers[index];

    [viewController endAppearanceTransition];
}

- (void)_didUpdateViewControllerTitleAtIndex:(NSUInteger)index {
    [_segmentControl _reloadCellAtIndex:index animated:YES];
}

- (void)_updateContentViewlayout {
    UIEdgeInsets safeAreaInsets;
    if (@available(iOS 11, *)) {
         safeAreaInsets = self.view.safeAreaInsets;
    } else {
        UIRectEdge edge = self.edgesForExtendedLayout;

        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        UITabBar *tabBar = self.tabBarController.tabBar;

        BOOL extended = self.extendedLayoutIncludesOpaqueBars;
        BOOL translucentNavigationBar = navigationBar.barStyle == UIBarStyleBlackTranslucent;
        BOOL translucentTabBar = tabBar.barStyle == UIBarStyleBlackTranslucent;

        BOOL excludeNaivgationBar = (extended && translucentNavigationBar) || (edge & UIRectEdgeTop);
        BOOL excludeTabBar = (extended && translucentTabBar) || (edge & UIRectEdgeBottom);

        CGFloat navigationBarMaxY = navigationBar.hidden ? 0 : CGRectGetMaxY(navigationBar.frame);
        CGFloat tabBarHeight = tabBar.hidden ? 0 : CGRectGetHeight(tabBar.frame);

        CGFloat top = excludeNaivgationBar ? navigationBarMaxY : 0;
        CGFloat bottom = excludeTabBar ? tabBarHeight : 0;

        safeAreaInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
    }

    [self _updateContentViewlayoutWithInsets:safeAreaInsets];
}

- (void)_updateContentViewlayoutWithInsets:(UIEdgeInsets)insets {
    CGRect bounds = self.view.bounds;
    CGSize segmentSize = _segmentControlSize;

    if (_style & MDSegmentControllerStyleEmbededTitleView) {
        _segmentControl.frame = (CGRect){0, 0, segmentSize};
        _contentView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(insets.top, 0, insets.bottom, 0));
    } else {
        if (segmentSize.width == 0) segmentSize.width = CGRectGetWidth(bounds);

        _segmentControl.frame = (CGRect){(CGRectGetWidth(bounds) - segmentSize.width) / 2., insets.top, segmentSize};
        _contentView.frame = (CGRect){0, insets.top + segmentSize.height, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - insets.top - insets.bottom - segmentSize.height};
    }
    CGSize size = _contentView.frame.size;
    size.width *= _viewControllers.count;

    _contentView.contentSize = size;
    self.preferredContentSize = _contentView.frame.size;

    [_preparedViewControllers enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, UIViewController *viewController, BOOL *stop) {
        [self _layoutViewController:viewController atIndex:index.unsignedIntegerValue];
    }];

    [self _scrollToIndex:_selectedIndex animated:NO];
}

- (void)_layoutViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    CGFloat width = CGRectGetWidth(_contentView.frame);
    viewController.view.frame = (CGRect){width * index, 0, _contentView.frame.size};
}

- (void)_scrollWithOffset:(CGPoint)offset {
    CGFloat indexProgress = offset.x / CGRectGetWidth(_contentView.frame);

    CGFloat index1 = floor(indexProgress);
    CGFloat index2 = ceil(indexProgress);
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];

    if (index1 >= 0 && index1 < _viewControllers.count) {
        [indexes addIndex:index1];
    }
    if (index2 >= 0 && index2 < _viewControllers.count) {
        [indexes addIndex:index2];
    }
    [self _reloadViewControllersAtIndexes:indexes];

    if (!_contentView.dragging) return;
    [_segmentControl _selectIndexProgress:indexProgress animated:NO];
}

- (void)_scrollWillEndWithOffset:(CGPoint)offset {
    CGFloat indexProgress = offset.x / CGRectGetWidth(_contentView.frame);

    [_segmentControl _selectIndexProgress:indexProgress animated:YES];
}

- (void)_scrollDidEndWithOffset:(CGPoint)offset dragging:(BOOL)dragging {
    CGFloat x = offset.x;
    NSInteger index = x / CGRectGetWidth(_contentView.frame);

    if (dragging) {
        UIViewController *viewController = _viewControllers[index];
        BOOL shouldSelect = [self _shouldSelectViewController:viewController];

        index = shouldSelect ? index : _selectedIndex;
        if (shouldSelect) [self _reloadViewControllersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    }
    [self _didSelectAtIndex:index animated:YES];
    [self _didFinishViewControllerAtIndex:index];
}

- (void)_selectAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [_segmentControl _selectAtIndex:index animated:animated];
    [self _scrollToIndex:index animated:animated];
}

- (void)_scrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    CGPoint offset = CGPointMake(index * CGRectGetWidth(_contentView.frame), 0);

    [_contentView setContentOffset:offset animated:animated];
    [_segmentControl _scrollToIndex:index animated:animated];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) return;

    UIViewController *viewController = [object isKindOfClass:[UIViewController class]] ? object : nil;
    if (!viewController) return;

    NSUInteger index = [_viewControllers indexOfObject:viewController];
    if (index == NSNotFound) return;

    [self _didUpdateViewControllerTitleAtIndex:index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _contentView) [self _scrollWithOffset:scrollView.contentOffset];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == _contentView) [self _scrollWithOffset:scrollView.contentOffset];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == _contentView) [self _scrollWillEndWithOffset:*targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _contentView && !decelerate) [self _scrollDidEndWithOffset:scrollView.contentOffset dragging:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _contentView) [self _scrollDidEndWithOffset:scrollView.contentOffset dragging:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == _contentView) [self _scrollDidEndWithOffset:scrollView.contentOffset dragging:NO];
}

#pragma mark - MDSegmentControlContainer

- (BOOL)segmentControl:(MDSegmentControl *)segmentControl shouldSelectAtIndex:(NSUInteger)index {
    UIViewController *viewController = _viewControllers[index];
    return [self _shouldSelectViewController:viewController];
}

- (void)segmentControl:(MDSegmentControl *)segmentControl didSelectAtIndex:(NSUInteger)index {
    [self _scrollToIndex:index animated:YES];
}

@end
