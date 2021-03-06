//
//  SUGridRootView.m
//  PixelHunter
//
//  Created by Alex Saenko on 9/25/13.
//  Copyright (c) 2013 Sigma Ukraine. All rights reserved.
//

#import "SUGridRootView.h"
#import "SUGridRulerViewHorizontal.h"
#import "SUGridRulerViewVertical.h"


typedef enum {
    SUToolbarStateNone = 0,
    SUToolbarStateHidden,
    SUToolbarStateShown
} SUToolBarState;


static CGFloat const kSUToolBarHeight = 96.0f;
static CGFloat const kSUToolBarWidth = 320.0f;

@interface SUGridRootView ()

@property (nonatomic, assign) SUToolBarState toolbarState;

@end


@implementation SUGridRootView

- (id)initWithFrame:(CGRect)rect withImage:(UIImage *)image
{
	self = [super initWithFrame:rect];
	if (self) {

        self.gridUnderLayerView = [[SUGridUnderLayerView alloc]
                                    initWithFrame:rect withImage:image];
        [self addSubview:self.gridUnderLayerView];

        self.tapGesture = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:self.tapGesture];
        [self.tapGesture addTarget:self action:@selector(onViewTap)];
        
        self.smallGridView = [[SUGridView alloc] init];
        self.smallGridView.hidden = YES;
        self.smallGridView.gridStepSize = kSUSmallStepSize;
        [self addSubview:self.smallGridView];
        
        self.topRuler = [[SUGridRulerViewHorizontal alloc] init];
        self.sideRuler = [[SUGridRulerViewVertical alloc] init];
        [self addSubview:self.topRuler];
        [self addSubview:self.sideRuler];
        
        self.toolbar = [[SUGridToolbar alloc] init];
        self.toolbarState = SUToolbarStateHidden;
        SEL displayGridAction = @selector(onDisplayGridButtonTap:);
        [self.toolbar.displayGridButton addTarget:self
                                           action:displayGridAction];
        [self addSubview:self.toolbar];
        
        [self layoutViewsDependingOnOrientation];
	}
    
	return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self layoutRulerViews];
    [self layoutGridUnderlayerView];
    [self layoutToolbar];
}

- (void)layoutRulerViews
{
    CGFloat zoomScale = self.gridUnderLayerView.scrollView.zoomScale;
    self.topRuler.scale = zoomScale;
    self.sideRuler.scale = zoomScale;
    [self.topRuler setNeedsDisplay];
    [self.sideRuler setNeedsDisplay];
}

- (void)layoutGridUnderlayerView
{
    CGRect gridViewsRect = [self screenBounds];
    [self swapSizeIfLandscape:&gridViewsRect.size];
    
    self.gridUnderLayerView.frame = gridViewsRect;
    self.smallGridView.frame = gridViewsRect;
}

- (void)layoutViewsDependingOnOrientation
{
    UIScrollView *scrollView = self.gridUnderLayerView.scrollView;
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    CGSize boundsSize = self.screenBounds.size;

    [self swapSizeIfLandscape:&boundsSize];

    self.topRuler.frame = CGRectMake(0.0f, 0.0f, boundsSize.width, kSURulerSize);
    self.sideRuler.frame = CGRectMake(0.0f, 0.0f, kSURulerSize, boundsSize.height);
}

- (void)layoutToolbar
{
    CGSize boundsSize = self.bounds.size;
    CGFloat y = self.toolbarState == SUToolbarStateHidden ?
    boundsSize.height : boundsSize.height - kSUToolBarHeight;
    CGRect newFrame = CGRectMake((boundsSize.width - kSUToolBarWidth) / 2.0f, y,
                                 kSUToolBarWidth, kSUToolBarHeight);
    self.toolbar.frame = newFrame;
}

#pragma mark - Private

- (void)swapSizeIfLandscape:(CGSize *)size
{
    if ([self isLandscape]) {
        CGFloat temp = size->width;
        size->width = size->height;
        size->height = temp;
    }
}

- (BOOL)isLandscape
{
    return UIInterfaceOrientationIsLandscape(
                        [UIApplication sharedApplication].statusBarOrientation);
}

- (CGRect)screenBounds
{
    return [[UIScreen mainScreen] bounds];
}

#pragma mark - Actions

- (void)onViewTap
{
    if (self.toolbarState == SUToolbarStateHidden) {
        [self showToolbarAnimated];
        
    } else {
        [self hideToolbarAnimated];
    }
}

- (void)showToolbarAnimated
{
    self.toolbarState = SUToolbarStateShown;
    [UIView animateWithDuration:kSUStandardAnimationTime animations:^{
        [self layoutToolbar];
    }];
}

- (void)hideToolbarAnimated
{
    self.toolbarState = SUToolbarStateHidden;
    [UIView animateWithDuration:kSUStandardAnimationTime animations:^{
        [self layoutToolbar];
    }];
}

- (void)onDisplayGridButtonTap:(SUCompositeButton *)sender
{
    UIView *gridView = self.gridUnderLayerView.gridView;

    if (sender.state == SUCompositeButtonStateNormal) {
        sender.state = SUCompositeButtonStateActivated;
        gridView.hidden = NO;
    } else {
        sender.state = SUCompositeButtonStateNormal;
        gridView.hidden = YES;
    }
}

@end
