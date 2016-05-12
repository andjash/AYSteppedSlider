//
//  ViewController.m
//  AYSteppedSlider
//
//  Created by Andrey Yashnev on 11/05/16.
//  Copyright © 2016 Andrey Yashnev. All rights reserved.
//

#import "ViewController.h"
#import "AYSteppedSliderView.h"

static const double kMaxValue = 1500000;
static const double kMinValue = 0;

@interface ViewController ()<AYSteppedSliderViewDelegate>

@property (nonatomic, weak) IBOutlet AYSteppedSliderView *slider;
@property (nonatomic, weak) IBOutlet UILabel *totalSummLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentLevelLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *currentLevelLabelTopSpace;
@property (nonatomic, weak) IBOutlet UIView *negativeOverlay;
@property (nonatomic, weak) IBOutlet UIView *positiveOverlay;

@property (nonatomic, assign) double totalSumm;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.slider.delegate = self;
    [self onTotalSumpUpdated];
    self.slider.steps = @[@100, @200, @300, @400, @5000, @7000, @9000, @100000];
    
//    NSMutableArray *steps = [NSMutableArray array];
//    double finalSumm = kMaxValue;
//    do {
//        [steps addObject:@(finalSumm)];
//        finalSumm -= 1000;
//    } while (finalSumm > 0);
//    self.slider.steps = [[steps reverseObjectEnumerator] allObjects];
    
    self.slider.sliderAnchorView.layer.cornerRadius = self.slider.sliderAnchorView.frame.size.width / 2;
}

#pragma mark - Private

- (void)onTotalSumpUpdated {
    self.totalSummLabel.text = [NSString stringWithFormat:@"Total sum: %@$", @(self.totalSumm)];
    self.slider.positiveSideEnabled = self.totalSumm < kMaxValue;
    self.slider.negativeSideEnabled = self.totalSumm > kMinValue;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.negativeOverlay.alpha = self.slider.negativeSideEnabled ? 0 : 0.8;
        self.positiveOverlay.alpha = self.slider.positiveSideEnabled ? 0 : 0.8;
    }];
}

#pragma mark - AYSteppedSliderViewDelegate

- (void)steppedSlider:(AYSteppedSliderView *)slider didAddStepWithIndex:(NSInteger)stepIndex {
    self.totalSumm += [self.slider.steps[stepIndex] doubleValue];
    self.totalSumm = MIN(self.totalSumm, kMaxValue);
    [self onTotalSumpUpdated];
    [UIView animateWithDuration:0.4 animations:^{
        self.currentLevelLabel.alpha = 0;
    }];
}

- (void)steppedSlider:(AYSteppedSliderView *)slider didRemoveStepWithIndex:(NSInteger)stepIndex {
    self.totalSumm -= [self.slider.steps[stepIndex] doubleValue];
    self.totalSumm = MAX(kMinValue, self.totalSumm);
    [self onTotalSumpUpdated];
    [UIView animateWithDuration:0.4 animations:^{
        self.currentLevelLabel.alpha = 0;
    }];
}

- (void)steppedSlider:(AYSteppedSliderView *)slider didMoveAnchorView:(UIView *)anchorView {
    BOOL isRemoving = NO;
    NSInteger index = [slider stepIndexForCurrentAnchorPosition:&isRemoving];
    double modulatedValue = 0;
    if (isRemoving) {
        modulatedValue = MAX(-self.totalSumm, -[slider.steps[index] doubleValue]);
        self.currentLevelLabel.textColor = [UIColor redColor];
        self.currentLevelLabel.text = [NSString stringWithFormat:@"%@$", @(modulatedValue)];
    } else {
        modulatedValue = MIN(kMaxValue - self.totalSumm, [slider.steps[index] doubleValue]);
        self.currentLevelLabel.textColor = [UIColor greenColor];
        self.currentLevelLabel.text = [NSString stringWithFormat:@"+%@$", @(modulatedValue)];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.currentLevelLabel.alpha = 1;
    }];
    self.currentLevelLabelTopSpace.constant = anchorView.frame.origin.y + anchorView.frame.size.height / 2 - self.currentLevelLabel.frame.size.height / 2;
    [self.view layoutIfNeeded];
}

@end
