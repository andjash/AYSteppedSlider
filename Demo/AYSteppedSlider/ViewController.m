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

@property (nonatomic, weak) IBOutlet UILabel *totalSummLabel;

@property (nonatomic, weak) IBOutlet AYSteppedSliderView *verticalSlider;
@property (nonatomic, weak) IBOutlet UILabel *currentVerticalLevelLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *currentVerticalLevelLabelTopSpace;
@property (nonatomic, weak) IBOutlet UIView *verticalNegativeOverlay;
@property (nonatomic, weak) IBOutlet UIView *verticalPositiveOverlay;

@property (nonatomic, weak) IBOutlet AYSteppedSliderView *horizontalSlider;
@property (nonatomic, weak) IBOutlet UILabel *currentHorizontalLevelLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *currentHorizontalLevelLabelLeftSpace;
@property (nonatomic, weak) IBOutlet UIView *horizontalNegativeOverlay;
@property (nonatomic, weak) IBOutlet UIView *horizontalPositiveOverlay;

@property (nonatomic, assign) double totalSumm;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.horizontalSlider.delegate = self;
    self.verticalSlider.delegate = self;
    [self onTotalSumpUpdated];
    self.horizontalSlider.steps =
    self.verticalSlider.steps = @[@100, @200, @300, @400, @5000, @7000, @9000, @100000];
    
    
    self.horizontalSlider.isHorizontal = YES;
//    NSMutableArray *steps = [NSMutableArray array];
//    double finalSumm = kMaxValue;
//    do {
//        [steps addObject:@(finalSumm)];
//        finalSumm -= 1000;
//    } while (finalSumm > 0);
//    self.slider.steps = [[steps reverseObjectEnumerator] allObjects];
    
    self.verticalSlider.sliderAnchorView.layer.cornerRadius = self.verticalSlider.sliderAnchorView.frame.size.width / 2;
    self.horizontalSlider.sliderAnchorView.layer.cornerRadius = self.horizontalSlider.sliderAnchorView.frame.size.width / 2;
}

#pragma mark - Private

- (void)onTotalSumpUpdated {
    self.totalSummLabel.text = [NSString stringWithFormat:@"Total sum: %@$", @(self.totalSumm)];
    self.verticalSlider.positiveSideEnabled = self.totalSumm < kMaxValue;
    self.verticalSlider.negativeSideEnabled = self.totalSumm > kMinValue;
    self.horizontalSlider.positiveSideEnabled = self.totalSumm < kMaxValue;
    self.horizontalSlider.negativeSideEnabled = self.totalSumm > kMinValue;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.verticalNegativeOverlay.alpha = self.verticalSlider.negativeSideEnabled ? 0 : 0.8;
        self.verticalPositiveOverlay.alpha = self.verticalSlider.positiveSideEnabled ? 0 : 0.8;
        
        self.horizontalNegativeOverlay.alpha = self.horizontalSlider.negativeSideEnabled ? 0 : 0.8;
        self.horizontalPositiveOverlay.alpha = self.horizontalSlider.positiveSideEnabled ? 0 : 0.8;
    }];
}

#pragma mark - AYSteppedSliderViewDelegate

- (void)steppedSlider:(AYSteppedSliderView *)slider didAddStepWithIndex:(NSInteger)stepIndex {
    self.totalSumm += [self.verticalSlider.steps[stepIndex] doubleValue];
    self.totalSumm = MIN(self.totalSumm, kMaxValue);
    [self onTotalSumpUpdated];
    [UIView animateWithDuration:0.4 animations:^{
        if (slider == self.verticalSlider) {
            self.currentVerticalLevelLabel.alpha = 0;
        } else {
            self.currentHorizontalLevelLabel.alpha = 0;
        }
    }];
}

- (void)steppedSlider:(AYSteppedSliderView *)slider didRemoveStepWithIndex:(NSInteger)stepIndex {
    self.totalSumm -= [self.verticalSlider.steps[stepIndex] doubleValue];
    self.totalSumm = MAX(kMinValue, self.totalSumm);
    [self onTotalSumpUpdated];
    [UIView animateWithDuration:0.4 animations:^{
        if (slider == self.verticalSlider) {
            self.currentVerticalLevelLabel.alpha = 0;
        } else {
            self.currentHorizontalLevelLabel.alpha = 0;
        }
    }];
}

- (void)steppedSlider:(AYSteppedSliderView *)slider didMoveAnchorView:(UIView *)anchorView {
    BOOL isRemoving = NO;
    NSInteger index = 0;
    if (slider == self.verticalSlider) {
        index = [slider stepIndexForCurrentAnchorPosition:&isRemoving];
        double modulatedValue = 0;
        if (isRemoving) {
            modulatedValue = MAX(-self.totalSumm, -[slider.steps[index] doubleValue]);
            self.currentVerticalLevelLabel.textColor = [UIColor redColor];
            self.currentVerticalLevelLabel.text = [NSString stringWithFormat:@"%@$", @(modulatedValue)];
        } else {
            modulatedValue = MIN(kMaxValue - self.totalSumm, [slider.steps[index] doubleValue]);
            self.currentVerticalLevelLabel.textColor = [UIColor greenColor];
            self.currentVerticalLevelLabel.text = [NSString stringWithFormat:@"+%@$", @(modulatedValue)];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.currentVerticalLevelLabel.alpha = 1;
        }];
        self.currentVerticalLevelLabelTopSpace.constant = anchorView.frame.origin.y + anchorView.frame.size.height / 2 - self.currentVerticalLevelLabel.frame.size.height / 2;
    } else {
        index = [slider stepIndexForCurrentAnchorPosition:&isRemoving];
        double modulatedValue = 0;
        if (isRemoving) {
            modulatedValue = MAX(-self.totalSumm, -[slider.steps[index] doubleValue]);
            self.currentHorizontalLevelLabel.textColor = [UIColor redColor];
            self.currentHorizontalLevelLabel.text = [NSString stringWithFormat:@"%@$", @(modulatedValue)];
        } else {
            modulatedValue = MIN(kMaxValue - self.totalSumm, [slider.steps[index] doubleValue]);
            self.currentHorizontalLevelLabel.textColor = [UIColor greenColor];
            self.currentHorizontalLevelLabel.text = [NSString stringWithFormat:@"+%@$", @(modulatedValue)];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.currentHorizontalLevelLabel.alpha = 1;
        }];
        self.currentHorizontalLevelLabelLeftSpace.constant = anchorView.frame.origin.x + anchorView.frame.size.width / 2 - self.currentHorizontalLevelLabel.frame.size.width / 2;
    }
   
    [self.view layoutIfNeeded];
}

@end
