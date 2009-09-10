//
//  MainMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MainMenuRenderer.h"
#import "Label.h"
#import "MenuItem.h"
#import "ImageButton.h"
#import "PhysicsUtil.h"
#import "NewsFetcher.h"

#import "SongPickerMenuRenderer.h"
#import "OptionsMenuRenderer.h"
#import "CreditsRenderer.h"
#import "NewsDialog.h"

#import "TMRunLoop.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"

#import "EAGLView.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "SongsDirectoryCache.h"

#import "ZoomEffect.h"
#import "BlinkEffect.h"
#import "SlideEffect.h"

//#import "QuadTransition.h"
#import "FadeTransition.h"

#import "FontManager.h"
#import "Font.h"

#import "TMSoundEngine.h"
#import "TMSound.h"

#import "VersionInfo.h"

@interface MainMenuRenderer (InputHandling)
- (void) playButtonHit;
- (void) optionsButtonHit;
- (void) creditsButtonHit;

- (void) donateButtonHit;
@end


@implementation MainMenuRenderer

int mt_PlayButtonY, mt_OptionsButtonY, mt_CreditsButtonY, mt_MenuButtonsX;
int mt_MenuButtonsWidth, mt_MenuButtonsHeight;
int mt_Mass, mt_Gravity;
Texture2D *t_BG;
Texture2D *t_Donate;
TMSound   *sr_BG;

