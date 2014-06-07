//
//  AppDelegate.m
//  Status Bar Application
//
//  Created by Ingo Böhme on 02.05.14.
//  Copyright (c) 2014 IBMobile. All rights reserved.
//

#import "AppDelegate.h"


#pragma mark - Defines

// SETTINGS TO BE SAVED

#define SETTINGSSHOWANIMATION @"showStatusbarAnimationValue"
#define SETTINGSSHOWTEXT      @"showStatusbarTextValue"
#define SETTINGSUUID          @"uuid"
#define SETTINGSUUIDNAME      @"myRegionName"
#define SETTINGSMAYOR         @"mayor"
#define SETTINGSMINOR         @"minor"
#define SETTINGSPOWER         @"power"




#define TIMEBETWEENTWOANIMATIONPULSES 1.0
#define ISBEACONSENDING (_beaconStatusMenu.tag != 0)
#define ISANIMATING (_showStatusbarAnimation.state != 0)
#define ISSTATUSBARTEXTVISIBLE (_showStatusbarText.state != 0)




@interface AppDelegate ()
@end

@implementation AppDelegate

#pragma mark - APP lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.manager = [[CBPeripheralManager alloc] initWithDelegate:self
	                                                       queue:nil];
    
    
    
    
	_icons = @[@"icon0", @"icon1", @"icon2", @"icon3", @"icon4", @"icon4", @"icon4", @"icon3", @"icon2", @"icon1", @"icon0", @"icon1", @"icon2", @"icon3", @"icon4", @"icon4", @"icon4", @"icon3", @"icon2", @"icon1", @"icon0"];
    
	//	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setMenu:statusMenu];
	[self setStatusText:@"iBeacon OFF"];
	[statusItem setImage:[NSImage imageNamed:@"icon0"]];
    
	[statusItem setHighlightMode:YES];
    
	[[_infoWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]]]];
    
    
	[self setUpSettingsView];
    
	[_window setIsVisible:NO];
	[_infoWindow setIsVisible:NO];
    
    
	// _infoWebView open
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[self saveSettings];
}

- (IBAction)generateUUID:(id)sender {
	NSString *uuidString = [[NSUUID UUID] UUIDString];
	NSAlert *alert = [NSAlert alertWithMessageText:@"Are you sure, that you want to replace your current UUID with a new generated one?"
	                                 defaultButton:@"No"
	                               alternateButton:@"Yes"
	                                   otherButton:@""
	                     informativeTextWithFormat:@"Just keep in mind that the UUID represents YOUR company, family or whatever. So if you change one beacon, you should copy&paste that new UUID to all other devices."];
	NSInteger result = [alert runModal];
	switch (result) {
		case 0:
			_UUIDField.stringValue = uuidString;
			break;
            
		default:
			break;
	}
	NSLog(@"result %ld",  result);
}

#pragma mark - Load and save Settings
- (void)loadSettings {
	NSLog(@"LOAD !!!");
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 @{
       SETTINGSSHOWANIMATION : @1
       , SETTINGSSHOWTEXT : @1
       , SETTINGSUUID     : @"F9A7F5BA-15F9-476C-952C-0E3A3FDEBD5B"
       , SETTINGSUUIDNAME : @"my personal Region Name"
       , SETTINGSMAYOR    : @1
       , SETTINGSMINOR    : @1
       , SETTINGSPOWER    : @ - 60
       }
     ];
    
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	_showStatusbarAnimation.state = [[settings objectForKey:SETTINGSSHOWANIMATION] integerValue];
	_showStatusbarText.state = [[settings objectForKey:SETTINGSSHOWTEXT] integerValue];
    
	_UUIDField.stringValue = [settings objectForKey:SETTINGSUUID];
	_UUIDNameField.stringValue = [settings objectForKey:SETTINGSUUIDNAME];
	_minorField.integerValue = [[settings objectForKey:SETTINGSMINOR] integerValue];
	_majorField.integerValue = [[settings objectForKey:SETTINGSMAYOR] integerValue];
	_pwrField.integerValue = [[settings objectForKey:SETTINGSPOWER] integerValue];
    
    
	_minorStepper.integerValue = _minorField.integerValue;
	_majorStepper.integerValue = _majorField.integerValue;
	_pwrStepper.integerValue = _pwrField.integerValue;
    
	[self changeSetStatusBarAnimation:nil];
	[self changeSetStatusBarText:nil];
}

- (void)saveSettings {
	NSLog(@"SAVE !!!");
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:_UUIDField.stringValue forKey:SETTINGSUUID];
	[settings setObject:_UUIDNameField.stringValue forKey:SETTINGSUUIDNAME];
    
	[settings setInteger:_minorField.integerValue forKey:SETTINGSMINOR];
	[settings setInteger:_majorField.integerValue forKey:SETTINGSMAYOR];
	[settings setInteger:_pwrField.integerValue forKey:SETTINGSPOWER];
    
	[settings setInteger:_showStatusbarAnimation.state forKey:SETTINGSSHOWANIMATION];
	[settings setInteger:_showStatusbarText.state forKey:SETTINGSSHOWTEXT];
    
	[settings synchronize];
}

