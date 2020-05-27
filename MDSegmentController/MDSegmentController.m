//
//  MDSegmentController.m
//  MDSegmentController
//
//  Created by xulinfeng on 2018/8/27.
//  Copyright © 2018年 modool. All rights reserved.
//

#import <objc/runtime.h>
#import <MDHorizontalListView/MDHorizontalListView.h>

#import "MDSegmentController.h"

const CGFloat MDSegmentControllerAnimationDuration = .25f;

const CGFloat MDSegmentControllerSegmentControlMinimumHeight = 20.f;
const CGFloat MDSegmentControllerSegmentSpacingDynamic = CGFLOAT_MAX;

@interface _MDSegmentBadgeValueLabel : UILabel

@property (nonatomic, assign) CGSize minimumContentSize;

@property (nonatomic, assign) CGSize contentInset;

@end

@implementation _MDSegmentBadgeValueLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        self.contentInset = CGSizeMake(4, 2);
        self.minimumContentSize = CGSizeMake(8, 8);

        self.backgroundColor = [UIColor redColor];
        self.textAlignment = NSTextAlignmentCenter;

        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    CGFloat width = MIN(CGRectGetHeight([self bounds]), CGRectGetWidth([self bounds]));
    self.layer.cornerRadius = (width - 1) / 2.f;
}

- (CGSize)sizeByFitSize:(CGSize)size {
    NSUInteger length = self.attributedText ? self.attributedText.length : self.text.length;
    if (length) {
        size.height += self.contentInset.height;

        if (length == 1) {
            size.width = size.height;
        } else {
            size.width += self.contentInset.width;
        }
        size.width = MAX(size.width, size.height);
    } else {
        size = [self minimumContentSize];
    }
    return size;
}

#pragma mark - accessor

- (CGSize)intrinsicContentSize{
    if (!self.text && !self.attributedText) return CGSizeZero;

    CGSize size = [super intrinsicContentSize];
    size = [self sizeByFitSize:size];

    return size;
}

- (void)setText:(NSString *)text{
    [super setText:text];

    [self invalidateIntrinsicContentSize];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];

    [self invalidateIntrinsicContentSize];
}

- (void)setContentInset:(CGSize)contentInset{
    _contentInset = contentInset;

    [self invalidateIntrinsicContentSize];
}

- (void)setMinimumContentSize:(CGSize)minimumContentSize{
    _minimumContentSize = minimumContentSize;

    [self invalidateIntrinsicContentSize];
}

@end

@protocol MDSegmentItemDelegate <NSObject>

- (void)segmentItem:(MDSegmentItem *)segmentItem didUpdateAbility:(BOOL)enabled;

- (void)segmentItemDidRequireToReload:(MDSegmentItem *)segmentItem;
- (void)segmentItemDidUpdateContnet:(MDSegmentItem *)segmentItem;

@end

@interface MDSegmentItem () {
    UIColor *_badgeColor;
    NSMutableDictionary *_badgeValueAttributes;
}

@property (nonatomic, weak) id<MDSegmentItemDelegate> delegate;

@end

@implementation MDSegmentItem
@dynamic enabled, landscapeImagePhone, largeContentSizeImage, landscapeImagePhoneInsets, largeContentSizeImageInsets;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    MDSegmentItem *item = [super allocWithZone:zone];
    item->_badgeValueAttributes = [NSMutableDictionary dictionary];

    return item;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];

    [_delegate segmentItem:self didUpdateAbility:enabled];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];

    [_delegate segmentItemDidUpdateContnet:self];
}

- (void)setTitleAttributeString:(NSAttributedString *)titleAttributeString {
    if (_titleAttributeString != titleAttributeString) {
        _titleAttributeString = titleAttributeString;

        [_delegate segmentItemDidRequireToReload:self];
    }
}

- (void)setSelectedTitleAttributeString:(NSAttributedString *)selectedTitleAttributeString {
    if (_selectedTitleAttributeString != selectedTitleAttributeString) {
        _selectedTitleAttributeString = selectedTitleAttributeString;

        [_delegate segmentItemDidUpdateContnet:self];
    }
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];

    [_delegate segmentItemDidRequireToReload:self];
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    [super setSelectedImage:selectedImage];

    [_delegate segmentItemDidUpdateContnet:self];
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state {
    [super setTitleTextAttributes:attributes forState:state];

    [_delegate segmentItemDidUpdateContnet:self];
}

- (void)setTitlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    [super setTitlePositionAdjustment:titlePositionAdjustment];

    [_delegate segmentItemDidUpdateContnet:self];
}

- (void)setImageInsets:(UIEdgeInsets)imageInsets {
    [super setImageInsets:imageInsets];

    [_delegate segmentItemDidUpdateContnet:self];
}

- (UIColor *)badgeColor {
    return _badgeColor;
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    if (_badgeColor != badgeColor) {
        _badgeColor = badgeColor;

        [_delegate segmentItemDidUpdateContnet:self];
    }
}

- (void)setBadgeValue:(NSString *)badgeValue {
    [super setBadgeValue:badgeValue];

    [_delegate segmentItemDidUpdateContnet:self];
}

- (NSDictionary<NSAttributedStringKey,id> *)badgeTextAttributesForState:(UIControlState)state {
    return _badgeValueAttributes[@(state)];
}

- (void)setBadgeTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)textAttributes forState:(UIControlState)state {
    if (textAttributes) _badgeValueAttributes[@(state)] = textAttributes;
    else [_badgeValueAttributes removeObjectForKey:@(state)];

    [_delegate segmentItemDidUpdateContnet:self];
}

- (void)setBadgeValueContentInset:(CGRect)badgeValueContentInset {
    _badgeValueContentInset = badgeValueContentInset;

    [_delegate segmentItemDidUpdateContnet:self];
}

@end

@class _MDSegmentItemCell;
@protocol _MDSegmentItemCellDelegate <NSObject>

- (void)_segmentItemCellDidRequireToReload:(_MDSegmentItemCell *)segmentItemCell;

@end

@interface _MDSegmentItemCell : MDHorizontalListViewCell <MDSegmentItemDelegate>

@property (nonatomic, weak) id<_MDSegmentItemCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *selectedBckgroundView;

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIImageView *selectedImageView;

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *selectedTitleLabel;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, strong, readonly) _MDSegmentBadgeValueLabel *badgeValueLabel;
@property (nonatomic, strong, readonly) _MDSegmentBadgeValueLabel *selectedBadgeValueLabel;

