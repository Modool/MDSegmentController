//
//  MDSegmentController.h
//  MDSegmentController
//
//  Created by xulinfeng on 2018/8/27.
//  Copyright © 2018年 modool. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN const CGFloat MDSegmentControllerSegmentSpacingDynamic;

typedef NS_ENUM(NSUInteger, MDSegmentControllerStyle) {
    // Segment view style
    MDSegmentControllerStyleListView            = 0,
    MDSegmentControllerStyleSegmentControl      = 1 << 0,

    // Segment embed style
    MDSegmentControllerStyleEmbededContentView  = 0,
    MDSegmentControllerStyleEmbededTitleView    = 1 << 1,

    MDSegmentControllerStyleDefault  = 0,
    MDSegmentControllerStyleSegmentControlEmbedTitleView  = MDSegmentControllerStyleSegmentControl | MDSegmentControllerStyleEmbededTitleView,
};

@class MDSegmentControl;
@protocol MDSegmentControlDelegate <NSObject>

@optional
- (void)segmentControl:(MDSegmentControl *)segmentControl didSelectAtIndex:(NSUInteger)index;

@end

@class MDSegmentController;
@protocol MDSegmentControllerDelegate <NSObject>

@optional
- (BOOL)segmentController:(MDSegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController;

- (void)segmentController:(MDSegmentController *)segmentController didScrollToIndex:(NSUInteger)index;
- (void)segmentController:(MDSegmentController *)segmentController didSelectViewController:(UIViewController *)viewController;

@end

@interface MDSegmentControl : UIView

@property (nonatomic, weak) id<MDSegmentControlDelegate> delegate;

/** Default is calculated by text length,
 disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign) CGFloat itemWidth;

/** Font of segment item title, default is system font with label font size */
@property (nonatomic, strong, nullable) UIFont *font;

/** Tint color of segment, default is nil */
@property (nonatomic, strong, nullable) UIColor *tintColor;

/** Color of segment item title, default is nil */
@property (nonatomic, strong, nullable) UIColor *textColor;

/** Color of selected segment item title, default is nil */
@property (nonatomic, strong, nullable) UIColor *selectedTextColor;

/** Ability of title to transformer, it's no transformer if NO*/
@property (nonatomic, assign, getter=isFaded) BOOL fade;

/** Spacing between cells, the default value is MDSegmentControllerSegmentSpacingDynamic,
 disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign) CGFloat spacing;

/** Minimum spacing between cells, the default value is 0,
 disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign) CGFloat minimumSpacing;

/** Inset of scroll content view, default is UIEdgeInsetsZero,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign) UIEdgeInsets scrollContentInset;

/** Content view may be MDHorizontalListView or UISegmentControl. */
@property (nonatomic, strong) UIView *contentView;

/** Inset of content view, default is UIEdgeInsetsZero,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign) UIEdgeInsets contentInset;

/** Item is homodisperse in segment when overall width is less than width of content view, or align left,
 default is NO, disabled if style is MDSegmentControllerStyleSegmentControl or spacing is not dynamic. */
@property (nonatomic, assign, getter=isHomodisperse) BOOL homodisperse;

/** Ability of indicator, it's unavailabel if NO,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign, getter=isIndicatorEnabled) BOOL indicatorEnabled;

/** background color of indicator, default is 2.f,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, strong, nullable) CALayer *indicatorLayer;

/** inset of indicator, default is UIEdgeInsetsZero,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign) UIEdgeInsets indicatorInset;

/** Height of indicator, default is 2.f,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign) CGFloat indicatorHeight;

/** Width of indicator, default is dynamic,
 disabled if style is MDSegmentControllerStyleSegmentControl,
 disabled if indicatorInset is not empty. */
@property (nonatomic, assign) CGFloat indicatorWidth;

@end

@interface MDSegmentController : UIViewController

/** Default is MDSegmentControllerStyleEmbededContentView | MDSegmentControllerListView. */
@property (nonatomic, assign, readonly) MDSegmentControllerStyle style;

/** The segment control with UISegmentControl or MDHorizontalListView. */
@property (nonatomic, strong, readonly) MDSegmentControl *segmentControl;

/** The delegate to . */
@property (nonatomic, weak, nullable) id<MDSegmentControllerDelegate> delegate;

/** */
@property (nonatomic, copy, nullable) NSArray<UIViewController *> *viewControllers;

/** Using safe area if it's UIEdgeInsetsZero */
@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong) UIViewController *selectedViewController;

/** Default YES. if YES, bounces past edge of content and back again */
@property (nonatomic, assign, getter=isBounces) BOOL bounces;

/** Default YES. allow to scroll content view if YES. */
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled;

/** Default YES. adjust inset of content view with safe area if YES. */
@property (nonatomic, assign, getter=isAutomaticallyAdjustsContentViewInsets) BOOL automaticallyAdjustsContentViewInsets;

@property (nonatomic, assign) NSUInteger selectedIndex;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

/** The size of segment controll, width will be view's width if style is
 MDSegmentControllerStyleEmbededContentView. */
@property (nonatomic, assign) CGSize segmentControlSize;

/**
 Method to initilize with style

 @param style  style of layout and kind of view, the segment can be layout in either content view or title view.
 @return MDSegmentController instance
 */
- (instancetype)initWithStyle:(MDSegmentControllerStyle)style NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
