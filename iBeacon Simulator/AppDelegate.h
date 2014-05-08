//
//  AppDelegate.h
//  Status Bar Application
//
//  Created by Ingo Böhme on 02.05.14.
//  Copyright (c) 2014 IBMobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <IOBluetooth/IOBluetooth.h>


#import "BLCBeaconAdvertisementData.h"

#import <IOBluetooth/IOBluetooth.h>

#import "BLCBeaconAdvertisementData.h"



@interface AppDelegate : NSObject <NSApplicationDelegate, CBPeripheralManagerDelegate> {
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
}

@property (nonatomic, strong) AppDelegate *mainApp;

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSWindow *infoWindow;
@property (weak) IBOutlet NSMenuItem *beaconStatusMenu;


#pragma mark - Settings


@property (nonatomic, strong) IBOutlet NSStepper *majorStepper;
@property (nonatomic, strong) IBOutlet NSStepper *minorStepper;
@property (nonatomic, strong) IBOutlet NSStepper *pwrStepper;


@property (nonatomic, strong) IBOutlet NSTextField *UUIDNameField;
@property (nonatomic, strong) IBOutlet NSTextField *UUIDField;
@property (nonatomic, strong) IBOutlet NSTextField *majorField;
@property (nonatomic, strong) IBOutlet NSTextField *minorField;
@property (nonatomic, strong) IBOutlet NSTextField *pwrField;



@property (weak) IBOutlet NSButton *showStatusbarAnimation;
@property (weak) IBOutlet NSButton *showStatusbarText;
@property (weak) IBOutlet NSButton *startBeacon;

@property (weak) IBOutlet WebView *infoWebView;

@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSTimer *animTimer;
@property (nonatomic, strong) CBPeripheralManager *manager;


@end
