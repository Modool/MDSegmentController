//
//  MDSegmentController.h
//  MDSegmentController
//
//  Created by xulinfeng on 2018/8/27.
//  Copyright © 2018年 modool. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDSegmentControllerTransitioning <NSObject>

- (void)transitionWithContainerView:(UIView *)containerView;

@end

@class MDSegmentController;
@protocol MDSegmentControllerDelegate <NSObject>

- (BOOL)segmentController:(MDSegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController;

- (void)segmentController:(MDSegmentController *)segmentController didSelectViewController:(UIViewController *)viewController;

- (nullable id <MDSegmentControllerTransitioning>)segmentController:(MDSegmentController *)segmentController
                                    transitioningFromViewController:(UIViewController *)fromViewController
                                                   toViewController:(UIViewController *)toViewController;

@end


@interface MDSegmentController : UIViewController

@property (nonatomic, weak) id<MDSegmentControllerDelegate> delegate;

@property (nonatomic, copy) NSArray<UIViewController *> *viewControllers;

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong) UIViewController *selectedViewController;

@property (nonatomic, assign) NSUInteger selectedIndex;

@end

NS_ASSUME_NONNULL_END