@property (nonatomic, strong) MDSegmentItem *item;

@property (nonatomic, assign) BOOL fade;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) CGFloat progress;

@end

@implementation _MDSegmentItemCell
@dynamic index;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {

        _backgroundView = [[UIView alloc] init];
        _selectedBckgroundView = [[UIView alloc] init];

        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;

        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.contentMode = UIViewContentModeCenter;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;

        _selectedTitleLabel = [[UILabel alloc] init];
        _selectedTitleLabel.textAlignment = NSTextAlignmentCenter;

        _badgeValueLabel = [[_MDSegmentBadgeValueLabel alloc] init];
        _selectedBadgeValueLabel = [[_MDSegmentBadgeValueLabel alloc] init];

        [_backgroundView addSubview:_imageView];
        [_backgroundView addSubview:_titleLabel];
        [_backgroundView addSubview:_badgeValueLabel];

        [_selectedBckgroundView addSubview:_selectedImageView];
        [_selectedBckgroundView addSubview:_selectedTitleLabel];
        [_selectedBckgroundView addSubview:_selectedBadgeValueLabel];

        [self.contentView addSubview:_backgroundView];
        [self.contentView addSubview:_selectedBckgroundView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self _layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _item = nil;
}

#pragma mark - accessor

- (void)setItem:(MDSegmentItem *)item {
    if (_item != item) {
        if (_item) _item.delegate = nil;

        _item = item;

        if (item) item.delegate = self;

        [self _reloadContent];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    _backgroundView.alpha = !selected;
    _selectedBckgroundView.alpha = selected;
}

- (void)willSelectAtProgress:(CGFloat)progress animated:(BOOL)animated {
    [super willSelectAtProgress:progress animated:animated];

    if (!_fade) return;
    if (_progress == progress) return;

    _progress = progress;

    void (^transform)(void) = ^{
        _backgroundView.alpha = (1 - progress);
        _selectedBckgroundView.alpha = progress;
    };

    if (animated) {
        [UIView animateWithDuration:MDSegmentControllerAnimationDuration animations:transform];
    } else {
        transform();
    }
}

#pragma mark - private

- (void)_reloadContent {
    [self _updateContentView];
    [self _layoutSubviews];
}

- (void)_layoutSubviews {
    CGRect bounds = self.contentView.bounds;
    _backgroundView.frame = bounds;
    _selectedBckgroundView.frame = bounds;

    [self _layoutImageWithContentSize:bounds.size insets:_item.imageInsets];
    [self _layoutTitleWithContentSize:bounds.size offset:_item.titlePositionAdjustment];
    [self _layoutBadgeValueWithContentSize:bounds.size offset:_item.badgeValueContentInset.origin];
}

- (void)_updateContentView {
    self.userInteractionEnabled = _item.enabled;

    [self _updateImageView];
    [self _updateTitleLabel];
    [self _updateBadgeValueLabel];
}

- (void)_updateImageView {
    _imageView.image = _item.image;
    _selectedImageView.image = _item.selectedImage ?: _item.image;
}

- (void)_updateTitleLabel {
    [self _updateTitleLabelForState:UIControlStateNormal];
    [self _updateTitleLabelForState:UIControlStateSelected];
}

- (void)_updateTitleLabelForState:(UIControlState)state {
    BOOL selected = state == UIControlStateSelected;

    UILabel *label = selected ? _selectedTitleLabel : _titleLabel;
    NSAttributedString *attributedString = selected ? [_item selectedTitleAttributeString] : [_item titleAttributeString];
    if (!attributedString) {
        NSMutableDictionary *attributes = [[_item titleTextAttributesForState:state] ?: @{} mutableCopy];
        
        UIFont *font = attributes[NSFontAttributeName];
        UIColor *textColor = attributes[NSForegroundColorAttributeName];
        
        if (!font) attributes[NSFontAttributeName] = _font ?: [UIFont systemFontOfSize:8];
        if (!textColor) attributes[NSForegroundColorAttributeName] = (selected ? _selectedTextColor : _textColor) ?: [UIColor whiteColor];

        attributedString = _item.title ? [[NSAttributedString alloc] initWithString:_item.title attributes:attributes] : nil;
    }
    label.attributedText = attributedString;
}

- (void)_updateBadgeValueLabel {
    [self _updateBadgeValueLabelForState:UIControlStateNormal];
    [self _updateBadgeValueLabelForState:UIControlStateSelected];
}

- (void)_updateBadgeValueLabelForState:(UIControlState)state {
    _MDSegmentBadgeValueLabel *label = state == UIControlStateNormal ? _badgeValueLabel : _selectedBadgeValueLabel;

    NSMutableDictionary *attributes = [[_item badgeTextAttributesForState:state] ?: @{} mutableCopy];

    UIFont *font = attributes[NSFontAttributeName];
    UIColor *textColor = attributes[NSForegroundColorAttributeName];

    if (!font) attributes[NSFontAttributeName] = [UIFont systemFontOfSize:8];
    if (!textColor) attributes[NSForegroundColorAttributeName] = _item.badgeColor ?: [UIColor whiteColor];

    label.contentInset = _item.badgeValueContentInset.size;
    label.backgroundColor = attributes[NSBackgroundColorAttributeName] ?: [UIColor redColor];
    label.attributedText = _item.badgeValue ? [[NSAttributedString alloc] initWithString:_item.badgeValue attributes:attributes] : nil;
}

- (void)_layoutBadgeValueWithContentSize:(CGSize)contentSize offset:(CGPoint)offset {
    [self _layoutBadgeValueWithContentSize:contentSize offset:offset state:UIControlStateNormal];
    [self _layoutBadgeValueWithContentSize:contentSize offset:offset state:UIControlStateSelected];
}

- (void)_layoutBadgeValueWithContentSize:(CGSize)contentSize offset:(CGPoint)offset state:(UIControlState)state {
    UILabel *titleLabel = state == UIControlStateNormal ? _titleLabel : _selectedTitleLabel;
    _MDSegmentBadgeValueLabel *badgeValueLabel = state == UIControlStateNormal ? _badgeValueLabel : _selectedBadgeValueLabel;

    CGSize size = [badgeValueLabel intrinsicContentSize];
    CGPoint origin = CGPointMake(CGRectGetMaxX(titleLabel.frame), CGRectGetMinY(titleLabel.frame) - size.height);
    if ((origin.x + size.width) > contentSize.width) {
        origin.x = contentSize.width - size.width;
        origin.x = MAX(0, origin.x);

        size.width = MIN(size.width, contentSize.width - origin.x);
    }
    if ((origin.y - size.height) < 0) {
        origin.y = 0;

        size.height = MIN(size.height, contentSize.height);
    }
    
    origin.x += offset.x;
    origin.y += offset.y;

    badgeValueLabel.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
}

- (void)_layoutTitleWithContentSize:(CGSize)contentSize offset:(UIOffset)offset {
    CGSize size = [_titleLabel sizeThatFits:contentSize];
    CGRect titleFrame = CGRectMake(contentSize.width / 2 - size.width / 2., contentSize.height / 2 - size.height / 2., size.width, size.height);

    titleFrame = CGRectOffset(titleFrame, offset.horizontal, offset.vertical);
    _titleLabel.frame = titleFrame;

    size = [_selectedTitleLabel sizeThatFits:contentSize];
    titleFrame = CGRectMake(contentSize.width / 2 - size.width / 2., contentSize.height / 2 - size.height / 2., size.width, size.height);

    titleFrame = CGRectOffset(titleFrame, offset.horizontal, offset.vertical);
    _selectedTitleLabel.frame = titleFrame;
}

- (void)_layoutImageWithContentSize:(CGSize)contentSize insets:(UIEdgeInsets)insets {
    CGRect imageFrame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    imageFrame = UIEdgeInsetsInsetRect(imageFrame, insets);

    _imageView.frame = imageFrame;
    _selectedImageView.frame = imageFrame;
}

#pragma mark - MDSegmentItemDelegate

- (void)segmentItem:(MDSegmentItem *)segmentItem didUpdateAbility:(BOOL)enabled {
    self.userInteractionEnabled = enabled;
}

- (void)segmentItemDidRequireToReload:(MDSegmentItem *)segmentItem {
    [_delegate _segmentItemCellDidRequireToReload:self];
}

- (void)segmentItemDidUpdateContnet:(MDSegmentItem *)segmentItem {
    [self _reloadContent];
}

@end

@protocol _MDSegmentControlContainer <NSObject>

@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

- (NSUInteger)_numberOfTitlesForSegmentControl:(MDSegmentControl *)segmentControl;
- (NSString *)_segmentControl:(MDSegmentControl *)segmentControl titleAtIndex:(NSUInteger)index;

- (BOOL)_segmentControl:(MDSegmentControl *)segmentControl shouldSelectAtIndex:(NSUInteger)index;
- (void)_segmentControl:(MDSegmentControl *)segmentControl didSelectAtIndex:(NSUInteger)index;

@optional
- (MDSegmentItem *)_segmentControl:(MDSegmentControl *)segmentControl itemAtIndex:(NSUInteger)index;

@end

@interface MDSegmentControl () <MDHorizontalListViewDataSource, MDHorizontalListViewDelegate, _MDSegmentItemCellDelegate> {
    CGFloat _spacing;
    CGFloat _actualSpacing;
}

@property (nonatomic, weak, readonly) id<_MDSegmentControlContainer> container;

@property (nonatomic, assign, readonly) MDSegmentControllerStyle style;
@property (nonatomic, strong, readonly) MDHorizontalListView *horizontalListView;
@property (nonatomic, strong, readonly) UISegmentedControl *segmentControl;

@end

@implementation MDSegmentControl
@dynamic tintColor;

- (instancetype)initWithStyle:(MDSegmentControllerStyle)style container:(id<_MDSegmentControlContainer>)container {
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
            _horizontalListView.highlightEnabled = NO;
            _horizontalListView.allowsNoneSelection = NO;
            _horizontalListView.allowsMultipleSelection = NO;
            _horizontalListView.indexProgressSynchronous = NO;
            _horizontalListView.selectionStyle = MDHorizontalListViewCellSelectionStyleNone;

            if (@available(iOS 11, *)) {
                _horizontalListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }

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
    
    [self _updateContentViewLayout];
    [self _updateSpacing];
    [self _selectAtIndex:_container.selectedIndex animated:NO];
}

#pragma mark - accessor

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self _updateContentViewLayout];
}