- (void) dealloc {
	if(m_pDialog)
		[m_pDialog release];
	
	[super dealloc];	
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Cache metrics
	mt_PlayButtonY = [[ThemeManager sharedInstance] intMetric:@"MainMenu PlayButtonY"];
	mt_OptionsButtonY = [[ThemeManager sharedInstance] intMetric:@"MainMenu OptionsButtonY"];
	mt_CreditsButtonY = [[ThemeManager sharedInstance] intMetric:@"MainMenu CreditsButtonY"];
	mt_MenuButtonsX = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonsX"];	
	mt_MenuButtonsWidth = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonsWidth"];
	mt_MenuButtonsHeight = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonsHeight"];
	
	mt_Mass = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonMass"];
	mt_Gravity = [[ThemeManager sharedInstance] intMetric:@"MainMenu Gravity"];
	
	// Preload all required graphics
	t_BG = [[ThemeManager sharedInstance] texture:@"MainMenu Background"];
	t_Donate = [[ThemeManager sharedInstance] texture:@"Common Donate"];
	
	// And sounds
	sr_BG = [[ThemeManager sharedInstance] sound:@"MainMenu Music"];
	
	// No item selected by default
	m_nSelectedMenu = (MainMenuItem)-1;
	m_nState = kMainMenuState_Ready;
	m_dAnimationTime = 0.0;
	
	// Create version and copyright
	[self pushBackChild:[[Label alloc] initWithTitle:TAPMANIA_VERSION_STRING fontSize:12.0f andShape:CGRectMake(212, 285, 80, 40)]];
	[self pushBackChild:[[Label alloc] initWithTitle:TAPMANIA_COPYRIGHT fontSize:12.0f andShape:CGRectMake(140, 10, 180, 20)]];
	
	// Create donation button
	ImageButton* donateButton = 
	[[ZoomEffect alloc] initWithRenderable:
		 [[ImageButton alloc] initWithTexture:t_Donate andShape:CGRectMake(3, 3, 62, 31)]];
	[self pushBackControl:donateButton];
	
	// Register menu items
	// Must disable the play button if empty catalogue
	if([SongsDirectoryCache sharedInstance].catalogueIsEmpty) {
		m_pPlayButton = 
		[[SlideEffect alloc] initWithRenderable:
		  [[MenuItem alloc] initWithTitle:@"No Songs" andShape:CGRectMake(mt_MenuButtonsX, mt_PlayButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]];						
		
		[m_pPlayButton disable];
	} else {
		
		m_pPlayButton = 
		[[SlideEffect alloc] initWithRenderable:
		 [[ZoomEffect alloc] initWithRenderable:
		  [[MenuItem alloc] initWithTitle:@"Play" andShape:CGRectMake(mt_MenuButtonsX, mt_PlayButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];								
	}

	[self pushBackControl:m_pPlayButton];
	
	m_pOptionsButton = 
	[[SlideEffect alloc] initWithRenderable:
	 [[ZoomEffect alloc] initWithRenderable:
	  [[MenuItem alloc] initWithTitle:@"Options" andShape:CGRectMake(mt_MenuButtonsX, mt_OptionsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];
	[self pushBackControl:m_pOptionsButton];
	
	m_pCreditsButton =
	[[SlideEffect alloc] initWithRenderable:
	 [[ZoomEffect alloc] initWithRenderable:
	  [[MenuItem alloc] initWithTitle:@"Credits" andShape:CGRectMake(mt_MenuButtonsX, mt_CreditsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];
	[self pushBackControl:m_pCreditsButton];
	
	// Setup sliding animation
	[(SlideEffect*)(m_pPlayButton) destination: CGPointMake(-mt_MenuButtonsWidth, mt_PlayButtonY)];
	[(SlideEffect*)(m_pOptionsButton) destination: CGPointMake(-mt_MenuButtonsWidth, mt_OptionsButtonY)];
	[(SlideEffect*)(m_pCreditsButton) destination: CGPointMake(-mt_MenuButtonsWidth, mt_CreditsButtonY)];
	
	[(SlideEffect*)(m_pPlayButton) effectTime: 0.4f];
	[(SlideEffect*)(m_pOptionsButton) effectTime: 0.4f];
	[(SlideEffect*)(m_pCreditsButton) effectTime: 0.4f];	
	
	// Setup action handlers
	[m_pPlayButton setActionHandler:@selector(playButtonHit) receiver:self];
	[m_pOptionsButton setActionHandler:@selector(optionsButtonHit) receiver:self];
	[m_pCreditsButton setActionHandler:@selector(creditsButtonHit) receiver:self];
	[donateButton setActionHandler:@selector(donateButtonHit) receiver:self];	
	
	// Raise a news dialog if unread news are found
	if([[NewsFetcher sharedInstance] hasUnreadNews]) {
		// Raise the dialog
		m_pDialog = [[NewsDialog alloc] init];
		[[TapMania sharedInstance] registerObject:m_pDialog withPriority:kRunLoopPriority_Lowest];
		[[InputEngine sharedInstance] subscribeDialog:m_pDialog];
	}
	
	// Play music
	if( ! sr_BG.playing ) {
		[[TMSoundEngine sharedInstance] addToQueue:sr_BG];
	}
	
	// Get ads back to place
	[[TapMania sharedInstance] toggleAds:YES];	 
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_BG drawInRect:bounds];
	
	// Draw children
	[super render:fDelta];
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	
	[super update:fDelta];
	
	if(m_nState == kMainMenuState_Ready) {
		
		if(m_nSelectedMenu == kMainMenuItem_Play) {
			TMLog(@"Enter song pick menu...");		
			m_nState = kMainMenuState_AnimatingOut;
			
		} else if(m_nSelectedMenu == kMainMenuItem_Options) {
			TMLog(@"Enter options menu...");
			m_nState = kMainMenuState_AnimatingOut;			
			
		} else if(m_nSelectedMenu == kMainMenuItem_Credits) {
			TMLog(@"Enter credits screen...");
			m_nState = kMainMenuState_AnimatingOut;
		}

	} else if(m_nState == kMainMenuState_Finished) {
		
		if(m_nSelectedMenu == kMainMenuItem_Play) {
			[[TapMania sharedInstance] switchToScreen:[[SongPickerMenuRenderer alloc] init] usingTransition:[FadeTransition class]];

		} else if(m_nSelectedMenu == kMainMenuItem_Options) {
			[[TapMania sharedInstance] switchToScreen:[[OptionsMenuRenderer alloc] init]];
			
		} else if(m_nSelectedMenu == kMainMenuItem_Credits) {				
			[[TapMania sharedInstance] switchToScreen:[[CreditsRenderer alloc] init] usingTransition:[FadeTransition class]];
		}
		
		m_nState = kMainMenuState_None;	// Do nothing more
	
	} else if(m_nState == kMainMenuState_AnimatingOut) {		
		
		if([(SlideEffect*)m_pCreditsButton isFinished]) {
			m_nState = kMainMenuState_Finished;
			return;
		}
		
		// Start stuff with timeouts
		if(![(SlideEffect*)m_pPlayButton isFinished] && 
		   ![(SlideEffect*)m_pPlayButton isTweening])
		{			
			[(SlideEffect*)m_pPlayButton startTweening];
			
		} else if(m_dAnimationTime >= 0.1 && ![(SlideEffect*)m_pOptionsButton isFinished]
				  && ![(SlideEffect*)m_pOptionsButton isTweening]) 
		{			
			[(SlideEffect*)m_pOptionsButton startTweening];
			
		} else if(m_dAnimationTime >= 0.2 && ![(SlideEffect*)m_pCreditsButton isFinished]
				  && ![(SlideEffect*)m_pCreditsButton isTweening]) 
		{			
			[(SlideEffect*)m_pCreditsButton startTweening];
		}
						
		m_dAnimationTime += fDelta;
	}
	
}

/* Input handlers */
- (void) playButtonHit {
	m_nSelectedMenu = kMainMenuItem_Play;

	// Disable the dispatcher so that we don't mess around with random taps
	[[InputEngine sharedInstance] disableDispatcher];
}

- (void) optionsButtonHit {
	m_nSelectedMenu = kMainMenuItem_Options;
	[[InputEngine sharedInstance] disableDispatcher];
}

- (void) creditsButtonHit {
	m_nSelectedMenu = kMainMenuItem_Credits;
	[[InputEngine sharedInstance] disableDispatcher];
}

- (void) donateButtonHit {
	NSURL* url = [NSURL URLWithString:DONATE_URL];
	[[UIApplication sharedApplication] openURL:url];
}

@end
