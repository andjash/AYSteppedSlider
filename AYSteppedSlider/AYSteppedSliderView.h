//
//  AYSteppedSliderView.h
//  AYSteppedSlider
//
//  Created by Andrey Yashnev on 11/05/16.
//  Copyright © 2016 Andrey Yashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AYSteppedSliderView;

@protocol AYSteppedSliderViewDelegate <NSObject>

@optional

- (void)steppedSlider:(AYSteppedSliderView *)slider didMoveAnchorView:(UIView *)anchorView;
- (void)steppedSlider:(AYSteppedSliderView *)slider didAddStepWithIndex:(NSInteger)stepIndex;
- (void)steppedSlider:(AYSteppedSliderView *)slider didRemoveStepWithIndex:(NSInteger)stepIndex;
@end

@interface AYSteppedSliderView : UIView

@property (nonatomic, strong) IBOutlet UIView *sliderTrackView;
@property (nonatomic, strong) IBOutlet UIView *sliderAnchorView;

@property (nonatomic, strong) NSArray *steps;
@property (nonatomic, assign) BOOL bouncing;
@property (nonatomic, assign) BOOL positiveSideEnabled;
@property (nonatomic, assign) BOOL negativeSideEnabled;


@property (nonatomic, weak) id<AYSteppedSliderViewDelegate> delegate;

- (NSInteger)stepIndexForCurrentAnchorPosition:(BOOL *)isRemoving;

@end
