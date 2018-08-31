//
//  MDSegmentController.h
//  MDSegmentController
//
//  Created by xulinfeng on 2018/8/27.
//  Copyright © 2018年 modool. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

@class MDSegmentController;
@protocol MDSegmentControllerDelegate <NSObject>

@optional
- (BOOL)segmentController:(MDSegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController;

- (void)segmentController:(MDSegmentController *)segmentController didScrollToIndex:(NSUInteger)index;
- (void)segmentController:(MDSegmentController *)segmentController didSelectViewController:(UIViewController *)viewController;

@end

@protocol MDSegmentControlDelegate <NSObject>

@optional
- (void)segmentController:(MDSegmentController *)segmentController didSelectAtIndex:(NSUInteger)index;

@end

@interface MDSegmentControl : UIView

@property (nonatomic, weak) id<MDSegmentControlDelegate> delegate;

/** Default is calculated by text length,
 disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign) CGFloat itemWidth;

/** Font of segment item title, default is system font with label font size */
@property (nonatomic, strong) UIFont *font;

/** Tint color of segment, default is nil */
@property (nonatomic, strong) UIColor *tintColor;

/** Color of segment item title, default is nil */
@property (nonatomic, strong) UIColor *textColor;

/** Color of selected segment item title, default is nil */
@property (nonatomic, strong) UIColor *selectedTextColor;

/** Ability of title to transformer, it's no transformer if NO*/
@property (nonatomic, assign, getter=isFaded) BOOL fade;

/** Spacing between cells, the default value is 0.0f,
 disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign) CGFloat spacing;

/** Item is homodisperse in segment when overall width is less than width of content view,
 or align left, default is NO, disabled if style is MDSegmentControllerStyleSegmentControl. */
@property (nonatomic, assign, getter=isHomodisperse) BOOL homodisperse;

/** Ability of indicator, it's unavailabel if NO,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign, getter=isIndicatorEnabled) BOOL indicatorEnabled;

/** background color of indicator, default is 2.f,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, strong) UIColor *indicatorBackgroundColor;

/** Height of indicator, default is 2.f,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign) CGFloat indicatorHeight;

/** Width of indicator, default is dynamic,
 disabled if style is MDSegmentControllerStyleSegmentControl */
@property (nonatomic, assign) CGFloat indicatorWidth;

@end

@interface MDSegmentController : UIViewController

// Default is MDSegmentControllerStyleEmbededContentView | MDSegmentControllerListView.
@property (nonatomic, assign, readonly) MDSegmentControllerStyle style;

@property (nonatomic, strong, readonly) MDSegmentControl *segmentControl;

@property (nonatomic, weak) id<MDSegmentControllerDelegate> delegate;

@property (nonatomic, copy) NSArray<UIViewController *> *viewControllers;

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong) UIViewController *selectedViewController;

/** Default YES. if YES, bounces past edge of content and back again */
@property (nonatomic, assign, getter=isBounces) BOOL bounces;

@property (nonatomic, assign) NSUInteger selectedIndex;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

/** The width of segment controll will be view's width if style is MDSegmentControllerStyleEmbededContentView. */
@property (nonatomic, assign) CGSize segmentControlSize;

/**
 Method to initilize with style

 @param style  style of layout and kind of view, the segment can be layout in either content view or title view.
 @return MDSegmentController instance
 */
- (instancetype)initWithStyle:(MDSegmentControllerStyle)style NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
