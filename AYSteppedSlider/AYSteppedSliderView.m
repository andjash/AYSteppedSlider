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
    
    [self moveAnchorAccordingToTouchOrigin:(self.isHorizontal ? location.x : location.y)];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self anchorMoved]) {
        [self doSelectionForAnchorOrigin:self.isHorizontal ? self.sliderAnchorView.center.x : self.sliderAnchorView.center.y];
        [self animateAnchorBounceBack];
    }
}

#pragma mark - Public

- (NSInteger)stepIndexForCurrentAnchorPosition:(BOOL *)isRemoving {
    CGFloat anchorOrigin = self.isHorizontal ? self.sliderAnchorView.center.x : self.sliderAnchorView.center.y;
    CGFloat size = self.isHorizontal ? self.sliderTrackView.frame.size.width : self.sliderTrackView.frame.size.height;
    CGFloat sliderOrigin = self.isHorizontal ? self.sliderTrackView.frame.origin.x : self.sliderTrackView.frame.origin.y;
    
    double step = (size / 2) / [self.steps count];
    NSInteger translatedOrigin = anchorOrigin - sliderOrigin;
    BOOL removing = self.isHorizontal ? translatedOrigin < size / 2 : translatedOrigin > size / 2;
    if (removing) {
        NSInteger index = 0;
        if (self.isHorizontal) {
            index = [self.steps count] - 1 - translatedOrigin / step;
        } else {
            translatedOrigin -= size / 2;
            index = MIN([self.steps count] - 1, translatedOrigin / step);
        }
        
        *isRemoving = YES;
        return index;
    } else {
        NSInteger index = 0;
        if (self.isHorizontal) {
            translatedOrigin -= size / 2;
            index = MIN(translatedOrigin / step, [self.steps count] - 1);
        } else {
            index = ([self.steps count] - 1) - translatedOrigin / step;
        }
       
        index = MAX(0, index);
        *isRemoving = NO;
        return index;
    }        
}

#pragma mark - Private

- (void)moveAnchorAccordingToTouchOrigin:(CGFloat)touchOrigin {
    self.anchorMoved = NO;
    
    CGFloat size = self.isHorizontal ? self.sliderTrackView.frame.size.width : self.sliderTrackView.frame.size.height;
    CGFloat origin = self.isHorizontal ? self.sliderTrackView.frame.origin.x : self.sliderTrackView.frame.origin.y;
    
    if (self.isHorizontal) {
        if (!self.positiveSideEnabled && touchOrigin > (size / 2 + origin)) {
            return;
        }
        if (!self.negativeSideEnabled && touchOrigin < (size / 2 + origin)) {
            return;
        }
    } else {
        if (!self.positiveSideEnabled && touchOrigin < (size / 2 + origin)) {
            return;
        }
        if (!self.negativeSideEnabled && touchOrigin > (size / 2 + origin)) {
            return;
        }
    }

    self.anchorMoved = YES;
    
    CGPoint sliderAnchorCenter = self.sliderAnchorView.center;
    CGFloat centerOrigin = MAX(touchOrigin, origin);
    centerOrigin = MIN(centerOrigin, origin + size);
    
    if (self.isHorizontal) {
        sliderAnchorCenter.x = centerOrigin;
    } else {
        sliderAnchorCenter.y = centerOrigin;
    }
    
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
    [self moveAnchorAccordingToTouchOrigin:self.isHorizontal ? location.x : location.y];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged:
            if (!CGRectContainsPoint(self.bounds, location)) {
                [self doSelectionForAnchorOrigin:self.isHorizontal ? self.sliderAnchorView.center.x : self.sliderAnchorView.center.y];
                [self animateAnchorBounceBack];
                disabling = YES;
                gestureRecognizer.enabled = NO;
                gestureRecognizer.enabled = YES;
                disabling = NO;
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.anchorMoved)
                [self doSelectionForAnchorOrigin:self.isHorizontal ? self.sliderAnchorView.center.x : self.sliderAnchorView.center.y];
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
        if (self.isHorizontal) {
            sliderAnchorCenter.x = self.sliderTrackView.frame.origin.x + self.sliderTrackView.frame.size.width / 2;
        } else {
            sliderAnchorCenter.y = self.sliderTrackView.frame.origin.y + self.sliderTrackView.frame.size.height / 2;
        }
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