- (void)setItemWidth:(CGFloat)itemWidth {
    if (_itemWidth != itemWidth) {
        _itemWidth = itemWidth;
        
        [self _reloadData];
    }
}

- (void)setItemHorizontalInset:(CGFloat)itemWidthInset {
    if (_itemWidthInset != itemWidthInset) {
        _itemWidthInset = itemWidthInset;

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
    }
}

- (CGFloat)spacing {
    return _spacing;
}

- (void)setMinimumSpacing:(CGFloat)minimumSpacing {
    if (_minimumSpacing != minimumSpacing) {
        _minimumSpacing = minimumSpacing;
        
        [self _updateSpacing];
    }
}

- (void)setScrollContentInset:(UIEdgeInsets)scrollContentInset {
    _scrollContentInset = scrollContentInset;
    
    [self _updateSpacing];
}

- (UIView *)contentView {
    BOOL segmentControl = (_style & MDSegmentControllerStyleSegmentControl);
    return segmentControl ? _segmentControl : _horizontalListView;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    
    [self setNeedsLayout];
}

- (void)setHomodisperse:(BOOL)homodisperse {
    if (_homodisperse != homodisperse) {
        _homodisperse = homodisperse;
        
        [self _updateSpacing];
    }
}

- (void)setIndicatorEnabled:(BOOL)indicatorEnabled {
    _horizontalListView.indicatorEnabled = indicatorEnabled;
}

- (BOOL)isIndicatorEnabled {
    return _horizontalListView.indicatorEnabled;
}

- (UIView *)indicatorView {
    return _horizontalListView.indicatorView;
}

- (void)setIndicatorInset:(UIEdgeInsets)indicatorInset {
    _horizontalListView.indicatorInset = indicatorInset;
}

- (UIEdgeInsets)indicatorInset {
    return _horizontalListView.indicatorInset;
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

- (void)_updateContentViewLayout {
    self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, _contentInset);
}

