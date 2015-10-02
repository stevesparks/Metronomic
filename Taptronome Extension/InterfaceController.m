//
//  InterfaceController.m
//  Taptronome Extension
//
//  Created by Steve Sparks on 6/9/15.
//  Copyright © 2015 Steve Sparks. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceSlider *bpmSlider;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *bpmPicker;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *stopButton;


@property (nonatomic) NSTimer *metronomeTimer;
@property (nonatomic) NSTimer *nextTimer;
@property (nonatomic) NSInteger bpm;

@property (nonatomic) BOOL useTaptics;
@property (nonatomic) BOOL runInBackground;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.useTaptics = YES;
    [self loadPicker];
    self.bpm = 120;
    // Configure interface objects here.
}

- (void)willActivate {
    [super willActivate];
    [self.bpmPicker focus];
    [self updateUI];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    if(!self.runInBackground)
        [self stopMetronome];
}

- (IBAction)sliderChanged:(float)value {
    [self setBPM:(NSInteger)value];
}

- (IBAction)crownChanged:(NSInteger)value {
    [self setBPM:value+50];
}

- (IBAction)runInBackgroundChanged:(BOOL)value {
    self.runInBackground = value;
}

- (IBAction)tapticSwitchChanged:(BOOL)value {
    self.useTaptics = value;
}

- (IBAction)stopButtonTapped {
    if(self.metronomeTimer) {
        [self stopMetronome];
    } else {
        [self startTimer];
    }
}

- (void)loadPicker {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(int c=50;c<200;c++) {
        WKPickerItem *item = [[WKPickerItem alloc] init];
        item.title = [NSString stringWithFormat:@"%d bpm", c];
        [items addObject:item];
    }
    [self.bpmPicker setItems:items];
}

- (void)updateUI {
    if(self.metronomeTimer) {
        [self.stopButton setBackgroundColor:[UIColor redColor]];
        [self.stopButton setTitle:@"Stop"];
    } else {
        [self.stopButton setBackgroundColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0]];
        [self.stopButton setTitle:@"Start"];
    }
    [self.bpmPicker setSelectedItemIndex:self.bpm - 50];
}

- (void)setBPM:(NSInteger)bpm {
    self.bpm = bpm;
}

- (void)startTimer {
    NSTimeInterval len = 60.0/self.bpm;
    self.nextTimer = [NSTimer timerWithTimeInterval:len target:self selector:@selector(tick:) userInfo:@{ @"bpm" : @(self.bpm) } repeats:YES];
    if(!self.metronomeTimer) {
        [self switchToNextTimer];
    }
}

- (void)tick:(NSTimer *)timer {
    if(self.useTaptics) {
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeClick];
    } else {
        // boop
    }

    if(self.nextTimer) {
        [self switchToNextTimer];
    }
}

- (void)switchToNextTimer {
    [self.metronomeTimer invalidate];
    self.metronomeTimer = self.nextTimer;

    [self updateUI];

    self.nextTimer = nil;
    [[NSRunLoop mainRunLoop] addTimer:self.metronomeTimer forMode:NSRunLoopCommonModes];
}

- (IBAction)stopMetronome {
    [self.metronomeTimer invalidate];
    self.metronomeTimer = nil;
    [self updateUI];
}
@end



