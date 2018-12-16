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

@interface MDSegmentControl : UIView

@property (nonatomic, weak, nullable) id<MDSegmentControlDelegate> delegate;

/** Default is calculated by text length,
 disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign) CGFloat itemWidth;

/** Actual item width is itemWidth added this or (dynamic item width added this,
 Default is 0., disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign) CGFloat itemWidthInset;

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
@property (nonatomic, strong, readonly) UIView *contentView;

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
@property (nonatomic, strong, nullable, readonly) UIView *indicatorView;

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

@class MDSegmentController;
@protocol MDSegmentControllerDelegate <NSObject>

@optional
- (BOOL)segmentController:(MDSegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController;

- (void)segmentController:(MDSegmentController *)segmentController didScrollToIndex:(NSUInteger)index;
- (void)segmentController:(MDSegmentController *)segmentController didSelectViewController:(UIViewController *)viewController;

@end

@interface MDSegmentController : UIViewController

/** Default is MDSegmentControllerStyleEmbededContentView | MDSegmentControllerListView. */
@property (assign, readonly) MDSegmentControllerStyle style;

/** The segment control with UISegmentControl or MDHorizontalListView. */
@property (strong, readonly) MDSegmentControl *segmentControl;

/** The delegate to notify events. */
@property (weak, nullable) id<MDSegmentControllerDelegate> delegate;

/** Child view controllers .*/
@property (copy, nullable) NSArray<UIViewController *> *viewControllers;

/** Using safe area if it's UIEdgeInsetsZero */
@property (assign) UIEdgeInsets contentInset;

/** Custom content view for additional sub views. */
@property (strong, readonly) UIView *contentView;

/** Default YES, if YES, bounces past edge of content and back again */
@property (nonatomic, assign, getter=isBounces) BOOL bounces;

/** Default YES, allow to scroll content view if YES. */
@property (assign, getter=isScrollEnabled) BOOL scrollEnabled;

/** Default YES, adjust inset of content view with safe area if YES. */
@property (assign, getter=isAutomaticallyAdjustsContentViewInsets) BOOL automaticallyAdjustsContentViewInsets;

/** Default NO, YES to reuse view controllers when reseting view controllers, the selected view controller will be reserved. */
@property (assign, getter=isReusingWhenResetViewControllers) BOOL reusingWhenResetViewControllers;

/** Current selected view controller, nil for none of selection. */
@property (strong, nullable) UIViewController *selectedViewController;

/** Current selected index, default is 0. */
@property (assign) NSUInteger selectedIndex;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

/** The size of segment controll, width will be view's width if style is
 MDSegmentControllerStyleEmbededContentView. */
@property (assign) CGSize segmentControlSize;

/**
 Method to initilize with style

 @param style  style of layout and kind of view, the segment can be layout in either content view or title view.
 @return MDSegmentController instance
 */
- (instancetype)initWithStyle:(MDSegmentControllerStyle)style NS_DESIGNATED_INITIALIZER;

@end

@interface MDSegmentItem : UITabBarItem

@property (nonatomic, copy, nullable) NSAttributedString *titleAttributeString;
@property (nonatomic, copy, nullable) NSAttributedString *selectedTitleAttributeString;

@property (nonatomic, copy, nullable) UIColor *badgeColor;
@property (nonatomic, assign) CGRect badgeValueContentInset;

- (nullable NSDictionary<NSAttributedStringKey,id> *)badgeTextAttributesForState:(UIControlState)state;
- (void)setBadgeTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)textAttributes forState:(UIControlState)state;

- (instancetype)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag NS_UNAVAILABLE;

@property (nonatomic, strong) UIImage *landscapeImagePhone NS_UNAVAILABLE;
@property (nonatomic, strong) UIImage *largeContentSizeImage NS_UNAVAILABLE;
@property (nonatomic, assign) UIEdgeInsets landscapeImagePhoneInsets NS_UNAVAILABLE;
@property (nonatomic, assign) UIEdgeInsets largeContentSizeImageInsets NS_UNAVAILABLE;

@end

@interface UIViewController (MDSegmentController)

@property (nonatomic, weak, readonly) MDSegmentController *segmentController;

@property (nonatomic, strong) MDSegmentItem *segmentItem;

@end

NS_ASSUME_NONNULL_END