- (void)_updateSpacing {
    if (_style & MDSegmentControllerStyleSegmentControl) return;
    
    CGFloat spacing = _minimumSpacing;
    CGFloat width = [self _overallWidth];
    CGFloat contentWidth = CGRectGetWidth(_horizontalListView.frame);
    
    BOOL dynamic = _spacing == MDSegmentControllerSegmentSpacingDynamic;
    if (!dynamic) spacing = _spacing;
    
    UIEdgeInsets inset = _scrollContentInset;
    CGFloat offset = inset.left + inset.right;

    NSUInteger numberOfTitles = [self _numberOfTitles];
    CGFloat length = width + spacing * (numberOfTitles - 1) + offset;

    BOOL over = length <= contentWidth && numberOfTitles;
    if (dynamic && over) {
        if (_homodisperse) {
            spacing = (contentWidth - width - offset) / numberOfTitles;
            inset.left += spacing / 2.;
            inset.right += spacing / 2.;
        } else {
            spacing = (contentWidth - width - offset) / (numberOfTitles - 1);
        }
    } else if (over && _homodisperse) {
        CGFloat insetWidth = (contentWidth - length) / 2;
        inset.left += insetWidth;
        inset.right += insetWidth;
    }
    
    _actualSpacing = spacing;
    
    _horizontalListView.contentInset = inset;
    _horizontalListView.cellSpacing = _actualSpacing;
}

- (CGFloat)_overallWidth {
    NSUInteger numberOfTitles = [self _numberOfTitles];
    if (_itemWidth != 0) return numberOfTitles * (_itemWidth + _itemWidthInset);
    
    CGFloat width = 0;
    for (int index = 0; index < numberOfTitles; index++) {
        width += [self _widthAtIndex:index];
    }
    return width;
}

- (NSUInteger)_numberOfTitles {
    return [_container _numberOfTitlesForSegmentControl:self];
}

- (MDSegmentItem *)_itemAtIndex:(NSUInteger)index {
    MDSegmentItem *item = nil;
    if ([_container respondsToSelector:@selector(_segmentControl:itemAtIndex:)]) {
        item = [_container _segmentControl:self itemAtIndex:index];
    }
    NSAssert(!item || [item isKindOfClass:MDSegmentItem.class], @"Item must be instance of MDSegmentItem");

    if (item) return item;

    NSString *title = [_container _segmentControl:self titleAtIndex:index];
    NSDictionary *attributes = [self _titleAttributesForSelected:NO];
    NSDictionary *selectedAttributes = [self _titleAttributesForSelected:YES];

    item = [[MDSegmentItem alloc] initWithTitle:title image:nil selectedImage:nil];
    item.badgeValueContentInset = CGRectMake(0, 0, 4, 2);

    [item setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];

    return item;
}

- (NSDictionary *)_titleAttributesForSelected:(BOOL)selected {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = _font ?: [UIFont systemFontOfSize:[UIFont labelFontSize]];

    if (selected && _selectedTextColor) attributes[NSForegroundColorAttributeName] = _selectedTextColor;
    else if (_textColor) attributes[NSForegroundColorAttributeName] = _textColor;

    return [attributes copy];
}

- (CGFloat)_widthAtIndex:(NSUInteger)index {
    MDSegmentItem *item = [self _itemAtIndex:index];
    return [self _widthForItem:item];
}

- (CGFloat)_widthForItem:(MDSegmentItem *)item {
    CGFloat imageWidth = item.image.size.width;
    
    CGSize size = _horizontalListView.bounds.size;

    NSAttributedString *attributedString = item.titleAttributeString;
    if (!attributedString) {
        NSDictionary *attributes = [item titleTextAttributesForState:UIControlStateNormal];
        attributedString = [[NSAttributedString alloc] initWithString:item.title ?: @"" attributes:attributes];
    }
    CGFloat titleWidth = [attributedString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;

    return MAX(imageWidth, titleWidth) + _itemWidthInset;
}

- (void)_updateIndexProgressAnimated:(BOOL)animated {
    CGFloat indexProgress = _horizontalListView.indexProgress;

    [self _updateIndexProgress:indexProgress animated:animated];
    [self _scrollToIndexProgress:indexProgress animated:animated];
}

- (void)_updateIndexProgress:(CGFloat)indexProgress animated:(BOOL)animated {
    if (_style & MDSegmentControllerStyleSegmentControl) return;

    [_horizontalListView setIndexProgress:indexProgress animated:animated];
}

- (void)_scrollToIndexProgress:(CGFloat)indexProgress animated:(BOOL)animated {
    if (_style & MDSegmentControllerStyleSegmentControl) return;

    [_horizontalListView scrollToIndexProgress:indexProgress animated:animated nearestPosition:MDHorizontalListViewPositionCenter];
}

- (BOOL)_selectAtIndex:(NSInteger)index animated:(BOOL)animated {
    BOOL success = YES;
    if (_style & MDSegmentControllerStyleSegmentControl) {
        _segmentControl.selectedSegmentIndex = index;
    } else {
        success = [_horizontalListView selectCellAtIndex:index animated:animated];
        if (success) {
            [self _updateIndexProgress:index animated:animated];
            [self _scrollToIndexProgress:index animated:animated];
        }
    }
    return success;
}

- (void)_reloadCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (_style & MDSegmentControllerStyleSegmentControl) {
        NSString *title = [_container _segmentControl:self titleAtIndex:index];
        [_segmentControl setTitle:title forSegmentAtIndex:index];
    } else {
        [_horizontalListView reloadCellAtIndex:index animated:animated];
        
        [self _updateSpacing];
        [self _updateIndexProgressAnimated:animated];
    }
}

