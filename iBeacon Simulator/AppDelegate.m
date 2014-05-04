//
//  AppDelegate.m
//  Status Bar Application
//
//  Created by Ingo Böhme on 02.05.14.
//  Copyright (c) 2014 IBMobile. All rights reserved.
//

#import "AppDelegate.h"


#define TIMEBETWEENTWOANIMATIONPULSES 1.0
#define ISBEACONSENDING (_beaconStatusMenu.tag != 0)
#define ISANIMATING (_showStatusbarAnimation.state != 0)
#define ISSTATUSBARTEXTVISIBLE (_showStatusbarText.state != 0)




@interface AppDelegate ()
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSTimer *animTimer;

@end

@implementation AppDelegate

#pragma mark - APP lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_icons = @[@"icon0", @"icon1", @"icon2", @"icon3", @"icon4", @"icon4", @"icon4", @"icon3", @"icon2", @"icon1", @"icon0", @"icon1", @"icon2", @"icon3", @"icon4", @"icon4", @"icon4", @"icon3", @"icon2", @"icon1", @"icon0"];
    
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setMenu:statusMenu];
	[self setStatusText:@"iBeacon OFF"];
	[statusItem setImage:[NSImage imageNamed:@"icon0"]];
    
	[statusItem setHighlightMode:NO];
	[_window setIsVisible:NO];
    
	[self defaultSettings];
    
	NSLog(@"TXT %ld", _showStatusbarText.state);
	NSLog(@"ANI %ld", _showStatusbarAnimation.state);
    
    
	[self loadSettings];
    
	NSLog(@"TXT %ld", _showStatusbarText.state);
	NSLog(@"ANI %ld", _showStatusbarAnimation.state);
    
	[self setUpSettingsView];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[self saveSettings];
}

#pragma mark - Load and save Settings

- (void)setUpSettingsView {
	NSNumberFormatter *intFormatter = [[NSNumberFormatter alloc] init];
	[intFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[intFormatter setGeneratesDecimalNumbers:FALSE];
	[intFormatter setMaximumFractionDigits:0];
    
    
    
    
	//	[_UUIDField setFormatter:fmtCurrency];
	[_majorField setFormatter:intFormatter];
	[_minorField setFormatter:intFormatter];
	[_pwrField setFormatter:intFormatter];
}

- (void)defaultSettings {
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 @{
       @"app_showStatusbarAnimationValue" : @1,
       @"app_showStatusbarTextValue" : @1
       }
     ];
}

- (void)loadSettings {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	_showStatusbarAnimation.state = [[settings objectForKey:@"showStatusbarTAnimationValue"] integerValue];
	_showStatusbarText.state = [[settings objectForKey:@"showStatusbarTextValue"] integerValue];
}

- (void)saveSettings {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setInteger:_showStatusbarAnimation.state forKey:@"showStatusbarAnimationValue"];
	[settings setInteger:_showStatusbarText.state forKey:@"showStatusbarTextValue"];
    
	[settings synchronize];
}

#pragma mark - StatusbarText Methods
- (void)setStatusText:(NSString *)text {
	static NSString *lastText = @"";
	if (text) {
		lastText = [NSString stringWithString:text];
		if (ISSTATUSBARTEXTVISIBLE) {
			statusItem.title = text;
		}
	}
	else {
		if (ISSTATUSBARTEXTVISIBLE) {
			statusItem.title = lastText;
		}
		else {
			statusItem.title = @"";
		}
	}
}

#pragma mark - StatusbarIcon Methods

- (void)startAnimating {
	NSLog(@"START!!!");
    
	if (_animTimer) [_animTimer invalidate];
    
	if (!ISBEACONSENDING)
		return; // NOT ACTIVATED
    
    
    
	if (!ISANIMATING) {
		[self showStatusbarStaticIcon];
		return;
	}
	else {
		_animTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 15 target:self selector:@selector(updateImage:) userInfo:nil repeats:YES];
	}
}

- (void)stopAnimating {
	NSLog(@"STOP!!!");
	if (_animTimer) [_animTimer invalidate];
	[self updateImage:nil];
}

- (void)updateImage:(NSTimer *)timer {
	static NSInteger imageCounter = 0;
    
    
	if (timer) {
		imageCounter++;
		if (imageCounter >= [_icons count]) {
			imageCounter = 0;
		}
	}
	else {
		imageCounter = 0;
	}
    
    
    
	//get the image for the current frame
	NSImage *image = [NSImage imageNamed:[_icons objectAtIndex:imageCounter]];
	[statusItem setImage:image];
    
	if ((imageCounter == [_icons count] - 1) && timer) {
		[self stopAnimating];
		[self performSelector:@selector(startAnimating) withObject:nil afterDelay:TIMEBETWEENTWOANIMATIONPULSES];
	}
}

- (void)showStatusbarStaticIcon {
	[self stopAnimating];
	NSImage *image;
    
	if (!ISBEACONSENDING) {
		image = [NSImage imageNamed:@"icon0"];
	}
	else {
		image = [NSImage imageNamed:@"icon4"];
	}
    
    
	[statusItem setImage:image];
}

#pragma mark - Menu Actions
- (IBAction)toggleIBeacon:(id)sender {
	if (ISBEACONSENDING) {
		_beaconStatusMenu.tag = 0;
		[self stopAnimating];
		[_beaconStatusMenu setTitle:@"Start iBeacon"];
		[self setStatusText:@"iBeacon OFF"];
	}
	else {
		_beaconStatusMenu.tag = 1;
		[self startAnimating];
		[self setStatusText:nil];
        
		[_beaconStatusMenu setTitle:@"Stop iBeacon"];
		[self setStatusText:@"iBeacon ON"];
	}
}

- (IBAction)showSettings:(id)sender {
	[_window setIsVisible:YES];
}

- (IBAction)quitIBeacon:(id)sender {
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	[bar removeStatusItem:statusItem];
    
	[[NSApplication sharedApplication] terminate:self];
}

#pragma mark - Change settings IBActions

- (IBAction)changeSetStatusBarText:(NSButton *)sender {
	[self setStatusText:nil];
}

- (IBAction)changeSetStatusBarAnimation:(NSButton *)sender {
	if (sender.state == 0) {
		[self showStatusbarStaticIcon];
	}
	else {
		if (sender.state != 0) {
			[self startAnimating];
		}
		else {
			[self stopAnimating];
		}
	}
}

@end;