- (void)setUpSettingsView {
	[self loadSettings];
    
	NSNumberFormatter *intFormatter = [[NSNumberFormatter alloc] init];
	[intFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[intFormatter setGeneratesDecimalNumbers:FALSE];
	[intFormatter setMaximumFractionDigits:0];
    
    
    
    
	//	[_UUIDField setFormatter:fmtCurrency];
	[_majorField setFormatter:intFormatter];
	[_minorField setFormatter:intFormatter];
	[_pwrField setFormatter:intFormatter];
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
	// NSLog(@"START!!!");
    
	if (_animTimer) [_animTimer invalidate];
    
	if (!ISBEACONSENDING)
		return;      // NOT ACTIVATED
    
    
    
	if (!ISANIMATING) {
		[self showStatusbarStaticIcon];
		return;
	}
	else {
		_animTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 15 target:self selector:@selector(updateImage:) userInfo:nil repeats:YES];
	}
}

- (void)stopAnimating {
	// NSLog(@"STOP!!!");
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
		[_manager stopAdvertising];
        
		[_UUIDField setEnabled:YES];
		[_majorField setEnabled:YES];
		[_minorField setEnabled:YES];
		[_pwrField setEnabled:YES];
        
		[self stopAnimating];
		[_beaconStatusMenu setTitle:@"Start iBeacon"];
		[self setStatusText:@"iBeacon OFF"];
	}
	else {
		_beaconStatusMenu.tag = 1;
		NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:[_UUIDField stringValue]];
        
		BLCBeaconAdvertisementData *beaconData = [[BLCBeaconAdvertisementData alloc] initWithProximityUUID:proximityUUID
		                                                                                             major:_majorField.integerValue
		                                                                                             minor:_minorField.integerValue
                                                  
		                                                                                     measuredPower:_pwrField.integerValue];
        
		[_manager startAdvertising:beaconData.beaconAdvertisement];
        
		[_UUIDField setEnabled:NO];
		[_majorField setEnabled:NO];
		[_minorField setEnabled:NO];
		[_pwrField setEnabled:NO];
        
		[self startAnimating];
		[self setStatusText:nil];
		[_beaconStatusMenu setTitle:@"Stop iBeacon"];
        
		[self setStatusText:@"iBeacon ON"];
	}
    
	[_startBeacon setTitle:_beaconStatusMenu.title];
    
    
    
	//	if (ISBEACONSENDING) {
	//		_beaconStatusMenu.tag = 0;
	//		[self stopAnimating];
	//		[_beaconStatusMenu setTitle:@"Start iBeacon"];
	//		[self setStatusText:@"iBeacon OFF"];
	//	}
	//	else {
	//		_beaconStatusMenu.tag = 1;
	//		[self startAnimating];
	//		[self setStatusText:nil];
	//
	//		[_beaconStatusMenu setTitle:@"Stop iBeacon"];
	//		[self setStatusText:@"iBeacon ON"];
	//	}
}

- (IBAction)showSettings:(id)sender {
	[_window setIsVisible:YES];
	[_window setLevel:NSFloatingWindowLevel];
    
	//	[_window makeKeyAndOrderFront:nil];
	//	[_window setLevel:NSStatusWindowLevel];
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

- (IBAction)editTextField:(NSTextField *)sender {
	NSLog(@"VAL %d", sender.intValue);
	if (sender == _majorField) {
		_majorStepper.integerValue = _majorField.integerValue;
	}
	else if (sender == _minorField) {
		_minorStepper.integerValue = _minorField.integerValue;
	}
	else if (sender == _pwrField) {
		_pwrStepper.integerValue = _pwrField.integerValue;
	}
}

- (IBAction)showHelp:(id)sender {
	[_infoWindow setIsVisible:YES];
}

#pragma mark - CBPeripheralManager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
	NSLog(@"STATE: %ld", peripheral.state);
    
    
    
	switch (peripheral.state) {
		default:
			break;
            
		case CBPeripheralManagerStateUnknown: NSLog(@"Unknown"); break;
            
		case CBPeripheralManagerStateResetting: NSLog(@"Resetting"); break;
            
		case CBPeripheralManagerStateUnsupported: NSLog(@"Unsupported"); break;
            
		case CBPeripheralManagerStateUnauthorized: NSLog(@"Unauthorized"); break;
            
		case CBPeripheralManagerStatePoweredOff: NSLog(@"Power Off"); break;
            
		case CBPeripheralManagerStatePoweredOn: NSLog(@"Power ON"); break;
	}
    
	if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
	}
}

/*!
 *  @method peripheralManager:willRestoreState:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param dict
 *
 *  @discussion
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
}

/*!
 *  @method peripheralManagerDidStartAdvertising:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of a @link startAdvertising: @/link call. If advertisement could
 *                      not be started, the cause will be detailed in the <i>error</i> parameter.
 *
 */
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
}

/*!
 *  @method peripheralManager:didAddService:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param service      The service that was added to the local database.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of an @link addService: @/link call. If the service could
 *                      not be published to the local database, the cause will be detailed in the <i>error</i> parameter.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
}

/*!
 *  @method peripheralManager:central:didSubscribeToCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were enabled.
 *
 *  @discussion             This method is invoked when a central configures <i>characteristic</i> to notify or indicate.
 *                          It should be used as a cue to start sending updates as the characteristic value changes.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
}

/*!
 *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were disabled.
 *
 *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
}

/*!
 *  @method peripheralManager:didReceiveReadRequest:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param request      A <code>CBATTRequest</code> object.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
}

/*!
 *  @method peripheralManager:didReceiveWriteRequests:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
 *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
 *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
}

/*!
 *  @method peripheralManagerIsReadyToUpdateSubscribers:
 *
 *  @param peripheral   The peripheral manager providing this update.
 *
 *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
 *                      ready to send characteristic value updates.
 *
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
}

@end;