- (void)_reloadData {
    [self _updateSpacing];
    
    if (_style & MDSegmentControllerStyleSegmentControl) {
        UIColor *color = _textColor ?: [UIColor grayColor];
        UIColor *selectedColor = _selectedTextColor ?: color;
        UIFont *font = _font ?: [UIFont systemFontOfSize:[UIFont labelFontSize]];
        
        NSDictionary *noramlAttributes = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
        [_segmentControl setTitleTextAttributes:noramlAttributes forState:UIControlStateNormal];
        
        NSDictionary *selectedAttributes = @{NSForegroundColorAttributeName: selectedColor, NSFontAttributeName: font};
        [_segmentControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        
        [_segmentControl removeAllSegments];

        NSUInteger numberOfTitles = [self _numberOfTitles];
        for (int index = 0; index < numberOfTitles; index++) {
            MDSegmentItem *item = [self _itemAtIndex:index];

            [self _insertSegmentItem:item atIndex:index];
        }
    } else {
        [_horizontalListView reloadData];
    }
    [self _selectAtIndex:_container.selectedIndex animated:NO];
}

- (void)_insertSegmentItem:(MDSegmentItem *)item atIndex:(NSUInteger)index {
    if (item.image) {
        [_segmentControl insertSegmentWithImage:item.image atIndex:index animated:NO];
    } else {
        [_segmentControl insertSegmentWithTitle:item.title atIndex:index animated:NO];
    }
}

- (BOOL)_shouldSelectAtIndex:(NSUInteger)index {
    return [_container _segmentControl:self shouldSelectAtIndex:index];
}

- (void)_didSelectAtIndex:(NSUInteger)index {
    [_container _segmentControl:self didSelectAtIndex:index];
    
    if ([_delegate respondsToSelector:@selector(segmentControl:didSelectAtIndex:)]) {
        [_delegate segmentControl:self didSelectAtIndex:index];
    }
}

#pragma mark - MDHorizontalListViewDelegate, MDHorizontalListViewDataSource

- (NSInteger)horizontalListViewNumberOfCells:(MDHorizontalListView *)horizontalListView {
    return [self _numberOfTitles];
}

- (CGFloat)horizontalListView:(MDHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index {
    if (_itemWidth != 0) return _itemWidth + _itemWidthInset;

    return [self _widthAtIndex:index];
}

- (MDHorizontalListViewCell *)horizontalListView:(MDHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index {
    _MDSegmentItemCell *cell = (_MDSegmentItemCell *)[horizontalListView dequeueCellWithReusableIdentifier:NSStringFromClass([_MDSegmentItemCell class])];
    if (!cell) cell = [[_MDSegmentItemCell alloc] initWithReuseIdentifier:NSStringFromClass([_MDSegmentItemCell class])];

    MDSegmentItem *item = [self _itemAtIndex:index];

    cell.font = _font;
    cell.textColor = _textColor;
    cell.selectedTextColor = _selectedTextColor;
    
    cell.delegate = self;
    cell.fade = _fade;
    cell.item = item;
    
    return cell;
}

- (BOOL)horizontalListView:(MDHorizontalListView *)horizontalListView shouldSelectCellAtIndex:(NSInteger)index {
    return [self _shouldSelectAtIndex:index];
}

- (void)horizontalListView:(MDHorizontalListView *)horizontalListView didSelectCellAtIndex:(NSInteger)index {
    [self _didSelectAtIndex:index];
}

#pragma mark - _MDSegmentItemCellDelegate

- (void)_segmentItemCellDidRequireToReload:(_MDSegmentItemCell *)segmentItemCell {
    [self _reloadCellAtIndex:segmentItemCell.index animated:NO];
}

#pragma mark - actions

- (IBAction)didSegmentValueChanged:(UISegmentedControl *)segmentedControl {
    NSUInteger index = segmentedControl.selectedSegmentIndex;
    BOOL shouldSelect = [self _shouldSelectAtIndex:index];
    if (shouldSelect) {
        [self _didSelectAtIndex:index];
    } else {
        segmentedControl.selectedSegmentIndex = _container.selectedIndex;
    }
}
@end

@interface _MDSegmentControllerContentView : UIView
@end
@implementation _MDSegmentControllerContentView
@end

@interface _MDSegmentControllerScrollView : UIScrollView
@end
@implementation _MDSegmentControllerScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.pagingEnabled = YES;
        self.contentInset = UIEdgeInsetsZero;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;

        if (@available(iOS 11, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")];
}

@end

@interface UIViewController (MDSegmentControllerPrivate)

@property (nonatomic, weak) MDSegmentController *segmentController;

@end

@implementation UIViewController (MDSegmentControllerPrivate)

- (MDSegmentController *)segmentController {
    return objc_getAssociatedObject(self, @selector(segmentController));
}

- (void)setSegmentController:(MDSegmentController *)segmentController {
    objc_setAssociatedObject(self, @selector(segmentController), segmentController, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIViewController (MDSegmentController)
@dynamic segmentController;

- (MDSegmentItem *)segmentItem {
    return objc_getAssociatedObject(self, @selector(segmentItem));
}

- (void)setSegmentItem:(MDSegmentItem *)segmentItem {
    [self willChangeValueForKey:NSStringFromSelector(@selector(segmentItem))];
    objc_setAssociatedObject(self, @selector(segmentItem), segmentItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(segmentItem))];
}

@end

@interface MDSegmentController () <_MDSegmentControlContainer, MDHorizontalListViewDelegate, UIScrollViewDelegate> {
    @protected
    __weak id<MDSegmentControllerDelegate> _delegate;

    NSMutableArray<UIViewController *> *_viewControllers;
    NSMutableDictionary<NSNumber *, UIViewController *> *_preparedViewControllers;
    NSUInteger _selectedIndex;

    UIView *_contentView;
    UIView *_wrapperView;
    UIScrollView *_scrollView;
    NSRecursiveLock *_lock;

    CGSize _segmentControlSize;
    BOOL _reusingWhenResetViewControllers;
    BOOL _scrollingEnabled;
}

@end

@implementation MDSegmentController

- (instancetype)initWithStyle:(MDSegmentControllerStyle)style {
    NSAssert(style >= 0 && style <= 3, @"Unsupport style with %lu", (unsigned long)style);
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
    _lock = [[NSRecursiveLock alloc] init];
    _viewControllers = [NSMutableArray<UIViewController *> array];
    _preparedViewControllers = [NSMutableDictionary<NSNumber *, UIViewController *> dictionary];

    _bounces = YES;
    _automaticallyAdjustsContentViewInsets = YES;
    _contentInset = UIEdgeInsetsZero;
    _segmentControlSize = CGSizeMake(0, MDSegmentControllerSegmentControlMinimumHeight);

    _contentView = [[_MDSegmentControllerContentView alloc] initWithFrame:CGRectZero];

    _wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    _scrollView = [[_MDSegmentControllerScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.delegate = self;

    _segmentControl = [[MDSegmentControl alloc] initWithStyle:_style container:self];
}

- (void)loadView {
    [super loadView];

    [self.view addSubview:_contentView];
    [self.view addSubview:_wrapperView];
    [_wrapperView addSubview:_scrollView];

    if (_style & MDSegmentControllerStyleEmbededTitleView) {
        self.navigationItem.titleView = _segmentControl;
    } else {
        [self.view addSubview:_segmentControl];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self _excuteInTransaction:^{
        [self _updateContentViewlayout];
        [self _loadSelectedViewController];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self _excuteInTransaction:^{
        [self _updateContentViewlayout];
    }];
    if (_viewControllers.count) [self _selectAtIndex:_selectedIndex animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self _excuteInTransaction:^{
        [self _updateContentViewlayout];
    }];
    if (_viewControllers.count) [self _selectAtIndex:_selectedIndex animated:NO];
}

- (void)dealloc {
    [self _removeObservers];
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

- (void)setReusingWhenResetViewControllers:(BOOL)reusingWhenResetViewControllers {
    [_lock lock];
    _reusingWhenResetViewControllers = reusingWhenResetViewControllers;
    [_lock unlock];
}

- (BOOL)isReusingWhenResetViewControllers {
    BOOL reusingWhenResetViewControllers = NO;
    [_lock lock];
    reusingWhenResetViewControllers = _reusingWhenResetViewControllers;
    [_lock unlock];
    return reusingWhenResetViewControllers;
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
    if (_selectedIndex >= viewControllers.count) _selectedIndex = 0;

    UIViewController *currentViewController = _selectedIndex < _viewControllers.count ? _viewControllers[_selectedIndex] : nil;
    UIViewController *viewController = _selectedIndex < viewControllers.count ? viewControllers[_selectedIndex] : nil;
    BOOL reusing = _reusingWhenResetViewControllers && currentViewController && currentViewController == viewController;

    UIView.animationsEnabled = NO;
    if (reusing) {
        [self _unloadViewControllersForReusing];
    } else {
        [self _unloadViewControllers];
    }
    _viewControllers.array = viewControllers;

    if (reusing) {
        [self _loadViewControllersForReusing];
    } else {
        [self _loadViewControllers];
    }
    UIView.animationsEnabled = YES;
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
            [self _updateSelectedIndex:selectedIndex];
        }
    }
    [_lock unlock];
}

- (NSUInteger)selectedIndex {
    NSUInteger selectedIndex = 0;
    [_lock lock];
    selectedIndex = _selectedIndex;
    [_lock unlock];
    return selectedIndex;
}

- (void)setSegmentControlSize:(CGSize)segmentControlSize {
    [_lock lock];
    segmentControlSize.height = MAX(segmentControlSize.height, MDSegmentControllerSegmentControlMinimumHeight);
    _segmentControlSize = segmentControlSize;
    
    if (self.viewLoaded) [self _updateContentViewlayout];
    [_lock unlock];
}

- (CGSize)segmentControlSize {
    CGSize segmentControlSize = CGSizeZero;
    [_lock lock];
    segmentControlSize = _segmentControlSize;
    [_lock unlock];
    return segmentControlSize;
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

        _scrollView.bounces = bounces;
        _segmentControl.horizontalListView.bounces = bounces;
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)isScrollEnabled {
    return _scrollView.scrollEnabled;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures {
    return self.selectedViewController;
}

- (BOOL)shouldAutorotate {
    UIViewController *selectedViewController = self.selectedViewController;
    return selectedViewController ? selectedViewController.shouldAutorotate : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *selectedViewController = self.selectedViewController;
    return selectedViewController ? selectedViewController.supportedInterfaceOrientations : UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *selectedViewController = self.selectedViewController;
    return selectedViewController ? selectedViewController.preferredInterfaceOrientationForPresentation : UIInterfaceOrientationPortrait;
}

#pragma mark - private

- (void)_updateSelectedIndex:(NSUInteger)selectedIndex {
    [self willChangeValueForKey:NSStringFromSelector(@selector(selectedIndex))];
    _selectedIndex = selectedIndex;
    [self didChangeValueForKey:NSStringFromSelector(@selector(selectedIndex))];
}

- (void)_excuteInTransaction:(void (^)(void))block {
    _scrollingEnabled = NO;
    if (block) block();
    _scrollingEnabled = YES;
}

- (void)_reloadData {
    if (_selectedIndex >= _viewControllers.count) return;

    [_segmentControl _reloadData];
    [self _loadSelectedViewController];
    [self _selectAtIndex:_selectedIndex animated:NO];
}

- (void)_loadSelectedViewController {
    UIViewController *selectedViewController = self.selectedViewController;
    if (!selectedViewController) return;

    BOOL lessThan11 = [[[UIDevice currentDevice] systemVersion] floatValue] < 11.f;
    BOOL appeared = self.view.window != nil;

    if (lessThan11 && appeared) [selectedViewController beginAppearanceTransition:YES animated:NO];

    [self _loadViewController:selectedViewController atIndex:_selectedIndex];

    if (lessThan11 && appeared) [selectedViewController endAppearanceTransition];
}

- (void)_unloadViewControllers {
    [self _removeObservers];

    [self _updateContentViewlayout];
    [self _reloadViewControllersAtIndexes:nil];
}

- (void)_loadViewControllers {
    [self _addObservers];

    if (self.viewLoaded) {
        [self _updateContentViewlayout];
        [self _reloadData];
    }
}

- (void)_unloadViewControllersForReusing {
    [self _removeObservers];
}

- (void)_loadViewControllersForReusing {
    [self _addObservers];

    if (self.viewLoaded) {
        [self _updateContentViewlayout];

        [_segmentControl _reloadData];
        [self _selectAtIndex:_selectedIndex animated:NO];
    }
}

- (void)_addObservers {
    for (UIViewController *viewController in _viewControllers) {
        [self _addObserversForViewController:viewController];
    }
}

- (void)_removeObservers {
    for (UIViewController *viewController in _viewControllers) {
        [self _removeObserversForViewController:viewController];
    }
}

- (void)_addObserversForViewController:(UIViewController *)viewController {
    [viewController addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:NSKeyValueObservingOptionNew context:NULL];
    [viewController addObserver:self forKeyPath:NSStringFromSelector(@selector(segmentItem)) options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)_removeObserversForViewController:(UIViewController *)viewController {
    [viewController removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
    [viewController removeObserver:self forKeyPath:NSStringFromSelector(@selector(segmentItem))];
}

- (void)_reloadViewControllersAtIndexes:(NSIndexSet *)indexes {
    NSArray<UIViewController *> *viewControllers = [_viewControllers copy];
    NSDictionary<NSNumber *, UIViewController *> *preparedViewControllers = [_preparedViewControllers copy];
    
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger index, BOOL *stop) {
        if ([indexes containsIndex:index] && ![preparedViewControllers.allKeys containsObject:@(index)]) {
            [self _loadViewController:viewController atIndex:index];
        } else if (![indexes containsIndex:index] && [preparedViewControllers.allKeys containsObject:@(index)]) {
            if (index != _selectedIndex) [viewController beginAppearanceTransition:NO animated:NO];
            [self _unloadViewController:viewController atIndex:index];
        }
    }];
}

- (void)_prepareToSelectIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    UIViewController *viewController = _viewControllers[selectedIndex];
    BOOL shouldSelect = [self _shouldSelectViewController:viewController];
    if (!shouldSelect) return;

    [self _selectAtIndex:selectedIndex animated:animated];
    [self _didSelectAtIndex:selectedIndex animated:animated];
}

- (void)_didSelectAtIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex == selectedIndex) return;

    [self _updateSelectedIndex:selectedIndex];
}

- (BOOL)_shouldSelectViewController:(UIViewController *)viewController {
    if ([_delegate respondsToSelector:@selector(segmentController:shouldSelectViewController:)]) {
        return [_delegate segmentController:self shouldSelectViewController:viewController];
    }
    return YES;
}

- (void)_didSelectViewController:(UIViewController *)selectedViewController isDragging:(BOOL)isDragging {
    if ([_delegate respondsToSelector:@selector(segmentController:didSelectViewController:isDragging:)]) {
        [_delegate segmentController:self didSelectViewController:selectedViewController isDragging:isDragging];
    } else {
        if ([_delegate respondsToSelector:@selector(segmentController:didSelectViewController:)]) {
            [_delegate segmentController:self didSelectViewController:selectedViewController];
        }
    }
}

- (void)_didScrollToIndex:(NSUInteger)index {
    if ([_delegate respondsToSelector:@selector(segmentController:didScrollToIndex:)]) {
        [_delegate segmentController:self didScrollToIndex:index];
    }
}

- (void)_loadViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if ([[_preparedViewControllers allKeys] containsObject:@(index)]) return;
    
    BOOL contentSizeUpdated = CGSizeEqualToSize(self.parentViewController.view.bounds.size, self.preferredContentSize);
    viewController.automaticallyAdjustsScrollViewInsets = contentSizeUpdated;
    viewController.segmentController = self;

    [self addChildViewController:viewController];
    [viewController beginAppearanceTransition:YES animated:NO];
    [_scrollView addSubview:viewController.view];
    [self _layoutViewController:viewController atIndex:index];

    [viewController didMoveToParentViewController:self];

    _preparedViewControllers[@(index)] = viewController;
}

- (void)_unloadViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    viewController.segmentController = nil;

    [viewController willMoveToParentViewController:nil];

    [viewController.view removeFromSuperview];
    [viewController endAppearanceTransition];
    [viewController removeFromParentViewController];

    [_preparedViewControllers removeObjectForKey:@(index)];
}

- (void)_beginAppearanceTransition:(BOOL)appeared atIndex:(NSUInteger)index {
    if (index >= _viewControllers.count) return;

    UIViewController *viewController = _viewControllers[_selectedIndex];
    [viewController beginAppearanceTransition:appeared animated:NO];
}

- (void)_endAppearanceTransitionAtIndex:(NSUInteger)index {
    if (index >= _viewControllers.count) return;

    UIViewController *viewController = _viewControllers[index];

    [viewController endAppearanceTransition];
}

- (void)_didUpdateViewControllerTitleAtIndex:(NSUInteger)index {
    [_segmentControl _reloadCellAtIndex:index animated:NO];
}

- (UIEdgeInsets)_scrollViewInset {
    if (_automaticallyAdjustsContentViewInsets && UIEdgeInsetsEqualToEdgeInsets(_contentInset, UIEdgeInsetsZero)) {
        if (@available(iOS 11, *)) {
            return self.view.safeAreaInsets;
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
            
            return UIEdgeInsetsMake(top, 0, bottom, 0);
        }
    }
    return _contentInset;
}

- (void)_updateContentViewlayout {
    CGRect bounds = self.view.bounds;
    CGSize segmentSize = self.segmentControlSize;
    UIEdgeInsets insets = [self _scrollViewInset];

    _contentView.frame = bounds;
    _wrapperView.frame = bounds;

    CGRect segmentFrame, scrollFrame;
    if (_style & MDSegmentControllerStyleEmbededTitleView) {
        segmentFrame = CGRectMake(0, 0, segmentSize.width, segmentSize.height);
        scrollFrame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(insets.top, 0, insets.bottom, 0));
    } else {
        if (segmentSize.width == 0) segmentSize.width = CGRectGetWidth(bounds);
        
        segmentFrame = CGRectMake((CGRectGetWidth(bounds) - segmentSize.width) / 2., insets.top, segmentSize.width, segmentSize.height);
        scrollFrame = CGRectMake(0, insets.top + segmentSize.height, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - insets.top - insets.bottom - segmentSize.height);
    }
    _scrollView.frame = scrollFrame;
    _segmentControl.frame = segmentFrame;

    CGSize size = scrollFrame.size;
    self.preferredContentSize = size;

    CGSize contentSize = CGSizeMake(size.width * _viewControllers.count, size.height);
    _scrollView.contentSize = contentSize;
    _scrollView.contentOffset = CGPointMake(_selectedIndex * size.width, 0);

    [_preparedViewControllers enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, UIViewController *viewController, BOOL *stop) {
        [self _layoutViewController:viewController atIndex:index.unsignedIntegerValue];
    }];

    [_segmentControl layoutIfNeeded];
}

- (void)_layoutViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    CGFloat width = CGRectGetWidth(_scrollView.frame);
    viewController.view.frame = CGRectMake(width * index, 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
}

- (void)_willBeginDrggingWithOffset:(CGPoint)offset {
    [self _beginAppearanceTransition:NO atIndex:_selectedIndex];
    [self _scrollWithOffset:offset];
}

- (void)_scrollWithOffset:(CGPoint)offset {
    CGFloat indexProgress = offset.x / CGRectGetWidth(_scrollView.frame);

    [self _reloadViewControllersAtIndexProgress:indexProgress];
    [_segmentControl _updateIndexProgress:indexProgress animated:YES];
    [_segmentControl _scrollToIndexProgress:indexProgress animated:NO];
}

- (void)_reloadViewControllersAtIndexProgress:(CGFloat)indexProgress {
    NSUInteger index1 = floor(indexProgress);
    NSUInteger index2 = ceil(indexProgress);
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    
    if (index1 < _viewControllers.count) {
        [indexes addIndex:index1];
    }
    if (index2 < _viewControllers.count) {
        [indexes addIndex:index2];
    }
    [self _reloadViewControllersAtIndexes:indexes];
}

- (void)_scrollWillEndDraggingWithOffset:(CGPoint)offset {
    CGFloat indexProgress = offset.x / CGRectGetWidth(_scrollView.frame);
    NSUInteger index = round(indexProgress);

    index = MIN(index, _viewControllers.count - 1);

    if (index == _selectedIndex) [self _beginAppearanceTransition:YES atIndex:_selectedIndex];
}

- (void)_scrollDidEndWithOffset:(CGPoint)offset animated:(BOOL)animated {
    CGFloat x = offset.x;
    CGFloat indexProgress = x / CGRectGetWidth(_scrollView.frame);
    NSInteger index = round(indexProgress);

    BOOL offsetEnabled = index != indexProgress;

    index = MAX(0, index);
    index = MIN(index, _viewControllers.count - 1);

    if (offsetEnabled) {
        [self _scrollToIndex:index animated:animated];
    } else {
        [self _scrollAtIndex:index animated:animated isDragging:YES];
    }
}

- (void)_scrollAtIndex:(NSUInteger)index animated:(BOOL)animated isDragging:(BOOL)isDragging {
    if (index != _selectedIndex) {
        UIViewController *viewController = _viewControllers[index];
        BOOL shouldSelect = [self _shouldSelectViewController:viewController];

        index = shouldSelect ? index : _selectedIndex;
        if (shouldSelect) {
            [self _reloadViewControllersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
            [_segmentControl _selectAtIndex:index animated:animated];

            [self _didScrollToIndex:index];
            [self _didSelectAtIndex:index animated:animated];
            [self _didSelectViewController:_viewControllers[index] isDragging:isDragging];
        }
    }
    [self _endAppearanceTransitionAtIndex:index];
}

- (void)_selectAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [_segmentControl _selectAtIndex:index animated:animated];

    [self _scrollToIndex:index animated:animated];
}

- (void)_scrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    long indexOffset = _selectedIndex - index;
    NSRange range = NSMakeRange(MIN(index, _selectedIndex), (NSUInteger)labs(indexOffset) + 1);
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];

    [self _reloadViewControllersAtIndexes:indexes];
    [_segmentControl _updateIndexProgress:index animated:animated];
    [_segmentControl _scrollToIndexProgress:index animated:animated];

    CGPoint offset = CGPointMake(index * CGRectGetWidth(_scrollView.frame), 0);

    void (^animation)(void) = ^{
        _scrollView.contentOffset = offset;
    };
    void (^completion)(void) = ^{
        [self _scrollAtIndex:index animated:animated isDragging:NO];
    };

    animated = animated && offset.x != _scrollView.contentOffset.x;
    if (animated) {
        [UIView animateWithDuration:MDSegmentControllerAnimationDuration animations:animation completion:^(BOOL finished) {
            completion();
        }];
    } else {
        animation();
        completion();
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:NSStringFromSelector(@selector(title))] && ![keyPath isEqualToString:NSStringFromSelector(@selector(segmentItem))]) return;
    
    UIViewController *viewController = [object isKindOfClass:[UIViewController class]] ? object : nil;
    if (!viewController) return;
    
    NSUInteger index = [_viewControllers indexOfObject:viewController];
    if (index == NSNotFound) return;
    
    [self _didUpdateViewControllerTitleAtIndex:index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _scrollView || !_scrollingEnabled || (!scrollView.dragging && !scrollView.decelerating)) return;

    [self _scrollWithOffset:scrollView.contentOffset];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != _scrollView || !_scrollingEnabled) return;

    [self _willBeginDrggingWithOffset:scrollView.contentOffset];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView != _scrollView || !_scrollingEnabled) return;

    [self _scrollWillEndDraggingWithOffset:*targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != _scrollView || decelerate || !_scrollingEnabled) return;

    [self _scrollDidEndWithOffset:scrollView.contentOffset animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _scrollView || !_scrollingEnabled) return;

    [self _scrollDidEndWithOffset:scrollView.contentOffset animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView != _scrollView || !_scrollingEnabled) return;

    [self _scrollDidEndWithOffset:scrollView.contentOffset animated:YES];
}

#pragma mark - MDSegmentControlContainer

- (NSUInteger)_numberOfTitlesForSegmentControl:(MDSegmentControl *)segmentControl {
    return _viewControllers.count;
}

- (NSString *)_segmentControl:(MDSegmentControl *)segmentControl titleAtIndex:(NSUInteger)index {
    UIViewController *viewController = _viewControllers[index];
    return viewController.title;
}

- (BOOL)_segmentControl:(MDSegmentControl *)segmentControl shouldSelectAtIndex:(NSUInteger)index {
    UIViewController *viewController = _viewControllers[index];
    return [self _shouldSelectViewController:viewController];
}

- (void)_segmentControl:(MDSegmentControl *)segmentControl didSelectAtIndex:(NSUInteger)index {
    [self _scrollToIndex:index animated:YES];
}

- (MDSegmentItem *)_segmentControl:(MDSegmentControl *)segmentControl itemAtIndex:(NSUInteger)index {
    UIViewController *viewController = _viewControllers[index];

    return viewController.segmentItem;
}

@end
