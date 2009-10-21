//
//  TapMania.h
//  TapMania
//
//  Created by Alex Kremer on 02.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMRunLoop.h"	// For TMRunLoopPriority etc.
#import "ARRollerProtocol.h"

@class TMSong, TMSongOptions, EAGLView, JoyPad, TMScreen, TMModalView;

@interface TapMania : NSObject <TMRunLoopDelegate, ARRollerDelegate> {	
	TMSong*				m_pCurrentSong;	// Points to currently selected song which can be played
	TMSongOptions*		m_pCurrentSongOptions;	// Holds current song options which are applied to the currentSong
	
	TMScreen*			m_pCurrentScreen;	// This is set to currently rendering screen
	
	UIWindow*			m_pWindow;
	EAGLView*			m_pGlView;
	ARRollerView*		m_pAdsView;
		
	TMRunLoop*			m_pGameRunLoop;
	JoyPad*				m_pJoyPad;			// The joypad
	
	CGAffineTransform	m_Transform;		// Affine transformation used for metrics system
	CGAffineTransform	m_InputTransform;	// Affine transformation used for input engine
}

@property (retain, nonatomic, readonly, getter=glView) EAGLView* m_pGlView;
@property (retain, nonatomic, readonly) UIWindow* m_pWindow;

@property (retain, nonatomic, readonly, getter=joyPad) JoyPad* m_pJoyPad;
@property (retain, nonatomic, readonly) TMRunLoop* m_pGameRunLoop;

@property (nonatomic, readonly) CGAffineTransform m_Transform;
@property (nonatomic, readonly) CGAffineTransform m_InputTransform;

- (void) startGame;

// Go to another screen using this method
// This method will remove current screen and release memory. Afterwards it will switch to the specified screen.
- (void) switchToScreen:(TMScreen*)screenRenderer;
- (void) switchToScreen:(TMScreen*)screenRenderer usingTransition:(Class)transitionClass;
- (void) switchToScreen:(TMScreen*)screenRenderer usingTransition:(Class)transitionClass timeIn:(double)timeIn timeOut:(double) timeOut;	

- (void) addOverlay:(TMModalView*)modalView;
- (void) removeOverlay:(TMModalView*)modalView;

- (void) registerObjectAtEnd:(NSObject*) obj;
- (void) registerObjectAtBegin:(NSObject*) obj;

- (void) deregisterObject:(NSObject*) obj;
- (void) deregisterAll;

- (void) setCurrentScreen:(TMScreen*) screenRenderer;
- (void) releaseCurrentScreen;

- (void) toggleAds:(BOOL)onOff;
- (JoyPad*) enableJoyPad;
- (void) disableJoyPad;

+ (TapMania *)sharedInstance;

@end
