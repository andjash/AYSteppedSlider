//
//  AYSteppedSliderView.m
//  AYSteppedSlider
//
//  Created by Andrey Yashnev on 11/05/16.
//  Copyright © 2016 Andrey Yashnev. All rights reserved.
//

#import "AYSteppedSliderView.h"

@interface AYSteppedSliderView ()

@property (nonatomic, assign) BOOL anchorMoved;

@end

@implementation AYSteppedSliderView

#pragma mark - Init&Dealloc

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.positiveSideEnabled = YES;
    self.negativeSideEnabled = YES;
    self.bouncing = YES;
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleModeGesture:)]];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    [self moveAnchorAccordingToTouchOrigin:location.y];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self anchorMoved]) {
        [self doSelectionForAnchorOrigin:self.sliderAnchorView.center.y];
        [self animateAnchorBounceBack];
    }
}

#pragma mark - Public

- (NSInteger)stepIndexForCurrentAnchorPosition:(BOOL *)isRemoving {
    CGFloat anchorOrigin = self.sliderAnchorView.center.y;
    double step = (self.sliderTrackView.frame.size.height / 2) / [self.steps count];
    NSInteger translatedOrigin = anchorOrigin - self.sliderTrackView.frame.origin.y;
    BOOL removing = translatedOrigin > self.sliderTrackView.frame.size.height / 2;
    if (removing) {
        translatedOrigin -= self.sliderTrackView.frame.size.height / 2;
        NSInteger index = MIN([self.steps count] - 1, translatedOrigin / step);
        *isRemoving = YES;
        return index;
    } else {
        NSInteger index = ([self.steps count] - 1) - translatedOrigin / step;
        index = MAX(0, index);
        *isRemoving = NO;
        return index;
    }        
}

#pragma mark - Private

- (void)moveAnchorAccordingToTouchOrigin:(CGFloat)touchOrigin {
    self.anchorMoved = NO;
    if (!self.positiveSideEnabled && touchOrigin < (self.sliderTrackView.frame.size.height / 2 + self.sliderTrackView.frame.origin.y)) {
        return;
    }
    if (!self.negativeSideEnabled && touchOrigin > (self.sliderTrackView.frame.size.height / 2 + self.sliderTrackView.frame.origin.y)) {
        return;
    }
    self.anchorMoved = YES;
    
    CGPoint sliderAnchorCenter = self.sliderAnchorView.center;
    sliderAnchorCenter.y = MAX(touchOrigin, self.sliderTrackView.frame.origin.y);
    sliderAnchorCenter.y = MIN(sliderAnchorCenter.y, self.sliderTrackView.frame.origin.y + self.sliderTrackView.frame.size.height);
    self.sliderAnchorView.center = sliderAnchorCenter;
    if ([self.delegate respondsToSelector:@selector(steppedSlider:didMoveAnchorView:)]) {
        [self.delegate steppedSlider:self didMoveAnchorView:self.sliderAnchorView];
    }
}

- (void)handleModeGesture:(UIGestureRecognizer *)gestureRecognizer {
    static BOOL disabling = NO;
    if (disabling) {
        return;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    [self moveAnchorAccordingToTouchOrigin:location.y];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged:
            if (!CGRectContainsPoint(self.bounds, location)) {
                [self doSelectionForAnchorOrigin:self.sliderAnchorView.center.y];
                [self animateAnchorBounceBack];
                disabling = YES;
                gestureRecognizer.enabled = NO;
                gestureRecognizer.enabled = YES;
                disabling = NO;
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.anchorMoved)
                [self doSelectionForAnchorOrigin:self.sliderAnchorView.center.y];
       case UIGestureRecognizerStateCancelled:
       case UIGestureRecognizerStateFailed:
            [self animateAnchorBounceBack];
        default:
            break;
    }
}

- (void)animateAnchorBounceBack {
    void (^changeBlock)() = ^void() {
        CGPoint sliderAnchorCenter = self.sliderAnchorView.center;
        sliderAnchorCenter.y = self.sliderTrackView.frame.origin.y + self.sliderTrackView.frame.size.height / 2;
        self.sliderAnchorView.center = sliderAnchorCenter;
    };
    
    if (self.bouncing) {
        [UIView animateWithDuration:0.5 delay:0
             usingSpringWithDamping:0.4 initialSpringVelocity:0.0f
                            options:0 animations:changeBlock completion:nil];
    } else {
        [UIView animateWithDuration:0.5 animations:changeBlock];
    }
}

- (void)doSelectionForAnchorOrigin:(CGFloat)anchorOrigin {
    BOOL isRemoving = NO;
    NSInteger index = [self stepIndexForCurrentAnchorPosition:&isRemoving];
    if (isRemoving) {
       if ([self.delegate respondsToSelector:@selector(steppedSlider:didRemoveStepWithIndex:)]) {
            [self.delegate steppedSlider:self didRemoveStepWithIndex:index];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(steppedSlider:didAddStepWithIndex:)]) {
            [self.delegate steppedSlider:self didAddStepWithIndex:index];
        }
    }
}

@end
