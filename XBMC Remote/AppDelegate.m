//
//  AppDelegate.m
//  XBMC Remote
//
//  Created by Giovanni Messina on 23/3/12.
//  Copyright (c) 2012 joethefox inc. All rights reserved.
//

#import "AppDelegate.h"
#import "mainMenu.h"
#import "MasterViewController.h"
#import "ViewControllerIPad.h"
#import "GlobalData.h"
#import <arpa/inet.h>
#import "InitialSlidingViewController.h"
#import "UIImageView+WebCache.h"

@implementation AppDelegate

NSMutableArray *mainMenuItems;
NSMutableArray *hostRightMenuItems;

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize windowController = _windowController;
@synthesize dataFilePath;
@synthesize arrayServerList;
@synthesize serverOnLine;
@synthesize serverVersion;
@synthesize serverMinorVersion;
@synthesize obj;
@synthesize playlistArtistAlbums;
@synthesize playlistMovies;
@synthesize playlistTvShows;
@synthesize rightMenuItems;
@synthesize serverName;
@synthesize nowPlayingMenuItems;
@synthesize serverVolume;
@synthesize remoteControlMenuItems;
@synthesize xbmcSettings;

+ (AppDelegate *) instance {
	return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark init

- (id) init {
	if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.dataFilePath = [documentsDirectory stringByAppendingPathComponent:@"serverList_saved.dat"];
        NSFileManager *fileManager1 = [NSFileManager defaultManager];
        if([fileManager1 fileExistsAtPath:self.dataFilePath]) {
            NSMutableArray *tempArray;
            tempArray = [NSKeyedUnarchiver unarchiveObjectWithFile:self.dataFilePath];
            [self setArrayServerList:tempArray];
        } else {
            arrayServerList = [[NSMutableArray alloc] init];
        }
        NSString *fullNamespace = @"LibraryCache";
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.libraryCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fullNamespace];
        if (![fileManager1 fileExistsAtPath:self.libraryCachePath]){
            [fileManager1 createDirectoryAtPath:self.libraryCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        self.epgCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"EPGDataCache"];
//        [[NSFileManager defaultManager] removeItemAtPath:self.epgCachePath error:nil];
        if (![fileManager1 fileExistsAtPath:self.epgCachePath]){
            [fileManager1 createDirectoryAtPath:self.epgCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
    }
	return self;
	
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    UIApplication *xbmcRemote = [UIApplication sharedApplication];
    if ([[userDefaults objectForKey:@"lockscreen_preference"] boolValue]==YES){
        xbmcRemote.idleTimerDisabled = YES;
    }
    else {
        xbmcRemote.idleTimerDisabled = NO;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    int thumbWidth;
    int tvshowHeight;
    NSString *filemodeRowHeight= @"44";
    NSString *filemodeThumbWidth= @"44";
    NSString *livetvThumbWidth= @"64";
    NSString *livetvRowHeight= @"76";
    NSString *channelEPGRowHeight= @"82";


    NSString *filemodeVideoType = @"video";
    NSString *filemodeMusicType = @"music";
    if ([[userDefaults objectForKey:@"fileType_preference"] boolValue]==YES){
        filemodeVideoType = @"files";
        filemodeMusicType = @"files";
    }
    NSNumber *animationStartBottomScreen = [NSNumber numberWithBool:YES];
    NSNumber *animationStartX = [NSNumber numberWithInt:0];
    
    obj=[GlobalData getInstance];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        float transform = 1.0f;
        if (IS_IPHONE_6) {
            transform = 1.18f;
        }
        else if (IS_IPHONE_6_PLUS){
            transform = 1.294f;
        }
        thumbWidth = (int)(PHONE_TV_SHOWS_BANNER_WIDTH * transform);
        tvshowHeight = (int)(PHONE_TV_SHOWS_BANNER_HEIGHT * transform);
        NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor colorWithRed:1 green:1 blue:1 alpha:1], NSForegroundColorAttributeName,
                                                   [UIFont boldSystemFontOfSize:18], NSFontAttributeName, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    }
    else {
        animationStartBottomScreen = [NSNumber numberWithBool:NO];
        animationStartX = [NSNumber numberWithInt: STACKSCROLL_WIDTH];
        thumbWidth = PAD_TV_SHOWS_BANNER_WIDTH;
        tvshowHeight = PAD_TV_SHOWS_BANNER_HEIGHT;
    }
    
    float itemMusicWidthIphone = 106.0f;
    float itemMusicHeightIphone = 106.0f;
    
    float itemMusicWidthIpad = 119.0f;
    float itemMusicHeightIpad = 119.0f;
    
    float itemMusicWidthLargeIpad = 158.0f;
    float itemMusicHeightLargeIpad = 158.0f;
    
    float fullscreenItemMusicWidthIpad = 164.0f;
    float fullscreenItemMusicHeightIpad = 164.0f;
    
    float itemMovieWidthIphone = 106.0f;
    float itemMovieHeightIphone = 151.0f;
    
    float itemMovieWidthIpad = 119.0f;
    float itemMovieHeightIpad = 170.0f;
    
    float itemMovieWidthLargeIpad =158.0f;
    float itemMovieHeightLargeIpad =  230.0f;
    
    float fullscreenItemMovieWidthIpad = 164.0f;
    float fullscreenItemMovieHeightIpad = 246.0f;
    
    float itemMovieHeightRecentlyIphone =  132.0f;
    float itemMovieHeightRecentlyIpad =  196.0f;
    
    [self.window makeKeyAndVisible];
    
    mainMenuItems = [NSMutableArray arrayWithCapacity:1];
    mainMenu *menu_Music = [[mainMenu alloc] init];
    mainMenu *menu_Favourite = [[mainMenu alloc] init];
    mainMenu *menu_Radio = [[mainMenu alloc] init];
    mainMenu *menu_Addons = [[mainMenu alloc] init];
    mainMenu *menu_Movie = [[mainMenu alloc] init];
    mainMenu *menu_TVShows = [[mainMenu alloc] init];
    mainMenu *menu_Picture = [[mainMenu alloc] init];
    mainMenu *menu_NowPlaying = [[mainMenu alloc] init];
    mainMenu *menu_Remote = [[mainMenu alloc] init];
    mainMenu *menu_Server = [[mainMenu alloc] init];
    mainMenu *menu_LiveTV = [[mainMenu alloc] init];

    menu_Music.subItem = [[mainMenu alloc] init];
    menu_Music.subItem.subItem = [[mainMenu alloc] init];
    menu_Music.subItem.subItem.subItem = [[mainMenu alloc] init];
    
    
    menu_Favourite.subItem = [[mainMenu alloc] init];
    
    menu_Addons.subItem = [[mainMenu alloc] init];
    menu_Addons.subItem.subItem = [[mainMenu alloc] init];
    menu_Addons.subItem.subItem.subItem = [[mainMenu alloc] init];

    menu_Movie.subItem = [[mainMenu alloc] init];
    menu_Movie.subItem.subItem = [[mainMenu alloc] init];
    
    menu_TVShows.subItem = [[mainMenu alloc] init];
    menu_TVShows.subItem.subItem = [[mainMenu alloc] init];
    
    menu_Picture.subItem = [[mainMenu alloc] init];
    menu_Picture.subItem.subItem = [[mainMenu alloc] init];
    
    menu_LiveTV.subItem = [[mainMenu alloc] init];
    menu_LiveTV.subItem.subItem = [[mainMenu alloc] init];

    
#pragma mark - Music
    menu_Music.mainLabel = NSLocalizedString(@"Music", nil);
    menu_Music.upperLabel = NSLocalizedString(@"Listen to", nil);
    menu_Music.icon = @"icon_home_music_alt";
    menu_Music.family = 1;
    menu_Music.enableSection=YES;
    menu_Music.mainButtons=[NSArray arrayWithObjects:@"st_album", @"st_artist", @"st_genre", @"st_filemode", @"st_album_recently", @"st_songs_recently", @"st_album_top100", @"st_songs_top100", @"st_album_recently_played", @"st_songs_recently_played", @"st_song", @"st_addons", @"st_music_playlist", @"st_music_playlist", nil]; //
    
    menu_Music.mainMethod=[NSMutableArray arrayWithObjects:
                      
                      [NSArray arrayWithObjects:
                       @"AudioLibrary.GetAlbums", @"method",
                       @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
                       nil],
                      
                      [NSArray arrayWithObjects:
                       @"AudioLibrary.GetArtists", @"method",
                       @"AudioLibrary.GetArtistDetails", @"extra_info_method",
                       nil],
                      
                      [NSArray arrayWithObjects:@"AudioLibrary.GetGenres", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"Files.GetSources", @"method", nil],
                      
                      [NSArray arrayWithObjects:
                       @"AudioLibrary.GetRecentlyAddedAlbums", @"method",
                       @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
                       nil],
                      
                      [NSArray arrayWithObjects:@"AudioLibrary.GetRecentlyAddedSongs", @"method", nil],
                      
                      [NSArray arrayWithObjects:
                       @"AudioLibrary.GetAlbums", @"method",
                       @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
                       nil],
                      
                      [NSArray arrayWithObjects:@"AudioLibrary.GetSongs", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"AudioLibrary.GetRecentlyPlayedAlbums", @"method",nil],
                      
                      [NSArray arrayWithObjects:@"AudioLibrary.GetRecentlyPlayedSongs", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"AudioLibrary.GetSongs", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"AudioLibrary.GetRoles", @"method", nil],
                      
                      nil];
    
    menu_Music.mainParameters=[NSMutableArray arrayWithObjects:
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableArray arrayWithObjects:NSLocalizedString(@"Album", nil), NSLocalizedString(@"Artist", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Play count", nil), nil], @"label",
                              [NSArray arrayWithObjects:@"label", @"genre", @"year", @"playcount", nil], @"method",
                              nil], @"available_methods",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist", @"playcount",  nil], @"properties",
                            nil],  @"parameters", NSLocalizedString(@"Albums", nil), @"label", @"Album", @"wikitype",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist", @"genre", @"description", @"albumlabel", @"fanart",
                             nil], @"properties",
                            nil], @"extra_info_parameters",
                           @"YES", @"enableCollectionView",
                           @"YES", @"enableLibraryCache",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"Not listened", nil), @"notWatched",
                            NSLocalizedString(@"Listened one time", nil), @"watchedOneTime",
                            NSLocalizedString(@"Listened %@ times", nil), @"watchedTimes",
                            nil], @"watchedListenedStrings",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIpad], @"height",
                             [NSNumber numberWithFloat:fullscreenItemMusicWidthIpad], @"fullscreenWidth",
                             [NSNumber numberWithFloat:fullscreenItemMusicHeightIpad], @"fullscreenHeight", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            [NSArray arrayWithObjects: @"thumbnail", @"genre", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Artists", nil), @"label", @"nocover_artist", @"defaultThumb", @"Artist", @"wikitype",
                           [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects: @"thumbnail", @"genre", @"instrument", @"style", @"mood", @"born", @"formed", @"description", @"died", @"disbanded", @"yearsactive", @"fanart", nil], @"properties",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSArray arrayWithObjects: @"roles", nil], @"18",
                             nil], @"kodiExtrasPropertiesMinimumVersion",
                            nil], @"extra_info_parameters",
                           @"YES", @"enableCollectionView",
                           @"YES", @"enableLibraryCache",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIpad], @"height",
                             [NSNumber numberWithFloat:fullscreenItemMusicWidthIpad], @"fullscreenWidth",
                             [NSNumber numberWithFloat:fullscreenItemMusicHeightIpad], @"fullscreenHeight", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            [NSArray arrayWithObjects: @"thumbnail", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Genres", nil), @"label", @"nocover_genre.png", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"enableLibraryCache",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            @"music", @"media",
                            nil], @"parameters", NSLocalizedString(@"Files", nil), @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"none", @"method",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist",  nil], @"properties",
                            nil],  @"parameters", NSLocalizedString(@"Added Albums", nil), @"label", @"Album", @"wikitype", NSLocalizedString(@"Recently added albums", nil), @"morelabel",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist", @"genre", @"description", @"albumlabel", @"fanart",
                             nil], @"properties",
                            nil], @"extra_info_parameters",
                           @"YES", @"enableCollectionView",

                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"none", @"method",
                             nil],@"sort",
                            //                            [NSDictionary dictionaryWithObjectsAndKeys:
                            //                             [NSNumber numberWithInt:0], @"start",
                            //                             [NSNumber numberWithInt:99], @"end",
                            //                             nil], @"limits",
                            [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"album", @"file", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Added Songs", nil), @"label", NSLocalizedString(@"Recently added songs", nil), @"morelabel", nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"descending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"playcount", @"method",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableArray arrayWithObjects:NSLocalizedString(@"Play count", nil), NSLocalizedString(@"Album", nil), NSLocalizedString(@"Artist", nil), NSLocalizedString(@"Year", nil), nil], @"label",
                              [NSArray arrayWithObjects:@"playcount", @"label", @"genre", @"year", nil], @"method",
                              nil], @"available_methods",
                             nil],@"sort",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:0], @"start",
                             [NSNumber numberWithInt:100], @"end",
                             nil], @"limits",
                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist",  @"playcount", nil], @"properties",
                            nil],  @"parameters", NSLocalizedString(@"Top 100 Albums", nil), @"label", @"Album", @"wikitype", NSLocalizedString(@"Top 100 Albums", nil), @"morelabel",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist", @"genre", @"description", @"albumlabel", @"fanart",
                             nil], @"properties",
                            nil], @"extra_info_parameters",
                           @"YES", @"enableCollectionView",

                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"descending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"playcount", @"method",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableArray arrayWithObjects:NSLocalizedString(@"Play count", nil), NSLocalizedString(@"Track", nil),NSLocalizedString(@"Title", nil), NSLocalizedString(@"Album", nil), NSLocalizedString(@"Artist", nil), NSLocalizedString(@"Rating", nil), NSLocalizedString(@"Year", nil), nil], @"label",
                              [NSArray arrayWithObjects:@"playcount", @"track", @"label", @"album", @"genre", @"rating", @"year", nil], @"method",
                              nil], @"available_methods",
                             nil],@"sort",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:0], @"start",
                             [NSNumber numberWithInt:100], @"end",
                             nil], @"limits",
                            [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"album", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Top 100 Songs", nil), @"label", NSLocalizedString(@"Top 100 Songs", nil), @"morelabel",
                           [NSNumber numberWithInt:5], @"numberOfStars",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"none", @"method",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist",  nil], @"properties",//@"genre", @"description", @"albumlabel", @"fanart",
                            nil], @"parameters", NSLocalizedString(@"Played albums", nil), @"label", @"Album", @"wikitype", NSLocalizedString(@"Recently played albums", nil), @"morelabel",
                           @"YES", @"enableCollectionView",

                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"none", @"method",
                             nil], @"sort",
                            //                            [NSDictionary dictionaryWithObjectsAndKeys:
                            //                             [NSNumber numberWithInt:0], @"start",
                            //                             [NSNumber numberWithInt:99], @"end",
                            //                             nil], @"limits",
                            [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"album", @"file", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Played songs", nil), @"label", NSLocalizedString(@"Recently played songs", nil), @"morelabel", nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"none", @"method",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableArray arrayWithObjects:NSLocalizedString(@"Name", nil),NSLocalizedString(@"Rating", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Play count", nil), NSLocalizedString(@"Track", nil), NSLocalizedString(@"Album", nil), NSLocalizedString(@"Artist", nil), nil], @"label",
                              [NSArray arrayWithObjects:@"label", @"rating", @"year", @"playcount", @"track", @"album", @"genre", nil], @"method",
                              nil], @"available_methods",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"album", @"file", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"All songs", nil), @"label", NSLocalizedString(@"All songs", nil), @"morelabel",
                           @"YES", @"enableLibraryCache",
                           [NSNumber numberWithInt:5], @"numberOfStars",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            @"music", @"media",
                            @"addons://sources/audio", @"directory",
                            [NSArray arrayWithObjects:@"thumbnail", @"file", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Music Add-ons", nil), @"label", NSLocalizedString(@"Music Add-ons", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"enableCollectionView",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            @"music", @"media",
                            @"special://musicplaylists", @"directory",
                            [NSArray arrayWithObjects:@"thumbnail", @"file", @"artist", @"album", @"duration", nil], @"properties",
                            [NSArray arrayWithObjects:@"thumbnail", @"file", @"artist", @"album", @"duration", nil], @"file_properties",
                            nil], @"parameters", NSLocalizedString(@"Music Playlists", nil), @"label", NSLocalizedString(@"Music Playlists", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"isMusicPlaylist",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"title", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Music Roles", nil), @"label", NSLocalizedString(@"Music Roles", nil), @"morelabel", @"nocover_genre", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          nil];
    
    menu_Music.mainFields=[NSArray arrayWithObjects:
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"albums",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"fanart", @"row4",
                       @"rating",@"row5",
                       @"albumid",@"row6",
                       @"playcount", @"row7",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"albumid",@"row8",
                       @"albumid", @"row9",
                       @"artist", @"row10",
                       @"genre",@"row11",
                       @"description",@"row12",
                       @"albumlabel",@"row13",
                       @"albumdetails",@"itemid_extra_info",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"artists",@"itemid",
                       @"label", @"row1",
                       @"genre", @"row2",
                       @"yearsactive", @"row3",
                       @"genre", @"row4",
                       @"disbanded",@"row5",
                       @"artistid",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"artistid",@"row8",
                       @"artistid", @"row9",
                       @"formed", @"row10",
                       @"artistid",@"row11",
                       @"description",@"row12",
                       @"instrument",@"row13",
                       @"style", @"row14",
                       @"mood", @"row15",
                       @"born", @"row16",
                       @"formed", @"row17",
                       @"died", @"row18",
                       @"roles", @"row20",
                       @"artistdetails",@"itemid_extra_info",
                       //@"", @"", @"", @"", @"", , @"", @"", , @"", @"", @"",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"genres",@"itemid",
                       @"label", @"row1",
                       @"genre", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"genreid",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"genreid",@"row8",
                       @"genreid", @"row9",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"sources",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"file",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"file",@"row8",
                       @"file", @"row9",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"albums",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"fanart", @"row4",
                       @"rating",@"row5",
                       @"albumid",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"albumid",@"row8",
                       @"albumid", @"row9",
                       @"artist", @"row10",
                       @"genre",@"row11",
                       @"description",@"row12",
                       @"albumlabel",@"row13",
                       @"albumdetails",@"itemid_extra_info",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"songs",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"duration", @"row4",
                       @"rating",@"row5",
                       @"songid",@"row6",
                       @"track",@"row7",
                       @"songid",@"row8",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"songid", @"row9",
                       @"file", @"row10",
                       @"artist", @"row11",
                       @"album", @"row12",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"albums",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"fanart", @"row4",
                       @"rating",@"row5",
                       @"albumid",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"albumid",@"row8",
                       @"albumid", @"row9",
                       @"artist", @"row10",
                       @"genre",@"row11",
                       @"description",@"row12",
                       @"albumlabel",@"row13",
                       @"playcount",@"row14",
                       @"albumdetails",@"itemid_extra_info",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"songs",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"duration", @"row4",
                       @"rating",@"row5",
                       @"songid",@"row6",
                       @"track",@"row7",
                       @"songid",@"row8",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"songid", @"row9",
                       @"file", @"row10",
                       @"artist", @"row11",
                       @"album", @"row12",
                       @"duration", @"row13",
                       @"rating", @"row14",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"albums",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"fanart", @"row4",
                       @"rating",@"row5",
                       @"albumid",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"albumid",@"row8",
                       @"albumid", @"row9",
                       @"artist", @"row10",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"songs",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"duration", @"row4",
                       @"rating",@"row5",
                       @"songid",@"row6",
                       @"track",@"row7",
                       @"songid",@"row8",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"songid", @"row9",
                       @"file", @"row10",
                       @"artist", @"row11",
                       @"album", @"row12",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"songs",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"duration", @"row4",
                       @"rating",@"row5",
                       @"songid",@"row6",
                       @"track",@"row7",
                       @"songid",@"row8",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"songid", @"row9",
                       @"file", @"row10",
                       @"artist", @"row11",
                       @"album", @"row12",
                       @"playcount", @"row13",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"files",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"file",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"file",@"row8",
                       @"file", @"row9",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"files",@"itemid",
                       @"label", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"duration", @"row4",
                       @"filetype",@"row5",
                       @"file",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"file",@"row8",
                       @"file", @"row9",
                       @"filetype", @"row10",
                       @"type", @"row11",
                       //                       @"filetype",@"row11",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"roles",@"itemid",
                       @"title", @"row1",
                       @"artist", @"row2",
                       @"year", @"row3",
                       @"duration", @"row4",
                       @"filetype",@"row5",
                       @"roleid",@"row6",
                       [NSNumber numberWithInt:0], @"playlistid",
                       @"roleid",@"row8",
                       @"roleid", @"row9",
                       nil],
                      
                      nil];
    menu_Music.rowHeight=53;
    menu_Music.thumbWidth=53;
    menu_Music.defaultThumb=@"nocover_music";
    menu_Music.watchModes = [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_listened", @"icon_listened", nil], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        nil];

    
    menu_Music.sheetActions=[NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Album Details", nil), NSLocalizedString(@"Search Wikipedia", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Artist Details", nil), NSLocalizedString(@"Search Wikipedia", nil), NSLocalizedString(@"Search last.fm charts", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), nil],
                        [NSArray array],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Album Details", nil), NSLocalizedString(@"Search Wikipedia", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Album Details", nil), NSLocalizedString(@"Search Wikipedia", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Album Details", nil), NSLocalizedString(@"Search Wikipedia", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                        [NSArray array],
                        [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Show Content", nil), nil],
                        [NSMutableArray array],
                        nil];
    
    menu_Music.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                              
                              [NSArray arrayWithObjects:@"AudioLibrary.GetSongs", @"method", @"YES", @"albumView", nil],
                              
                              [NSArray arrayWithObjects:
                               @"AudioLibrary.GetAlbums", @"method",
                               @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
                               nil],
                              
                              [NSArray arrayWithObjects:
                               @"AudioLibrary.GetAlbums", @"method",
                               @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
                               nil],
                              
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                              
                              [NSArray arrayWithObjects:
                               @"AudioLibrary.GetSongs", @"method",
                               @"YES", @"albumView",
                               nil],
                              
                              [NSArray array],
                              
                              [NSArray arrayWithObjects:
                               @"AudioLibrary.GetSongs", @"method",
                               @"YES", @"albumView",
                               nil],
                              
                              [NSArray array],
                              
                              [NSArray arrayWithObjects:
                               @"AudioLibrary.GetSongs", @"method",
                               @"YES", @"albumView",
                               nil],
                              
                              [NSArray array],
                              
                              [NSArray array],
                              
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                              
                              [NSArray array],
                              
                              [NSArray arrayWithObjects:
                               @"AudioLibrary.GetArtists", @"method",
                               @"AudioLibrary.GetArtistDetails", @"extra_info_method",
                               nil],
                              
                              nil];
    menu_Music.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"track", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"fanart", nil], @"properties",
                                    nil], @"parameters", @"Songs", @"label", nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"year", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist",  nil], @"properties",
                                    nil],  @"parameters", @"Albums", @"label", @"Album", @"wikitype",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist", @"genre", @"description", @"albumlabel", @"fanart",
                                     nil], @"properties",
                                    nil], @"extra_info_parameters",
                                   @"YES", @"enableCollectionView",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMusicWidthLargeIpad], @"width",
                                     [NSNumber numberWithFloat:itemMusicHeightLargeIpad], @"height", nil], @"ipad",
                                    nil], @"itemSizes",
                                   nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"label", @"method",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableArray arrayWithObjects:NSLocalizedString(@"Album", nil), NSLocalizedString(@"Artist", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Play count", nil), nil], @"label",
                                      [NSArray arrayWithObjects:@"label", @"genre", @"year", @"playcount", nil], @"method",
                                      nil], @"available_methods",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist",  nil], @"properties",
                                    nil],  @"parameters", @"Albums", @"label", @"Album", @"wikitype",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist", @"genre", @"description", @"albumlabel", @"fanart",
                                     nil], @"properties",
                                    nil], @"extra_info_parameters",
                                   @"YES", @"enableCollectionView",
                                   @"YES", @"enableLibraryCache",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    NSLocalizedString(@"Not listened", nil), @"notWatched",
                                    NSLocalizedString(@"Listened one time", nil), @"watchedOneTime",
                                    NSLocalizedString(@"Listened %@ times", nil), @"watchedTimes",
                                    nil], @"watchedListenedStrings",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                                     [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                                    nil], @"itemSizes",
                                   nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"label", @"method",
                                     nil],@"sort",
                                    filemodeMusicType, @"media",
                                    nil], @"parameters", @"Files", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"track", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"fanart", nil], @"properties",
                                    nil], @"parameters", @"Songs", @"label", nil],
                                  
                                  [NSArray array],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"track", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"fanart", nil], @"properties",
                                    nil], @"parameters", @"Songs", @"label", nil],
                                  
                                  [NSArray array],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"track", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"fanart", nil], @"properties",
                                    nil], @"parameters", @"Songs", @"label", nil],
                                  
                                  [NSArray array],
                                  
                                  [NSArray array],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"none", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"thumbnail", nil], @"file_properties",
                                    @"music", @"media",
                                    nil], @"parameters", @"Files", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", @"53", @"thumbWidth",
                                   @"YES", @"enableCollectionView",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                    nil], @"itemSizes",
                                   nil],
                                  
//                                  [NSArray array],
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"none", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"thumbnail", @"artist", @"duration", nil], @"file_properties",
                                    @"music", @"media",
                                    nil], @"parameters", @"Files", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", @"53", @"thumbWidth", nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"label", @"method",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects: @"thumbnail", @"genre", nil], @"properties",
                                    nil], @"parameters", NSLocalizedString(@"Artists", nil), @"label", @"nocover_artist", @"defaultThumb", @"Artist", @"wikitype",
                                   [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects: @"thumbnail", @"genre", @"instrument", @"style", @"mood", @"born", @"formed", @"description", @"died", @"disbanded", @"yearsactive", @"fanart",nil], @"properties",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSArray arrayWithObjects: @"roles", nil], @"18",
                                     nil], @"kodiExtrasPropertiesMinimumVersion",
                                    nil], @"extra_info_parameters",
                                   @"YES", @"enableCollectionView",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                                     [NSNumber numberWithFloat:itemMusicHeightIpad], @"height",
                                     [NSNumber numberWithFloat:fullscreenItemMusicWidthIpad], @"fullscreenWidth",
                                     [NSNumber numberWithFloat:fullscreenItemMusicHeightIpad], @"fullscreenHeight", nil], @"ipad",
                                    nil], @"itemSizes",
                                   nil],
                                  nil];
    
    menu_Music.subItem.mainFields=[NSArray arrayWithObjects:
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"songs",@"itemid",
                               @"label", @"row1",
                               @"artist", @"row2",
                               @"year", @"row3",
                               @"duration", @"row4",
                               @"rating",@"row5",
                               @"songid",@"row6",
                               @"track",@"row7",
                               @"albumid",@"row8",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"songid", @"row9",
                               @"file", @"row10",
                               @"artist", @"row11",
                               nil],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"albums",@"itemid",
                               @"label", @"row1",
                               @"artist", @"row2",
                               @"year", @"row3",
                               @"fanart", @"row4",
                               @"rating",@"row5",
                               @"albumid",@"row6",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"albumid",@"row8",
                               @"albumid", @"row9",
                               @"artist", @"row10",
                               @"genre",@"row11",
                               @"description",@"row12",
                               @"albumlabel",@"row13",
                               @"albumdetails",@"itemid_extra_info",
                               nil],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"albums",@"itemid",
                               @"label", @"row1",
                               @"artist", @"row2",
                               @"year", @"row3",
                               @"fanart", @"row4",
                               @"rating",@"row5",
                               @"albumid",@"row6",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"albumid",@"row8",
                               @"albumid", @"row9",
                               @"artist", @"row10",
                               @"genre",@"row11",
                               @"description",@"row12",
                               @"albumlabel",@"row13",
                               @"albumdetails",@"itemid_extra_info",
                               nil],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"files",@"itemid",
                               @"label", @"row1",
                               @"filetype", @"row2",
                               @"filetype", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"file",@"row6",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"file",@"row8",
                               @"file", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"songs",@"itemid",
                               @"label", @"row1",
                               @"artist", @"row2",
                               @"year", @"row3",
                               @"duration", @"row4",
                               @"rating",@"row5",
                               @"songid",@"row6",
                               @"track",@"row7",
                               @"albumid",@"row8",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"songid", @"row9",
                               @"file", @"row10",
                               @"artist", @"row11",
                               nil],
                              
                              [NSDictionary dictionary],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"songs",@"itemid",
                               @"label", @"row1",
                               @"artist", @"row2",
                               @"year", @"row3",
                               @"duration", @"row4",
                               @"rating",@"row5",
                               @"songid",@"row6",
                               @"track",@"row7",
                               @"albumid",@"row8",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"songid", @"row9",
                               @"file", @"row10",
                               @"artist", @"row11",
                               nil],
                              
                              [NSDictionary dictionary],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"songs",@"itemid",
                               @"label", @"row1",
                               @"artist", @"row2",
                               @"year", @"row3",
                               @"duration", @"row4",
                               @"rating",@"row5",
                               @"songid",@"row6",
                               @"track",@"row7",
                               @"albumid",@"row8",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"songid", @"row9",
                               @"file", @"row10",
                               @"artist", @"row11",
                               nil],
                              
                              [NSDictionary dictionary],
                              
                              [NSDictionary dictionary],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"files",@"itemid",
                               @"label", @"row1",
                               @"filetype", @"row2",
                               @"filetype", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"file",@"row6",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"file",@"row8",
                               @"file", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              
//                              [NSDictionary dictionary],
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"files",@"itemid",
                               @"label", @"row1",
                               @"artist", @"row2",
                               @"year", @"row3",
                               @"duration", @"row4",
                               @"filetype",@"row5",
                               @"file",@"row6",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"file",@"row8",
                               @"file", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"artists",@"itemid",
                               @"label", @"row1",
                               @"genre", @"row2",
                               @"yearsactive", @"row3",
                               @"genre", @"row4",
                               @"disbanded",@"row5",
                               @"artistid",@"row6",
                               [NSNumber numberWithInt:0], @"playlistid",
                               @"artistid",@"row8",
                               @"artistid", @"row9",
                               @"formed", @"row10",
                               @"artistid",@"row11",
                               @"description",@"row12",
                               @"instrument",@"row13",
                               @"style", @"row14",
                               @"mood", @"row15",
                               @"born", @"row16",
                               @"formed", @"row17",
                               @"died", @"row18",
                               @"roles", @"row20",
                               @"artistdetails",@"itemid_extra_info",
                               //@"", @"", @"", @"", @"", , @"", @"", , @"", @"", @"",
                               nil],
                              
                              nil];
    menu_Music.subItem.enableSection=NO;
    menu_Music.subItem.rowHeight=53;
    menu_Music.subItem.thumbWidth=53;
    menu_Music.subItem.defaultThumb=@"nocover_music";
    menu_Music.subItem.sheetActions=[NSArray arrayWithObjects:
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil),  NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Album Details", nil), NSLocalizedString(@"Search Wikipedia", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Album Details", nil), NSLocalizedString(@"Search Wikipedia", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
//                                [NSArray array],
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                
                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Artist Details", nil), NSLocalizedString(@"Search Wikipedia", nil), NSLocalizedString(@"Search last.fm charts", nil), nil],
                                nil];//, @"Stream to iPhone"
    menu_Music.subItem.originYearDuration=248;
    menu_Music.subItem.widthLabel=252;
    menu_Music.subItem.showRuntime=[NSArray arrayWithObjects:
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:NO],
                               nil];
    
    menu_Music.subItem.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                                      
                                      [NSArray array],
                                      
                                      [NSArray arrayWithObjects:@"AudioLibrary.GetSongs", @"method", @"YES", @"albumView", nil],
                                      
                                      [NSArray arrayWithObjects:@"AudioLibrary.GetSongs", @"method", @"YES", @"albumView", nil],
                                      
                                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      [NSArray array],
                                      [NSArray array],
                                      [NSArray array],
                                      [NSArray array],
                                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
//                                      [NSArray array],
                                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                      
                                      [NSArray arrayWithObjects:
                                       @"AudioLibrary.GetAlbums", @"method",
                                       @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
                                       nil],
                                      
                                      nil];
    
    menu_Music.subItem.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                          
                                          [NSArray array],
                                          
                                          [NSMutableArray arrayWithObjects:
                                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"ascending",@"order",
                                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                             @"track", @"method",
                                             nil],@"sort",
                                            [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"fanart", nil], @"properties",
                                            nil], @"parameters", @"Songs", @"label", nil],
                                          
                                          [NSMutableArray arrayWithObjects:
                                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"ascending",@"order",
                                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                             @"track", @"method",
                                             nil],@"sort",
                                            [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"fanart", nil], @"properties",
                                            nil], @"parameters", @"Songs", @"label", nil],
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSMutableArray arrayWithObjects:filemodeRowHeight, @"rowHeight", @"53", @"thumbWidth", nil],
                                          
//                                          [NSArray array],
                                          [NSMutableArray arrayWithObjects:filemodeRowHeight, @"rowHeight", @"53", @"thumbWidth", nil],
                                          
                                          [NSMutableArray arrayWithObjects:
                                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"ascending",@"order",
                                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                             @"year", @"method",
                                             nil],@"sort",
                                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist",  nil], @"properties",
                                            nil],  @"parameters", @"Albums", @"label", @"Album", @"wikitype",
                                           [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSArray arrayWithObjects:@"year", @"thumbnail", @"artist", @"genre", @"description", @"albumlabel", @"fanart",
                                             nil], @"properties",
                                            nil], @"extra_info_parameters",
                                           @"YES", @"enableCollectionView",
                                           @"roleid", @"combinedFilter",
                                           [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                             [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                            [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:itemMusicWidthLargeIpad], @"width",
                                             [NSNumber numberWithFloat:itemMusicHeightLargeIpad], @"height", nil], @"ipad",
                                            nil], @"itemSizes",
                                           nil],
                                          
                                          nil];
    menu_Music.subItem.subItem.mainFields=[NSArray arrayWithObjects:
                                      
                                      [NSArray array],
                                      
                                      [NSDictionary  dictionaryWithObjectsAndKeys:
                                       @"songs",@"itemid",
                                       @"label", @"row1",
                                       @"artist", @"row2",
                                       @"year", @"row3",
                                       @"duration", @"row4",
                                       @"rating",@"row5",
                                       @"songid",@"row6",
                                       @"track",@"row7",
                                       @"albumid",@"row8",
                                       [NSNumber numberWithInt:0], @"playlistid",
                                       @"songid", @"row9",
                                       @"file", @"row10",
                                       @"artist", @"row11",
                                       nil],
                                      
                                      [NSDictionary  dictionaryWithObjectsAndKeys:
                                       @"songs",@"itemid",
                                       @"label", @"row1",
                                       @"artist", @"row2",
                                       @"year", @"row3",
                                       @"duration", @"row4",
                                       @"rating",@"row5",
                                       @"songid",@"row6",
                                       @"track",@"row7",
                                       @"albumid",@"row8",
                                       [NSNumber numberWithInt:0], @"playlistid",
                                       @"songid", @"row9",
                                       @"file", @"row10",
                                       @"artist", @"row11",
                                       nil],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSDictionary  dictionaryWithObjectsAndKeys:
                                       @"albums",@"itemid",
                                       @"label", @"row1",
                                       @"artist", @"row2",
                                       @"year", @"row3",
                                       @"fanart", @"row4",
                                       @"rating",@"row5",
                                       @"albumid",@"row6",
                                       [NSNumber numberWithInt:0], @"playlistid",
                                       @"albumid",@"row8",
                                       @"albumid", @"row9",
                                       @"artist", @"row10",
                                       @"genre",@"row11",
                                       @"description",@"row12",
                                       @"albumlabel",@"row13",
                                       @"albumdetails",@"itemid_extra_info",
                                       nil],
                                      
                                      nil];
    menu_Music.subItem.subItem.rowHeight=53;
    menu_Music.subItem.subItem.thumbWidth=53;
    menu_Music.subItem.subItem.defaultThumb=@"nocover_music";
    menu_Music.subItem.subItem.sheetActions=[NSArray arrayWithObjects:
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],//@"Stream to iPhone",
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        [NSArray array],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
//                                        [NSArray array],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Play in shuffle mode", nil), NSLocalizedString(@"Album Details", nil), NSLocalizedString(@"Search Wikipedia", nil), nil],
                                        nil];
    menu_Music.subItem.subItem.showRuntime=[NSArray arrayWithObjects:
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:YES],
                                       [NSNumber numberWithBool:NO],
                                       nil];
    
    menu_Music.subItem.subItem.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                                              
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray arrayWithObjects:@"AudioLibrary.GetSongs", @"method", @"YES", @"albumView", nil],
                                              nil];
    
    menu_Music.subItem.subItem.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                                  
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSArray array],
                                                  [NSMutableArray arrayWithObjects:
                                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     @"ascending",@"order",
                                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                                     @"track", @"method",
                                                     nil],@"sort",
                                                    [NSArray arrayWithObjects:@"genre", @"year", @"duration", @"track", @"thumbnail", @"rating", @"playcount", @"artist", @"albumid", @"file", @"fanart", nil], @"properties",
                                                    nil], @"parameters", @"Songs", @"label", nil],
                                                  nil];
    
    menu_Music.subItem.subItem.subItem.mainFields=[NSArray arrayWithObjects:
                                              
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSArray array],
                                              [NSDictionary  dictionaryWithObjectsAndKeys:
                                               @"songs",@"itemid",
                                               @"label", @"row1",
                                               @"artist", @"row2",
                                               @"year", @"row3",
                                               @"duration", @"row4",
                                               @"rating",@"row5",
                                               @"songid",@"row6",
                                               @"track",@"row7",
                                               @"albumid",@"row8",
                                               [NSNumber numberWithInt:0], @"playlistid",
                                               @"songid", @"row9",
                                               @"file", @"row10",
                                               @"artist", @"row11",
                                               nil],
                                              
                                              nil];
    menu_Music.subItem.subItem.subItem.rowHeight=53;
    menu_Music.subItem.subItem.subItem.thumbWidth=53;
    menu_Music.subItem.subItem.subItem.defaultThumb=@"nocover_music";
    menu_Music.subItem.subItem.subItem.sheetActions=[NSArray arrayWithObjects:
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray array],
                                                [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil),  NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                                nil];
    menu_Music.subItem.subItem.subItem.originYearDuration=248;
    menu_Music.subItem.subItem.subItem.widthLabel=252;
    menu_Music.subItem.subItem.subItem.showRuntime=[NSArray arrayWithObjects:
                                               [NSNumber numberWithBool:YES],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               [NSNumber numberWithBool:NO],
                                               nil];

#pragma mark - Radio Favourite
    menu_Favourite.mainLabel = NSLocalizedString(@"Radio Favourite", nil);
    menu_Favourite.upperLabel = NSLocalizedString(@"Listen to", nil);
    menu_Favourite.icon = @"icon_home_tv_alt";
    menu_Favourite.family = 1;
    menu_Favourite.enableSection = YES;

#pragma mark - Radio
    menu_Radio.mainLabel = NSLocalizedString(@"Internet Radio", nil);
    menu_Radio.upperLabel = NSLocalizedString(@"Listen to", nil);
    menu_Radio.icon = @"icon_home_tv_alt";
    menu_Radio.family = 1;
    menu_Radio.enableSection = YES;
    
#pragma mark - Addons

    menu_Addons.mainLabel = NSLocalizedString(@"Music Addons", nil);
    menu_Addons.upperLabel = NSLocalizedString(@"Listen to", nil);
    menu_Addons.icon = @"icon_home_music_alt";
    menu_Addons.family = 1;
    menu_Addons.enableSection=YES;
    
    menu_Addons.mainMethod=[NSMutableArray arrayWithObjects:
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                           nil];
    
    menu_Addons.mainParameters=[NSMutableArray arrayWithObjects:
                               [NSMutableArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"ascending",@"order",
                                  [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                  @"label", @"method",
                                  nil],@"sort",
                                 @"music", @"media",
                                 @"addons://sources/audio", @"directory",
                                 [NSArray arrayWithObjects:@"thumbnail", @"file", nil], @"properties",
                                 nil], @"parameters", NSLocalizedString(@"Music Add-ons", nil), @"label", NSLocalizedString(@"Music Add-ons", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                                @"YES", @"enableCollectionView",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                  [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                                  [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                                 nil], @"itemSizes",
                                nil],
                               nil];
    
    menu_Addons.mainFields=[NSArray arrayWithObjects:
                           
                           [NSDictionary  dictionaryWithObjectsAndKeys:
                            @"files",@"itemid",
                            @"label", @"row1",
                            @"year", @"row2",
                            @"year", @"row3",
                            @"runtime", @"row4",
                            @"rating",@"row5",
                            @"file",@"row6",
                            [NSNumber numberWithInt:0], @"playlistid",
                            @"file",@"row8",
                            @"file", @"row9",
                            nil],
                            nil];
    menu_Addons.rowHeight=53;
    menu_Addons.thumbWidth=53;
    menu_Addons.defaultThumb=@"nocover_music";
    menu_Addons.watchModes = [NSArray arrayWithObjects:

                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSArray array], @"modes",
                              [NSArray array], @"icons",
                              nil],
                             nil];
    
    
    menu_Addons.sheetActions=[NSArray arrayWithObjects:
                             [NSArray array],
                             nil];
    
    menu_Addons.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                                   
                                   [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                   
                                   nil];
    menu_Addons.subItem.mainParameters=[NSMutableArray arrayWithObjects:

                                       [NSMutableArray arrayWithObjects:
                                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"ascending",@"order",
                                          [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                          @"none", @"method",
                                          nil],@"sort",
                                         [NSArray arrayWithObjects:@"thumbnail", nil], @"file_properties",
                                         @"music", @"media",
                                         nil], @"parameters", @"Files", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", @"53", @"thumbWidth",
                                        @"YES", @"enableCollectionView",
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                          [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                         [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                          [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                         nil], @"itemSizes",
                                        nil],
                                        nil];
    
    menu_Addons.subItem.mainFields=[NSArray arrayWithObjects:

                                   [NSDictionary  dictionaryWithObjectsAndKeys:
                                    @"files",@"itemid",
                                    @"label", @"row1",
                                    @"filetype", @"row2",
                                    @"filetype", @"row3",
                                    @"filetype", @"row4",
                                    @"filetype",@"row5",
                                    @"file",@"row6",
                                    [NSNumber numberWithInt:0], @"playlistid",
                                    @"file",@"row8",
                                    @"file", @"row9",
                                    @"filetype", @"row10",
                                    @"type", @"row11",
                                    nil],
                                   
                                   nil];
    menu_Addons.subItem.enableSection=NO;
    menu_Addons.subItem.rowHeight=53;
    menu_Addons.subItem.thumbWidth=53;
    menu_Addons.subItem.defaultThumb=@"nocover_music";
    menu_Addons.subItem.sheetActions=[NSArray arrayWithObjects:
                                     [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                     nil];
    
    menu_Addons.subItem.originYearDuration=248;
    menu_Addons.subItem.widthLabel=252;
    menu_Addons.subItem.showRuntime=[NSArray arrayWithObjects:
                                    [NSNumber numberWithBool:YES],
                                    nil];
    
    menu_Addons.subItem.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                                           [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                           nil];
    
    menu_Addons.subItem.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                               [NSMutableArray arrayWithObjects:filemodeRowHeight, @"rowHeight", @"53", @"thumbWidth", nil],
                                               nil];
    menu_Addons.subItem.subItem.mainFields=[NSArray arrayWithObjects:
                                           [NSArray array],
                                           nil];
    menu_Addons.subItem.subItem.rowHeight=53;
    menu_Addons.subItem.subItem.thumbWidth=53;
    menu_Addons.subItem.subItem.defaultThumb=@"nocover_music";
    menu_Addons.subItem.subItem.sheetActions=[NSArray arrayWithObjects:
                                             [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                             nil];
    menu_Addons.subItem.subItem.showRuntime=[NSArray arrayWithObjects:
                                            [NSNumber numberWithBool:YES],
                                            nil];
    
    menu_Addons.subItem.subItem.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                                                   [NSArray array],
                                                   nil];
    
    menu_Addons.subItem.subItem.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                                       [NSArray array],
                                                       nil];
    
    menu_Addons.subItem.subItem.subItem.mainFields=[NSArray arrayWithObjects:
                                                   
                                                   [NSArray array],

                                                   
                                                   nil];
    menu_Addons.subItem.subItem.subItem.rowHeight=53;
    menu_Addons.subItem.subItem.subItem.thumbWidth=53;
    menu_Addons.subItem.subItem.subItem.defaultThumb=@"nocover_music";
    menu_Addons.subItem.subItem.subItem.sheetActions=[NSArray arrayWithObjects:
                                                     [NSArray array],

                                                     nil];
    menu_Addons.subItem.subItem.subItem.originYearDuration=248;
    menu_Addons.subItem.subItem.subItem.widthLabel=252;
    menu_Addons.subItem.subItem.subItem.showRuntime=[NSArray arrayWithObjects:
                                                    [NSNumber numberWithBool:NO],
                                                    nil];
    

#pragma mark - Movies
    menu_Movie.mainLabel = NSLocalizedString(@"Movies", nil);
    menu_Movie.upperLabel = NSLocalizedString(@"Watch your", nil);
    menu_Movie.icon = @"icon_home_movie_alt";
    menu_Movie.family = 1;
    menu_Movie.enableSection=YES;
    menu_Movie.noConvertTime = YES;
    menu_Movie.mainButtons=[NSArray arrayWithObjects:@"st_movie", @"st_movie_genre", @"st_movie_set", @"st_movie_recently", @"st_concert", @"st_filemode", @"st_addons", @"st_livetv", nil];
    menu_Movie.mainMethod=[NSMutableArray arrayWithObjects:
                      [NSArray arrayWithObjects:
                       @"VideoLibrary.GetMovies", @"method",
                       @"VideoLibrary.GetMovieDetails", @"extra_info_method",
                       nil],
                      
                      [NSArray arrayWithObjects:@"VideoLibrary.GetGenres", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"VideoLibrary.GetMovieSets", @"method", nil],
                      
                      [NSArray arrayWithObjects:
                       @"VideoLibrary.GetRecentlyAddedMovies", @"method",
                       @"VideoLibrary.GetMovieDetails", @"extra_info_method",
                       nil],
                      
                      [NSArray arrayWithObjects:@"VideoLibrary.GetMusicVideos", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"Files.GetSources", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                      
//                      [NSArray arrayWithObjects:@"PVR.GetChannelGroups", @"method", nil],
                      
                      nil];
    
    menu_Movie.mainParameters=[NSMutableArray arrayWithObjects:
                          [NSMutableArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableArray arrayWithObjects:NSLocalizedString(@"Title", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Rating", nil), NSLocalizedString(@"Duration", nil), NSLocalizedString(@"Date added", nil), NSLocalizedString(@"Play count", nil), nil], @"label",
                              [NSArray arrayWithObjects:@"label", @"year", @"rating", @"runtime", @"dateadded", @"playcount", nil], @"method",
                              nil], @"available_methods",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"trailer",  @"file", @"dateadded", nil], @"properties", //, @"fanart"
                            nil], @"parameters", NSLocalizedString(@"Movies", nil), @"label", @"Movie", @"wikitype",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"studio", @"director", @"plot", @"mpaa", @"votes", @"cast", @"file", @"fanart", @"resume", @"trailer", nil], @"properties",
                            nil], @"extra_info_parameters",
                           @"YES", @"FrodoExtraArt",
                           @"YES", @"enableCollectionView",
                           @"YES", @"enableLibraryCache",
                           @"YES", @"enableLibraryFullScreen",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieHeightIpad], @"height",
                             [NSNumber numberWithFloat:fullscreenItemMovieWidthIpad], @"fullscreenWidth",
                             [NSNumber numberWithFloat:fullscreenItemMovieHeightIpad], @"fullscreenHeight", nil], @"ipad",
                            nil], @"itemSizes",
//                           @"YES", @"collectionViewRecentlyAdded",
//                           [NSDictionary dictionaryWithObjectsAndKeys:
//                            [NSDictionary dictionaryWithObjectsAndKeys:
//                             @"fullWidth", @"width",
//                             [NSNumber numberWithFloat:itemMovieHeightRecentlyIphone], @"height", nil], @"iphone",
//                            [NSDictionary dictionaryWithObjectsAndKeys:
//                             @"fullWidth", @"width",
//                             [NSNumber numberWithFloat:itemMovieHeightRecentlyIpad], @"height", nil], @"ipad",
//                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            @"movie", @"type",
                            [NSArray arrayWithObjects:@"thumbnail", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Movie Genres", nil), @"label", @"nocover_movie_genre.png", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"enableLibraryCache",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableArray arrayWithObjects:NSLocalizedString(@"Name", nil), NSLocalizedString(@"Play count", nil), nil], @"label",
                              [NSArray arrayWithObjects:@"label", @"playcount", nil], @"method",
                              nil], @"available_methods",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"thumbnail", @"playcount", nil], @"properties",
                            nil], @"parameters",
                           @"YES", @"enableCollectionView",
                           @"YES", @"enableLibraryCache",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieHeightIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           NSLocalizedString(@"Movie Sets", nil), @"label", nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"none", @"method",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"trailer", @"fanart", @"file", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Added Movies", nil), @"label", @"Movie", @"wikitype",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"studio", @"director", @"plot", @"mpaa", @"votes", @"cast", @"file", @"fanart", @"resume", @"trailer", nil], @"properties",
                            nil], @"extra_info_parameters",
                           @"YES", @"FrodoExtraArt",
                           @"YES", @"enableCollectionView",
                           @"YES", @"collectionViewRecentlyAdded",
                           @"YES", @"enableLibraryFullScreen",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"fullWidth", @"width",
                             [NSNumber numberWithFloat:itemMovieHeightRecentlyIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"fullWidth", @"width",
                             [NSNumber numberWithFloat:itemMovieHeightRecentlyIpad], @"height",
                             [NSNumber numberWithFloat:502], @"fullscreenWidth",
                             [NSNumber numberWithFloat:206.0f], @"fullscreenHeight", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableArray arrayWithObjects:NSLocalizedString(@"Name", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Play count", nil), nil], @"label",
                              [NSArray arrayWithObjects:@"label", @"year", @"playcount", nil], @"method",
                              nil], @"available_methods",
                             nil],@"sort",
                            [NSArray arrayWithObjects:@"year", @"playcount", @"thumbnail", @"genre", @"runtime", @"studio", @"director", @"plot", @"file", @"fanart", @"resume", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Music Videos", nil), @"label", NSLocalizedString(@"Music Videos", nil), @"morelabel", @"Movie", @"wikitype",
                           @"YES", @"enableCollectionView",
                           @"YES", @"enableLibraryCache",
                           @"YES", @"enableLibraryFullScreen",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieHeightIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieHeightIpad], @"height",
                             [NSNumber numberWithFloat:fullscreenItemMovieWidthIpad], @"fullscreenWidth",
                             [NSNumber numberWithFloat:fullscreenItemMovieHeightIpad], @"fullscreenHeight", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],

                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"video", @"media",
                            nil], @"parameters", @"Files", @"label", NSLocalizedString(@"Files", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            @"video", @"media",
                            @"addons://sources/video", @"directory",
                            [NSArray arrayWithObjects:@"thumbnail", nil], @"properties",
                            nil], @"parameters", @"Video Add-ons", @"label", NSLocalizedString(@"Video Add-ons", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"enableCollectionView",

                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
//                          [NSMutableArray arrayWithObjects:
//                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                            @"tv", @"channeltype",
//                            nil], @"parameters", @"Live TV", @"label", NSLocalizedString(@"Live TV", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
//                           @"YES", @"enableCollectionView",
//                           [NSDictionary dictionaryWithObjectsAndKeys:
//                            [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
//                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
//                            [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
//                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
//                            nil], @"itemSizes",
//                           nil],
                          //                          "plot" and "runtime" and "plotoutline"
                          nil];
    
    menu_Movie.mainFields=[NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"movies",@"itemid",
                       @"label", @"row1",
                       @"genre", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"movieid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"movieid",@"row8",
                       @"movieid", @"row9",
                       @"playcount",@"row10",
                       @"trailer",@"row11",
                       @"plot",@"row12",
                       @"mpaa",@"row13",
                       @"votes",@"row14",
                       @"studio",@"row15",
                       @"cast",@"row16",
                       @"file",@"row7",
                       @"director",@"row17",
                       @"resume", @"row18",
                       @"dateadded", @"row19",
                       @"moviedetails",@"itemid_extra_info",
                       nil],
                      
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"genres",@"itemid",
                       @"label", @"row1",
                       @"label", @"row2",
                       @"disable", @"row3",
                       @"disable", @"row4",
                       @"disable",@"row5",
                       @"genre",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"genreid",@"row8",
                       nil],
                      
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"sets",@"itemid",
                       @"label", @"row1",
                       @"disable", @"row2",
                       @"disable", @"row3",
                       @"disable", @"row4",
                       @"disable",@"row5",
                       @"setid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"setid",@"row8",
                       @"setid",@"row9",
                       @"playcount",@"row10",
                       nil],

                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"movies",@"itemid",
                       @"label", @"row1",
                       @"genre", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"movieid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"movieid",@"row8",
                       @"movieid", @"row9",
                       @"playcount",@"row10",
                       @"trailer",@"row11",
                       @"plot",@"row12",
                       @"mpaa",@"row13",
                       @"votes",@"row14",
                       @"studio",@"row15",
                       @"cast",@"row16",
                       @"file",@"row7",
                       @"director",@"row17",
                       @"resume", @"row18",
                       @"moviedetails",@"itemid_extra_info",
                       nil],
                      
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"musicvideos",@"itemid",
                       @"label", @"row1",
                       @"genre", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"musicvideoid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"musicvideoid",@"row8",
                       @"musicvideoid", @"row9",
                       @"director",@"row10",
                       @"studio",@"row11",
                       @"plot",@"row12",
                       @"playcount",@"row13",
                       @"resume",@"row14",
                       @"votes",@"row15",
                       @"cast",@"row16",
                       @"file",@"row7",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"sources",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"file",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"file",@"row8",
                       @"file", @"row9",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"files",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"file",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"file",@"row8",
                       @"file", @"row9",
                       nil],
                      
//                      [NSDictionary  dictionaryWithObjectsAndKeys:
//                       @"channelgroups",@"itemid",
//                       @"label", @"row1",
//                       @"year", @"row2",
//                       @"year", @"row3",
//                       @"runtime", @"row4",
//                       @"rating",@"row5",
//                       @"channelgroupid",@"row6",
//                       [NSNumber numberWithInt:1], @"playlistid",
//                       @"channelgroupid",@"row8",
//                       @"channelgroupid", @"row9",
//                       nil],
                      
                      nil];
    menu_Movie.rowHeight=76;
    menu_Movie.thumbWidth=53;
    menu_Movie.defaultThumb=@"nocover_movies";
    menu_Movie.sheetActions=[NSArray arrayWithObjects:
                        [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Movie Details", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                        [NSArray array],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                        [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Movie Details", nil), nil], //, NSLocalizedString(@"Open with VLC", nil),
                        [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Music Video Details", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                        [NSArray array],
                        [NSArray array],
//                        [NSArray array],
                        nil];
    //    menu_Movie.showInfo = YES;
    menu_Movie.showInfo = [NSArray arrayWithObjects:
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
//                      [NSNumber numberWithBool:YES],
                      nil];
    menu_Movie.watchModes = [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
//                        [NSDictionary dictionaryWithObjectsAndKeys:
//                         [NSArray array], @"modes",
//                         [NSArray array], @"icons",
//                         nil],
                        nil];
    
    menu_Movie.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                              [NSArray array],
                              
                              [NSArray arrayWithObjects:
                               @"VideoLibrary.GetMovies", @"method",
                               @"VideoLibrary.GetMovieDetails", @"extra_info_method",
                               nil],

                              [NSArray arrayWithObjects:
                               @"VideoLibrary.GetMovies", @"method",
                               @"VideoLibrary.GetMovieDetails", @"extra_info_method",
                               nil],
                              
                              [NSArray array],
                              [NSArray array],
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
//                              [NSArray arrayWithObjects:@"PVR.GetChannels", @"method", nil],
                              nil];
    menu_Movie.subItem.noConvertTime = YES;

    menu_Movie.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                  
                                  [NSArray array],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"label", @"method",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableArray arrayWithObjects:NSLocalizedString(@"Title", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Rating", nil), NSLocalizedString(@"Duration", nil), NSLocalizedString(@"Date added", nil), NSLocalizedString(@"Play count", nil), nil], @"label",
                                      [NSArray arrayWithObjects:@"label", @"year", @"rating", @"runtime", @"dateadded", @"playcount", nil], @"method",
                                      nil], @"available_methods",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"trailer", @"file", @"dateadded", nil], @"properties",
                                    nil], @"parameters", @"Movies", @"label", @"Movie", @"wikitype", @"nocover_movies", @"defaultThumb",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"studio", @"director", @"plot", @"mpaa", @"votes", @"cast", @"file", @"fanart", @"resume", @"trailer", nil], @"properties",
                                    nil], @"extra_info_parameters",
                                   @"YES", @"FrodoExtraArt",
                                   @"YES", @"enableCollectionView",
                                   @"YES", @"enableLibraryCache",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMovieHeightIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                     [NSNumber numberWithFloat:itemMovieHeightIpad], @"height", nil], @"ipad",
                                    nil], @"itemSizes",
                                   nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"year", @"method",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableArray arrayWithObjects:NSLocalizedString(@"Title", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Rating", nil), NSLocalizedString(@"Duration", nil), NSLocalizedString(@"Date added", nil), NSLocalizedString(@"Play count", nil), nil], @"label",
                                      [NSArray arrayWithObjects:@"label", @"year", @"rating", @"runtime", @"dateadded", @"playcount", nil], @"method",
                                      nil], @"available_methods",
                                     nil],@"sort",
                                    [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"trailer", @"file", @"dateadded", nil], @"properties", //, @"fanart"
                                    nil], @"parameters", @"Movies", @"label", @"Movie", @"wikitype", @"nocover_movies", @"defaultThumb",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"runtime", @"studio", @"director", @"plot", @"mpaa", @"votes", @"cast", @"file", @"fanart", @"resume", @"trailer", nil], @"properties",
                                    nil], @"extra_info_parameters",
                                   @"YES", @"FrodoExtraArt",
                                   @"YES", @"enableCollectionView",

                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMovieHeightIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthLargeIpad], @"width",
                                     [NSNumber numberWithFloat:itemMovieHeightLargeIpad], @"height", nil], @"ipad",
                                    nil], @"itemSizes",
//                                   @"YES", @"collectionViewRecentlyAdded",
//                                   [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [NSDictionary dictionaryWithObjectsAndKeys:
//                                     @"fullWidth", @"width",
//                                     [NSNumber numberWithFloat:itemMovieHeightRecentlyIphone], @"height", nil], @"iphone",
//                                    [NSDictionary dictionaryWithObjectsAndKeys:
//                                     @"fullWidth", @"width",
//                                     [NSNumber numberWithFloat:itemMovieHeightRecentlyIpad], @"height", nil], @"ipad",
//                                    nil], @"itemSizes",
                                   nil],
                                  
                                  [NSArray array],
                                  
                                  [NSArray array],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"label", @"method",
                                     nil],@"sort",
                                    filemodeVideoType, @"media",
                                    nil], @"parameters", @"Files", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"none", @"method",
                                     nil],@"sort",
                                    @"video", @"media",
                                    [NSArray arrayWithObjects:@"thumbnail", nil], @"file_properties",
                                    nil], @"parameters", @"Video Add-ons", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                                   @"YES", @"enableCollectionView",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                    nil], @"itemSizes",
                                   nil],
                                  
//                                  [NSMutableArray arrayWithObjects:
//                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                    [NSArray arrayWithObjects:@"thumbnail", @"channel", nil], @"properties",
//                                    nil], @"parameters", @"Live TV", @"label", @"icon_video.png", @"defaultThumb", @"YES", @"disableFilterParameter", filemodeRowHeight, @"rowHeight", livetvThumbWidth, @"thumbWidth",
//                                   @"YES", @"enableCollectionView",
//                                   [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
//                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
//                                    [NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
//                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
//                                    nil], @"itemSizes",
//                                   nil],
                                  nil];
    menu_Movie.subItem.mainFields=[NSArray arrayWithObjects:
                              
                              [NSDictionary dictionary],
                              
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               @"movies",@"itemid",
                               @"label", @"row1",
                               @"genre", @"row2",
                               @"year", @"row3",
                               @"runtime", @"row4",
                               @"rating",@"row5",
                               @"movieid",@"row6",
                               [NSNumber numberWithInt:1], @"playlistid",
                               @"movieid",@"row8",
                               @"movieid", @"row9",
                               @"playcount",@"row10",
                               @"trailer",@"row11",
                               @"plot",@"row12",
                               @"mpaa",@"row13",
                               @"votes",@"row14",
                               @"studio",@"row15",
                               @"cast",@"row16",
                               @"file",@"row7",
                               @"director",@"row17",
                               @"resume", @"row18",
                               @"dateadded", @"row19",
                               @"moviedetails",@"itemid_extra_info",
                               nil],
                              
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               @"movies",@"itemid",
                               @"label", @"row1",
                               @"genre", @"row2",
                               @"year", @"row3",
                               @"runtime", @"row4",
                               @"rating",@"row5",
                               @"movieid",@"row6",
                               [NSNumber numberWithInt:1], @"playlistid",
                               @"movieid",@"row8",
                               @"movieid", @"row9",
                               @"playcount",@"row10",
                               @"trailer",@"row11",
                               @"plot",@"row12",
                               @"mpaa",@"row13",
                               @"votes",@"row14",
                               @"studio",@"row15",
                               @"cast",@"row16",
                               @"file",@"row7",
                               @"director",@"row17",
                               @"resume", @"row18",
                               @"dateadded", @"row19",
                               @"moviedetails",@"itemid_extra_info",
                               nil],
                              
                              [NSDictionary dictionary],
                              
                              [NSDictionary dictionary],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"files",@"itemid",
                               @"label", @"row1",
                               @"filetype", @"row2",
                               @"filetype", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"file",@"row6",
                               [NSNumber numberWithInt:1], @"playlistid",
                               @"file",@"row8",
                               @"file", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"files",@"itemid",
                               @"label", @"row1",
                               @"filetype", @"row2",
                               @"filetype", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"file",@"row6",
                               @"plugin", @"row7",
                               [NSNumber numberWithInt:1], @"playlistid",
                               @"file",@"row8",
                               @"file", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              
//                              [NSDictionary  dictionaryWithObjectsAndKeys:
//                               @"channels",@"itemid",
//                               @"channel", @"row1",
//                               @"starttime", @"row2",
//                               @"endtime", @"row3",
//                               @"filetype", @"row4",
//                               @"filetype",@"row5",
//                               @"channelid",@"row6",
//                               [NSNumber numberWithInt:1], @"playlistid",
//                               @"channelid",@"row8",
//                               @"channelid", @"row9",
//                               @"filetype", @"row10",
//                               @"type", @"row11",
//                               nil],
                              
                              nil];
    
    menu_Movie.subItem.enableSection = NO;
    menu_Movie.subItem.rowHeight = 76;
    menu_Movie.subItem.thumbWidth = 53;
    menu_Movie.subItem.defaultThumb = @"nocover_movies";
    menu_Movie.subItem.sheetActions = [NSArray arrayWithObjects:
                                  [NSArray array],
                                  [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Movie Details", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                                  [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Movie Details", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                                  [NSArray array],
                                  [NSArray array],
                                  [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                                  [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
//                                  [NSArray arrayWithObjects:NSLocalizedString(@"Play", nil), nil],
                                  
                                  nil];
    menu_Movie.subItem.showInfo = [NSArray arrayWithObjects:
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:NO],
//                              [NSNumber numberWithBool:NO],
                              nil];
    menu_Movie.subItem.watchModes = [NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray array], @"modes",
                                 [NSArray array], @"icons",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                                 [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                                 [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray array], @"modes",
                                 [NSArray array], @"icons",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray array], @"modes",
                                 [NSArray array], @"icons",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray array], @"modes",
                                 [NSArray array], @"icons",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray array], @"modes",
                                 [NSArray array], @"icons",
                                 nil],
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                 [NSArray array], @"modes",
//                                 [NSArray array], @"icons",
//                                 nil],
                                nil];

    menu_Movie.subItem.widthLabel = 252;
    
    menu_Movie.subItem.subItem.noConvertTime = YES;
    menu_Movie.subItem.subItem.mainMethod = [NSMutableArray arrayWithObjects:
                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                        [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
//                                        [NSArray array],
                                        nil];
    menu_Movie.subItem.subItem.mainParameters = [NSMutableArray arrayWithObjects:
                                            [NSArray array],
                                            [NSArray array],
                                            [NSArray array],
                                            [NSArray array],
                                            [NSArray array],
                                            [NSArray array],
                                            [NSMutableArray arrayWithObjects:filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
//                                            [NSArray array],
                                            nil];
    menu_Movie.subItem.subItem.mainFields = [NSArray arrayWithObjects:
                                        [NSDictionary dictionary],
                                        [NSDictionary dictionary],
                                        [NSDictionary dictionary],
                                        [NSDictionary dictionary],
                                        [NSDictionary dictionary],
                                        [NSDictionary dictionary],
                                        [NSDictionary dictionary],
//                                        [NSDictionary dictionary],
                                        
                                        nil];
    menu_Movie.subItem.subItem.enableSection = NO;
    menu_Movie.subItem.subItem.rowHeight = 76;
    menu_Movie.subItem.subItem.thumbWidth = 53;
    menu_Movie.subItem.subItem.defaultThumb = @"nocover_filemode";
    menu_Movie.subItem.subItem.sheetActions = [NSArray arrayWithObjects:
                                          [NSArray array],
                                          [NSArray array],
                                          [NSArray array],
                                          [NSArray array],
                                          [NSArray array],
                                          [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
//                                          [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                          nil];
    menu_Movie.subItem.subItem.widthLabel = 252;
    
#pragma mark - TV Shows
    menu_TVShows.mainLabel = NSLocalizedString(@"TV Shows", nil);
    menu_TVShows.upperLabel = NSLocalizedString(@"Watch your", nil);
    menu_TVShows.icon = @"icon_home_tv_alt";
    menu_TVShows.family = 1;
    menu_TVShows.enableSection = YES;
    menu_TVShows.mainButtons = [NSArray arrayWithObjects:@"st_tv", @"st_tv_recently", @"st_filemode", @"st_addons", nil];//@"st_movie_genre",
    menu_TVShows.mainMethod = [NSMutableArray arrayWithObjects:
                        [NSArray arrayWithObjects:
                         @"VideoLibrary.GetTVShows", @"method",
                         @"VideoLibrary.GetTVShowDetails", @"extra_info_method",
                         @"YES", @"tvshowsView",
                         nil],
                        
//                        [NSArray arrayWithObjects:@"VideoLibrary.GetGenres", @"method", nil],
                        
                        [NSArray arrayWithObjects:
                         @"VideoLibrary.GetRecentlyAddedEpisodes", @"method",
                         @"VideoLibrary.GetEpisodeDetails", @"extra_info_method",
                         nil],
                        
                        [NSArray arrayWithObjects:@"Files.GetSources", @"method", nil],
                        
                        [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                        
                        nil];
    menu_TVShows.mainParameters = [NSMutableArray arrayWithObjects:
                            [NSMutableArray arrayWithObjects:
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               @"ascending",@"order",
                               [NSNumber numberWithBool:FALSE],@"ignorearticle",
                               @"label", @"method",
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSMutableArray arrayWithObjects:NSLocalizedString(@"Title", nil), NSLocalizedString(@"Year", nil), NSLocalizedString(@"Rating", nil), nil], @"label",
                                [NSArray arrayWithObjects:@"label", @"year", @"rating", nil], @"method",
                                nil], @"available_methods",

                               nil],@"sort",
                              [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"studio", nil], @"properties",
                              nil], @"parameters", NSLocalizedString(@"TV Shows", nil), @"label", @"TV Show", @"wikitype",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"studio", @"plot", @"mpaa", @"votes", @"cast", @"premiered", @"episode", @"fanart", nil], @"properties",
                              nil], @"extra_info_parameters",
                             @"YES", @"blackTableSeparator",
                             @"YES", @"FrodoExtraArt",
                             @"YES", @"enableLibraryCache",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              @"0", @"separatorInset",
                              nil], @"itemSizes",

                            nil],
                            
                            [NSMutableArray arrayWithObjects:
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               @"ascending",@"order",
                               [NSNumber numberWithBool:FALSE],@"ignorearticle",
                               @"none", @"method",
                               nil],@"sort",
                              [NSArray arrayWithObjects:@"episode", @"thumbnail", @"firstaired", @"playcount", @"showtitle", @"file", nil], @"properties",
                              nil], @"parameters", NSLocalizedString(@"Added Episodes", nil), @"label", @"53", @"rowHeight", @"95", @"thumbWidth", @"nocover_tvshows_episode", @"defaultThumb",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSArray arrayWithObjects:@"episode", @"thumbnail", @"firstaired", @"runtime", @"plot", @"director", @"writer", @"rating", @"showtitle", @"season", @"cast", @"file", @"fanart", @"playcount", @"resume", nil], @"properties",
                              nil], @"extra_info_parameters",
                             @"YES", @"FrodoExtraArt",
//                             @"YES", @"enableCollectionView",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:itemMusicWidthIphone * 1.4999999f], @"width",
                               [NSNumber numberWithFloat:(itemMusicWidthIphone * 1.4999999f) * 0.5625f], @"height", nil], @"iphone",
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:itemMusicWidthIpad * 1.4999999f], @"width",
                               [NSNumber numberWithFloat:(itemMusicWidthIpad * 1.4999999f) * 0.5625f], @"height",
                               [NSNumber numberWithFloat:fullscreenItemMusicWidthIpad * 1.4999999f], @"fullscreenWidth",
                               [NSNumber numberWithFloat:(fullscreenItemMusicWidthIpad * 1.4999999f) * 0.5625f], @"fullscreenHeight", nil], @"ipad",
                                @"95", @"separatorInset",
                              nil], @"itemSizes",
                             
                             nil],
                            
                            [NSMutableArray arrayWithObjects:
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               @"ascending",@"order",
                               [NSNumber numberWithBool:FALSE],@"ignorearticle",
                               @"label", @"method",
                               nil],@"sort",
                              @"video", @"media",
                              nil], @"parameters", NSLocalizedString(@"Files", nil), @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              @"53", @"separatorInset",
                              nil], @"itemSizes",
                             nil],
                            
                            [NSMutableArray arrayWithObjects:
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               @"ascending",@"order",
                               [NSNumber numberWithBool:FALSE],@"ignorearticle",
                               @"label", @"method",
                               nil],@"sort",
                              @"video", @"media",
                              @"addons://sources/video", @"directory",
                              [NSArray arrayWithObjects:@"thumbnail", nil], @"properties",
                              nil], @"parameters", NSLocalizedString(@"Video Add-ons", nil), @"label", NSLocalizedString(@"Video Add-ons", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                             @"YES", @"enableCollectionView",
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                               [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                               [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                              filemodeThumbWidth, @"separatorInset",
                              nil], @"itemSizes",
                             nil],
                            
                            nil];

    menu_TVShows.mainFields = [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         @"tvshows",@"itemid",
                         @"label", @"row1",
                         @"genre", @"row2",
                         @"year", @"row3",
                         @"studio", @"row4",
                         @"rating",@"row5",
                         @"tvshowid",@"row6",
                         [NSNumber numberWithInt:1], @"playlistid",
                         @"tvshowid",@"row8",
                         @"playcount",@"row9",
                         @"mpaa",@"row10",
                         @"votes",@"row11",
                         @"cast",@"row12",
                         @"premiered",@"row13",
                         @"episode",@"row14",
//                         @"fanart",@"row7",
                         @"plot",@"row15",
                         @"studio",@"row16",
                         @"tvshowdetails",@"itemid_extra_info",
                         nil],
                        
//                        [NSDictionary dictionaryWithObjectsAndKeys:
//                         @"genres",@"itemid",
//                         @"label", @"row1",
//                         @"label", @"row2",
//                         @"disable", @"row3",
//                         @"disable", @"row4",
//                         @"disable",@"row5",
//                         @"genre",@"row6",
//                         [NSNumber numberWithInt:1], @"playlistid",
//                         @"genreid",@"row8",
//                         nil],
                        
                        [NSDictionary  dictionaryWithObjectsAndKeys:
                         @"episodes",@"itemid",
                         @"label", @"row1",
                         @"showtitle", @"row2",
                         @"firstaired", @"row3",
                         @"runtime", @"row4",
                         @"rating",@"row5",
                         @"episodeid",@"row6",
                         @"playcount",@"row7",
                         @"episodeid",@"row8",
                         [NSNumber numberWithInt:1], @"playlistid",
                         @"episodeid", @"row9",
                         @"file", @"row10",
                         @"director", @"row11",
                         @"writer", @"row12",
                         @"resume", @"row13",
                         @"showtitle", @"row14",
                         @"plot",@"row15",
                         @"cast",@"row16",
                         @"firstaired",@"row17",
                         @"season",@"row18",
//                         @"file",@"row20",
//                         @"file",@"row7",
                         @"episodedetails",@"itemid_extra_info",
                         nil],
                        
                        [NSDictionary  dictionaryWithObjectsAndKeys:
                         @"sources",@"itemid",
                         @"label", @"row1",
                         @"year", @"row2",
                         @"year", @"row3",
                         @"runtime", @"row4",
                         @"rating",@"row5",
                         @"file",@"row6",
                         [NSNumber numberWithInt:1], @"playlistid",
                         @"file",@"row8",
                         @"file", @"row9",
                         nil],
                        
                        [NSDictionary  dictionaryWithObjectsAndKeys:
                         @"files",@"itemid",
                         @"label", @"row1",
                         @"year", @"row2",
                         @"year", @"row3",
                         @"runtime", @"row4",
                         @"rating",@"row5",
                         @"file",@"row6",
                         [NSNumber numberWithInt:1], @"playlistid",
                         @"file",@"row8",
                         @"file", @"row9",
                         nil],
                        nil];
    
    menu_TVShows.rowHeight = tvshowHeight;
    menu_TVShows.thumbWidth = thumbWidth;
    menu_TVShows.defaultThumb = @"nocover_tvshows.png";
    menu_TVShows.originLabel = 60;
    menu_TVShows.sheetActions = [NSArray arrayWithObjects:
                          [NSMutableArray arrayWithObjects:NSLocalizedString(@"TV Show Details", nil), nil],
//                          [NSArray array],
                          [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Episode Details", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                          [NSArray array],
                          [NSArray array],
                          nil];
    
    menu_TVShows.showInfo = [NSArray arrayWithObjects:
                      [NSNumber numberWithBool:NO],
//                      [NSNumber numberWithBool:NO],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:NO],
                      [NSNumber numberWithBool:NO],
                      nil];
    
    menu_TVShows.watchModes = [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                         nil],
//                        [NSDictionary dictionaryWithObjectsAndKeys:
//                         [NSArray array], @"modes",
//                         [NSArray array], @"icons",
//                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        nil];
    
    menu_TVShows.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                              [NSArray arrayWithObjects:
                               @"VideoLibrary.GetEpisodes", @"method",
                               @"VideoLibrary.GetEpisodeDetails", @"extra_info_method",
                               @"YES", @"episodesView",
                               @"VideoLibrary.GetSeasons", @"extra_section_method",
                               nil],
//                              [NSArray arrayWithObjects:
//                               @"VideoLibrary.GetTVShows", @"method",
//                               @"VideoLibrary.GetTVShowDetails", @"extra_info_method",
//                               nil],
                              [NSArray array],
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                              nil];
    
    menu_TVShows.subItem.mainParameters = [NSMutableArray arrayWithObjects:
                                    [NSMutableArray arrayWithObjects:
                                     [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"ascending",@"order",
                                       @"episode", @"method",
                                       nil],@"sort",
                                      [NSArray arrayWithObjects:@"episode", @"thumbnail", @"firstaired", @"showtitle", @"playcount", @"season", @"tvshowid", @"runtime", @"file", nil], @"properties",
                                      nil], @"parameters", @"Episodes", @"label", @"YES", @"disableFilterParameter",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSArray arrayWithObjects:@"episode", @"thumbnail", @"firstaired", @"runtime", @"plot", @"director", @"writer", @"rating", @"showtitle", @"season", @"cast", @"fanart", @"resume", @"playcount", @"file", nil], @"properties",nil], @"extra_info_parameters",
                                     [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"ascending",@"order",
                                       [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                       @"label", @"method",
                                       nil],@"sort",
                                      [NSArray arrayWithObjects:@"season", @"thumbnail", @"tvshowid", @"playcount", @"episode", nil], @"properties",
                                      nil], @"extra_section_parameters",
                                     @"YES", @"FrodoExtraArt",
                                     nil],
                                    
//                                    [NSMutableArray arrayWithObjects:
//                                     [NSDictionary dictionaryWithObjectsAndKeys:
//                                      [NSDictionary dictionaryWithObjectsAndKeys:
//                                       @"ascending",@"order",
//                                       [NSNumber numberWithBool:FALSE],@"ignorearticle",
//                                       @"label", @"method",
//                                       nil],@"sort",
//                                      [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"studio", nil], @"properties",
//                                      nil], @"parameters",
//                                     @"TV Shows", @"label", @"TV Show", @"wikitype", [NSNumber numberWithInt:tvshowHeight], @"rowHeight", [NSNumber numberWithInt:thumbWidth], @"thumbWidth",
//                                     [NSDictionary dictionaryWithObjectsAndKeys:
//                                      [NSArray arrayWithObjects:@"year", @"playcount", @"rating", @"thumbnail", @"genre", @"studio", @"plot", @"mpaa", @"votes", @"cast", @"premiered", @"episode", @"fanart", nil], @"properties",
//                                      nil], @"extra_info_parameters",
//                                     @"YES", @"blackTableSeparator",
//                                     @"YES", @"FrodoExtraArt",
//                                     nil],
                                    
                                    [NSArray array],
                                    
                                    [NSMutableArray arrayWithObjects:
                                     [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"ascending",@"order",
                                       [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                       @"label", @"method",
                                       nil],@"sort",
                                      filemodeVideoType, @"media",
                                      nil], @"parameters", @"Files", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                                    
                                    [NSMutableArray arrayWithObjects:
                                     [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"ascending",@"order",
                                       [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                       @"none", @"method",
                                       nil],@"sort",
                                      @"video", @"media",
                                      [NSArray arrayWithObjects:@"thumbnail", nil], @"file_properties",
                                      nil], @"parameters", @"Video Add-ons", @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                                     @"YES", @"enableCollectionView",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                       [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                       [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                      nil], @"itemSizes",
                                     nil],
                                                                       
                                    nil];
    menu_TVShows.subItem.mainFields = [NSArray arrayWithObjects:
                                [NSDictionary  dictionaryWithObjectsAndKeys:
                                 @"episodes",@"itemid",
                                 @"label", @"row1",
                                 @"showtitle", @"row2",
                                 @"firstaired", @"row3",
                                 @"runtime", @"row4",
                                 @"rating",@"row5",
                                 @"episodeid",@"row6",
                                 @"playcount",@"row7",
                                 @"episodeid",@"row8",
                                 [NSNumber numberWithInt:1], @"playlistid",
                                 @"episodeid", @"row9",
                                 @"season", @"row10",
                                 @"tvshowid", @"row11",
                                 @"file", @"row12",
                                 @"writer", @"row13",
                                 @"firstaired", @"row14",
                                 @"showtitle",@"row15",
                                 @"cast",@"row16",
                                 @"director",@"row17",
                                 @"resume",@"row18",
                                 @"episode",@"row19",
                                 @"plot",@"row20",
                                 @"episodedetails",@"itemid_extra_info",
                                 @"seasons",@"itemid_extra_section",
                                 nil],
                                
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                 @"tvshows",@"itemid",
//                                 @"label", @"row1",
//                                 @"genre", @"row2",
//                                 @"blank", @"row3",
//                                 @"studio", @"row4",
//                                 @"rating",@"row5",
//                                 @"tvshowid",@"row6",
//                                 [NSNumber numberWithInt:1], @"playlistid",
//                                 @"tvshowid",@"row8",
//                                 @"playcount",@"row9",
//                                 @"mpaa",@"row10",
//                                 @"votes",@"row11",
//                                 @"cast",@"row12",
//                                 @"premiered",@"row13",
//                                 @"episode",@"row14",
//                                 @"fanart",@"row7",
//                                 @"plot",@"row15",
//                                 @"studio",@"row16",
//                                 @"tvshowdetails",@"itemid_extra_info",
//                                 nil],
                                
                                [NSArray array],
                                
                                [NSDictionary  dictionaryWithObjectsAndKeys:
                                 @"files",@"itemid",
                                 @"label", @"row1",
                                 @"filetype", @"row2",
                                 @"filetype", @"row3",
                                 @"filetype", @"row4",
                                 @"filetype",@"row5",
                                 @"file",@"row6",
                                 [NSNumber numberWithInt:1], @"playlistid",
                                 @"file",@"row8",
                                 @"file", @"row9",
                                 @"filetype", @"row10",
                                 @"type", @"row11",
                                 nil],
                                
                                [NSDictionary  dictionaryWithObjectsAndKeys:
                                 @"files",@"itemid",
                                 @"label", @"row1",
                                 @"filetype", @"row2",
                                 @"filetype", @"row3",
                                 @"filetype", @"row4",
                                 @"filetype",@"row5",
                                 @"file",@"row6",
                                 @"plugin", @"row7",
                                 [NSNumber numberWithInt:1], @"playlistid",
                                 @"file",@"row8",
                                 @"file", @"row9",
                                 @"filetype", @"row10",
                                 @"type", @"row11",
                                 nil],
                                
                                nil];
    menu_TVShows.subItem.enableSection = NO;
    menu_TVShows.subItem.rowHeight = 53;
    menu_TVShows.subItem.thumbWidth = 95;
    menu_TVShows.subItem.defaultThumb = @"nocover_tvshows_episode.png";
    menu_TVShows.subItem.sheetActions = [NSArray arrayWithObjects:
                                  [NSMutableArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Episode Details", nil),  nil], //, NSLocalizedString(@"Open with VLC", nil)
//                                  [NSArray arrayWithObjects:@"TV Show Details", nil],
                                  [NSArray array],
                                  [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil], //, NSLocalizedString(@"Open with VLC", nil)
                                  [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                  nil];//, @"Stream to iPhone"
    menu_TVShows.subItem.originYearDuration=248;
    menu_TVShows.subItem.widthLabel=208;
    menu_TVShows.subItem.showRuntime=[NSArray arrayWithObjects:
                               [NSNumber numberWithBool:NO],
//                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:NO],
                               nil];
    menu_TVShows.subItem.noConvertTime=YES;
    menu_TVShows.subItem.showInfo = [NSArray arrayWithObjects:
                              [NSNumber numberWithBool:YES],
//                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:YES],
                              nil];
    
    menu_TVShows.subItem.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                                      [NSArray array],
//                                      [NSArray array],
                                      [NSArray array],
                                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                      nil];
    menu_TVShows.subItem.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                          [NSArray array],
                                          
//                                          [NSArray array],

                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          [NSMutableArray arrayWithObjects:filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                                          
                                          nil];
    menu_TVShows.subItem.subItem.mainFields=[NSArray arrayWithObjects:
                                      [NSArray array],
                                      
//                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      nil];
    menu_TVShows.subItem.subItem.enableSection=NO;
    menu_TVShows.subItem.subItem.rowHeight=53;
    menu_TVShows.subItem.subItem.thumbWidth=95;
    menu_TVShows.subItem.subItem.defaultThumb=@"nocover_tvshows_episode.png";
    menu_TVShows.subItem.subItem.sheetActions=[NSArray arrayWithObjects:
                                        [NSArray array],
//                                        [NSArray array],
                                        [NSArray array],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                                        nil];
    menu_TVShows.subItem.subItem.originYearDuration=248;
    menu_TVShows.subItem.subItem.widthLabel=208;
    menu_TVShows.subItem.subItem.showRuntime=[NSArray arrayWithObjects:
                                       [NSNumber numberWithBool:NO],
//                                       [NSNumber numberWithBool:NO],
                                       [NSNumber numberWithBool:NO],
                                       [NSNumber numberWithBool:NO],
                                       [NSNumber numberWithBool:NO],
                                       nil];
    menu_TVShows.subItem.subItem.noConvertTime=YES;
    menu_TVShows.subItem.subItem.showInfo = [NSArray arrayWithObjects:
                                      [NSNumber numberWithBool:YES],
//                                      [NSNumber numberWithBool:YES],
                                      [NSNumber numberWithBool:YES],
                                      [NSNumber numberWithBool:YES],
                                      [NSNumber numberWithBool:YES],
                                      nil];

#pragma mark - Live TV
    menu_LiveTV.mainLabel = NSLocalizedString(@"Live TV", nil);
    menu_LiveTV.upperLabel = NSLocalizedString(@"Watch", nil);
    menu_LiveTV.icon = @"icon_home_livetv_alt";
    menu_LiveTV.family = 1;
    menu_LiveTV.enableSection=YES;
    menu_LiveTV.noConvertTime = YES;
    menu_LiveTV.mainButtons=[NSArray arrayWithObjects:@"st_livetv", @"st_radio", @"st_recordings", @"st_timers", nil];
    menu_LiveTV.mainMethod=[NSMutableArray arrayWithObjects:
                      [NSArray arrayWithObjects:@"PVR.GetChannelGroups", @"method", nil],
                      [NSArray arrayWithObjects:@"PVR.GetChannelGroups", @"method", nil],
                      [NSArray arrayWithObjects:
                       @"PVR.GetRecordings", @"method",
                       @"PVR.GetRecordingDetails", @"extra_info_method",
                       nil],
                      [NSArray arrayWithObjects:
                       @"PVR.GetTimers", @"method",
                       @"PVR.GetTimerDetails", @"extra_info_method",
                       nil],
                    nil];
    
    menu_LiveTV.mainParameters=[NSMutableArray arrayWithObjects:
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"tv", @"channeltype",
                            nil], @"parameters", NSLocalizedString(@"Live TV", nil), @"label", NSLocalizedString(@"Live TV", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"enableCollectionView",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"radio", @"channeltype",
                            nil], @"parameters", NSLocalizedString(@"Radio", nil), @"label", NSLocalizedString(@"Radio", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"enableCollectionView",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],

                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [[NSArray alloc] initWithObjects:@"title", @"starttime", @"endtime", @"plot", @"plotoutline", @"genre", @"playcount",@"resume", @"channel",  @"runtime",@"lifetime", @"icon", @"art", @"streamurl", @"file", @"directory", nil], @"properties",
                            nil], @"parameters",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSArray alloc] initWithObjects:@"title", @"starttime", @"endtime", @"plot", @"plotoutline", @"genre", @"playcount",@"resume", @"channel",  @"runtime",@"lifetime", @"icon", @"art", @"streamurl", @"file", @"directory", nil], @"properties",
                            nil], @"extra_info_parameters",
                           NSLocalizedString(@"Recordings", nil), @"label", NSLocalizedString(@"Recordings", nil), @"morelabel", @"nocover_channels", @"defaultThumb", channelEPGRowHeight, @"rowHeight", @"53", @"thumbWidth",
                           @"YES", @"enableCollectionView",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                            @"60", @"separatorInset",
                            nil], @"itemSizes",
                           nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [[NSArray alloc] initWithObjects:@"title", @"summary", @"channelid", @"isradio", @"starttime", @"endtime", @"runtime", @"lifetime", @"firstday",@"weekdays", @"priority", @"startmargin", @"endmargin", @"state", @"file", @"directory", nil], @"properties",
                            nil], @"parameters",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSArray alloc] initWithObjects:@"title", @"summary", @"starttime", @"endtime", @"runtime", @"lifetime", @"firstday", @"weekdays", @"priority", @"startmargin", @"endmargin", @"state", @"file", @"directory", nil], @"properties",
                            nil], @"extra_info_parameters",
                           NSLocalizedString(@"Timers", nil), @"label", NSLocalizedString(@"Timers", nil), @"morelabel", @"nocover_timers", @"defaultThumb", @"53", @"rowHeight", @"53", @"thumbWidth",
                           @"YES", @"enableCollectionView",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                            @"60", @"separatorInset",
                            nil], @"itemSizes",
                           nil],
                          
                        
                        nil];
    
    menu_LiveTV.mainFields=[NSArray arrayWithObjects:
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"channelgroups",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"channelgroupid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"channelgroupid",@"row8",
                       @"channelgroupid", @"row9",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"channelgroups",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"channelgroupid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"channelgroupid",@"row8",
                       @"channelgroupid", @"row9",
                       nil],

                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"recordings",@"itemid",
                       @"label", @"row1",
                       @"title", @"row2",
                       @"plot", @"row3",
                       @"runtime", @"row4",
                       @"starttime",@"row5",
                       @"recordingid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"recordingid",@"row8",
                       @"recordingid", @"row9",
                       @"file", @"row10",
                       @"channel", @"row11",
                       @"starttime", @"row12",
                       @"endtime", @"row13",
                       @"playcount", @"row14",
                       @"plot", @"row15",
                       @"recordingdetails",@"itemid_extra_info",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"timers",@"itemid",
                       @"label", @"row1",
                       @"summary", @"row2",
                       @"plot", @"row3",
                       @"plotoutline", @"row4",
                       @"starttime",@"row5",
                       @"timerid",@"row6",
                       [NSNumber numberWithInt:1], @"playlistid",
                       @"timerid",@"row8",
                       @"timerid", @"row9",
                       @"starttime", @"row10",
                       @"endtime", @"row11",
                       @"timerdetails",@"itemid_extra_info",
                       nil],
                      
                      nil];
    menu_LiveTV.rowHeight=76;
    menu_LiveTV.thumbWidth=53;
    menu_LiveTV.defaultThumb=@"nocover_movies";
    menu_LiveTV.sheetActions=[NSArray arrayWithObjects:
                        [NSArray array],
                        [NSArray array],
                        [NSArray arrayWithObjects:NSLocalizedString(@"Queue after current", nil), NSLocalizedString(@"Queue", nil), NSLocalizedString(@"Play", nil), nil],
                        [NSArray arrayWithObjects: NSLocalizedString(@"Delete timer", nil), nil],
                        nil];
    //    menu_LiveTV.showInfo = YES;
    menu_LiveTV.showInfo = [NSArray arrayWithObjects:
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:YES],
                      [NSNumber numberWithBool:NO],
                      nil];
    menu_LiveTV.watchModes = [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray arrayWithObjects:@"all", @"unwatched", @"watched", nil], @"modes",
                         [NSArray arrayWithObjects:@"", @"icon_not_watched", @"icon_watched", nil], @"icons",
                         nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSArray array], @"modes",
                         [NSArray array], @"icons",
                         nil],
                        
                        nil];
    
    menu_LiveTV.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                              [NSArray arrayWithObjects:@"PVR.GetChannels", @"method", @"YES", @"channelListView", nil],
                              [NSArray arrayWithObjects:@"PVR.GetChannels", @"method", @"YES", @"channelListView", nil],
                              [NSArray array],
                              [NSArray array],
                              nil];
    menu_LiveTV.subItem.noConvertTime = YES;
    
    menu_LiveTV.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects:@"thumbnail", @"channel", nil], @"properties",
                                    nil], @"parameters", @"Live TV", @"label", @"nocover_channels", @"defaultThumb", @"YES", @"disableFilterParameter", livetvRowHeight, @"rowHeight", @"48", @"thumbWidth",
                                   @"YES", @"enableCollectionView",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects: @"isrecording", nil], @"17",
                                    nil], @"kodiExtrasPropertiesMinimumVersion",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                    @"56", @"separatorInset",
                                    nil], @"itemSizes",
                                   nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects:@"thumbnail", @"channel", nil], @"properties",
                                    nil], @"parameters", @"Live TV", @"label", @"nocover_channels", @"defaultThumb", @"YES", @"disableFilterParameter", livetvRowHeight, @"rowHeight", @"48", @"thumbWidth",
                                   @"YES", @"enableCollectionView",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects: @"isrecording", nil], @"17",
                                    nil], @"kodiExtrasPropertiesMinimumVersion",
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                     [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                    @"56", @"separatorInset",
                                    nil], @"itemSizes",
                                   nil],
                                  
                                  [NSArray array],
                                  
                                  [NSArray array],
                                nil];
    menu_LiveTV.subItem.mainFields=[NSArray arrayWithObjects:
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"channels",@"itemid",
                               @"channel", @"row1",
                               @"starttime", @"row2",
                               @"endtime", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"channelid",@"row6",
                               [NSNumber numberWithInt:1], @"playlistid",
                               @"channelid",@"row8",
                               @"isrecording", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"channels",@"itemid",
                               @"channel", @"row1",
                               @"starttime", @"row2",
                               @"endtime", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"channelid",@"row6",
                               [NSNumber numberWithInt:1], @"playlistid",
                               @"channelid",@"row8",
                               @"channelid", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              [NSDictionary dictionary],
                              [NSDictionary dictionary],
                              nil];
    
    menu_LiveTV.subItem.enableSection = NO;
    menu_LiveTV.subItem.rowHeight = 76;
    menu_LiveTV.subItem.thumbWidth = [livetvThumbWidth intValue];
    menu_LiveTV.subItem.defaultThumb = @"nocover_channels";
    menu_LiveTV.subItem.sheetActions = [NSArray arrayWithObjects:
                                  [NSArray arrayWithObjects:
                                   NSLocalizedString(@"Play", nil),
                                   NSLocalizedString(@"Record", nil),
                                   NSLocalizedString(@"Channel Guide", nil), nil],
                                   [NSArray arrayWithObjects:
                                    NSLocalizedString(@"Play", nil),
                                    NSLocalizedString(@"Record", nil),
                                    NSLocalizedString(@"Channel Guide", nil), nil],
                                  [NSArray array],
                                  [NSArray array],
                                  nil];
    menu_LiveTV.subItem.showInfo = [NSArray arrayWithObjects:
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:NO],
                              nil];
    menu_LiveTV.subItem.watchModes = [NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray array], @"modes",
                                 [NSArray array], @"icons",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArray array], @"modes",
                                 [NSArray array], @"icons",
                                 nil],
                                [NSDictionary dictionary],
                                [NSDictionary dictionary],
                                nil];
    
    menu_LiveTV.subItem.widthLabel = 252;
    menu_LiveTV.subItem.subItem.noConvertTime = YES;
    menu_LiveTV.subItem.subItem.mainMethod = [NSMutableArray arrayWithObjects:
                                        [NSArray arrayWithObjects:@"PVR.GetBroadcasts", @"method", @"YES", @"channelGuideView", nil],
                                        [NSArray arrayWithObjects:@"PVR.GetBroadcasts", @"method", @"YES", @"channelGuideView", nil],
                                        [NSArray array],
                                        [NSArray array],
                                        nil];
    menu_LiveTV.subItem.subItem.mainParameters = [NSMutableArray arrayWithObjects:
                                            [NSMutableArray arrayWithObjects:
                                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [[NSArray alloc] initWithObjects:@"title", @"starttime", @"endtime", @"plot", @"plotoutline", @"progresspercentage", @"isactive", @"hastimer", nil], @"properties",
                                              nil], @"parameters", @"Live TV", @"label", @"icon_video.png", @"defaultThumb", @"YES", @"disableFilterParameter", channelEPGRowHeight, @"rowHeight", livetvThumbWidth, @"thumbWidth",
                                             [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                               [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                               [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                              @"48", @"separatorInset",
                                              nil], @"itemSizes",
                                             [NSNumber numberWithBool:YES], @"forceActionSheet",
                                             nil],
                                            [NSMutableArray arrayWithObjects:
                                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [[NSArray alloc] initWithObjects:@"title", @"starttime", @"endtime", @"plot", @"plotoutline", @"progresspercentage", @"isactive", @"hastimer", nil], @"properties",
                                              nil], @"parameters", @"Live TV", @"label", @"icon_video.png", @"defaultThumb", @"YES", @"disableFilterParameter", channelEPGRowHeight, @"rowHeight", livetvThumbWidth, @"thumbWidth",
                                             [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                                               [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                                               [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                                              @"48", @"separatorInset",
                                              nil], @"itemSizes",
                                             [NSNumber numberWithBool:YES], @"forceActionSheet",
                                             nil],
                                            [NSArray array],
                                            [NSArray array],
                                            nil];
    menu_LiveTV.subItem.subItem.mainFields = [NSArray arrayWithObjects:
                                        [NSDictionary  dictionaryWithObjectsAndKeys:
                                         @"broadcasts",@"itemid",
                                         @"title", @"row1",
                                         @"plot", @"row2",
                                         @"broadcastid", @"row3",
                                         @"broadcastid", @"row4",
                                         @"starttime",@"row5",
                                         @"broadcastid",@"row6",
                                         [NSNumber numberWithInt:1], @"playlistid",
                                         @"broadcastid",@"row8",
                                         @"plotoutline", @"row9",
                                         @"starttime", @"row10",
                                         @"endtime", @"row11",
                                         @"progresspercentage", @"row12",
                                         @"isactive", @"row13",
                                         @"title", @"row14",
                                         @"hastimer", @"row15",
                                         nil],
                                        [NSDictionary  dictionaryWithObjectsAndKeys:
                                         @"broadcasts",@"itemid",
                                         @"title", @"row1",
                                         @"plot", @"row2",
                                         @"broadcastid", @"row3",
                                         @"broadcastid", @"row4",
                                         @"starttime",@"row5",
                                         @"broadcastid",@"row6",
                                         [NSNumber numberWithInt:1], @"playlistid",
                                         @"broadcastid",@"row8",
                                         @"plotoutline", @"row9",
                                         @"starttime", @"row10",
                                         @"endtime", @"row11",
                                         @"progresspercentage", @"row12",
                                         @"isactive", @"row13",
                                         @"title", @"row14",
                                         @"hastimer", @"row15",
                                         nil],
                                        [NSArray array],
                                        [NSArray array],
                                        nil];
    menu_LiveTV.subItem.subItem.enableSection = NO;
    menu_LiveTV.subItem.subItem.rowHeight = 76;
    menu_LiveTV.subItem.subItem.thumbWidth = 53;
    menu_LiveTV.subItem.subItem.defaultThumb = @"nocover_filemode";
    menu_LiveTV.subItem.subItem.sheetActions = [NSArray arrayWithObjects:
                                          [NSArray arrayWithObjects:
                                           NSLocalizedString(@"Play", nil),
                                           NSLocalizedString(@"Record", nil),
                                           NSLocalizedString(@"Broadcast Details", nil), nil],
                                          [NSArray arrayWithObjects:
                                           NSLocalizedString(@"Play", nil),
                                           NSLocalizedString(@"Record", nil),
                                           NSLocalizedString(@"Broadcast Details", nil), nil],
                                          [NSArray array],
                                          [NSArray array],
                                        nil];
    menu_LiveTV.subItem.subItem.widthLabel = 252;
    menu_LiveTV.subItem.subItem.showInfo = [NSArray arrayWithObjects:
                                      [NSNumber numberWithBool:YES],
                                      [NSNumber numberWithBool:YES],
                                      [NSNumber numberWithBool:YES],
                                      [NSNumber numberWithBool:YES],
                                      nil];

#pragma mark - Pictures
    menu_Picture.mainLabel = NSLocalizedString(@"Pictures", nil);
    menu_Picture.upperLabel = NSLocalizedString(@"Browse your", nil);
    menu_Picture.icon = @"icon_home_picture_alt";
    menu_Picture.family = 1;
    menu_Picture.enableSection=YES;
    menu_Picture.mainButtons=[NSArray arrayWithObjects:@"st_filemode", @"st_addons", nil];
    
    menu_Picture.mainMethod=[NSMutableArray arrayWithObjects:
                      
                      [NSArray arrayWithObjects:@"Files.GetSources", @"method", nil],
                      
                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                      
                      nil];
    
    menu_Picture.mainParameters=[NSMutableArray arrayWithObjects:
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            @"pictures", @"media",
                            nil], @"parameters", NSLocalizedString(@"Pictures", nil), @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                          
                          [NSMutableArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"ascending",@"order",
                             [NSNumber numberWithBool:FALSE],@"ignorearticle",
                             @"label", @"method",
                             nil],@"sort",
                            @"pictures", @"media",
                            @"addons://sources/image", @"directory",
                            [NSArray arrayWithObjects:@"thumbnail", nil], @"properties",
                            nil], @"parameters", NSLocalizedString(@"Pictures Add-ons", nil), @"label", NSLocalizedString(@"Pictures Add-ons", nil), @"morelabel", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth",
                           @"YES", @"enableCollectionView",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIphone], @"height", nil], @"iphone",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"width",
                             [NSNumber numberWithFloat:itemMovieWidthIpad], @"height", nil], @"ipad",
                            nil], @"itemSizes",
                           nil],
                          nil];
    
    menu_Picture.mainFields=[NSArray arrayWithObjects:
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"sources",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"file",@"row6",
                       [NSNumber numberWithInt:2], @"playlistid",
                       @"file",@"row8",
                       @"file", @"row9",
                       nil],
                      
                      [NSDictionary  dictionaryWithObjectsAndKeys:
                       @"files",@"itemid",
                       @"label", @"row1",
                       @"year", @"row2",
                       @"year", @"row3",
                       @"runtime", @"row4",
                       @"rating",@"row5",
                       @"file",@"row6",
                       [NSNumber numberWithInt:2], @"playlistid",
                       @"file",@"row8",
                       @"file", @"row9",
                       nil],
                      
                      nil];
    
    menu_Picture.thumbWidth=53;
    menu_Picture.defaultThumb=@"jewel_dvd.table.png";
    
    menu_Picture.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                              
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                              
                              [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                              
                              nil];
    
    menu_Picture.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"label", @"method",
                                     nil],@"sort",
                                    @"pictures", @"media",
                                    [NSArray arrayWithObjects:@"thumbnail", nil], @"file_properties",
                                    nil], @"parameters", NSLocalizedString(@"Files", nil), @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                                  
                                  [NSMutableArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"ascending",@"order",
                                     [NSNumber numberWithBool:FALSE],@"ignorearticle",
                                     @"none", @"method",
                                     nil],@"sort",
                                    @"pictures", @"media",
                                    [NSArray arrayWithObjects:@"thumbnail", nil], @"file_properties",
                                    nil], @"parameters", NSLocalizedString(@"Video Add-ons", nil), @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", filemodeThumbWidth, @"thumbWidth", nil],
                                  
                                  nil];
    menu_Picture.subItem.mainFields=[NSArray arrayWithObjects:
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"files",@"itemid",
                               @"label", @"row1",
                               @"filetype", @"row2",
                               @"filetype", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"file",@"row6",
                               [NSNumber numberWithInt:2], @"playlistid",
                               @"file",@"row8",
                               @"file", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              
                              [NSDictionary  dictionaryWithObjectsAndKeys:
                               @"files",@"itemid",
                               @"label", @"row1",
                               @"filetype", @"row2",
                               @"filetype", @"row3",
                               @"filetype", @"row4",
                               @"filetype",@"row5",
                               @"file",@"row6",
                               [NSNumber numberWithInt:2], @"playlistid",
                               @"file",@"row8",
                               @"file", @"row9",
                               @"filetype", @"row10",
                               @"type", @"row11",
                               nil],
                              
                              nil];
    
    menu_Picture.subItem.enableSection=NO;
    menu_Picture.subItem.rowHeight=76;
    menu_Picture.subItem.thumbWidth=53;
    menu_Picture.subItem.defaultThumb=@"nocover_tvshows_episode.png";
    
    
    menu_Picture.subItem.subItem.mainMethod=[NSMutableArray arrayWithObjects:
                                      
                                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                      
                                      [NSArray arrayWithObjects:@"Files.GetDirectory", @"method", nil],
                                      
                                      nil];
    
    menu_Picture.subItem.subItem.mainParameters=[NSMutableArray arrayWithObjects:
                                          
                                          [NSArray array],
                                          
                                          [NSArray array],
                                          
                                          nil];
    
    menu_Picture.subItem.subItem.mainFields=[NSArray arrayWithObjects:
                                      
                                      [NSArray array],
                                      
                                      [NSArray array],
                                      
                                      nil];
    
#pragma mark - Now Playing
    menu_NowPlaying.mainLabel = NSLocalizedString(@"Now Playing", nil);
    menu_NowPlaying.upperLabel = NSLocalizedString(@"See what's", nil);
    menu_NowPlaying.icon = @"icon_home_playing_alt";
    menu_NowPlaying.family = 2;
    
#pragma mark - Remote Control
    menu_Remote.mainLabel = NSLocalizedString(@"Remote Control", nil);
    menu_Remote.upperLabel = NSLocalizedString(@"Use as", nil);
    menu_Remote.icon = @"icon_home_remote_alt";
    menu_Remote.family = 3;
    
#pragma mark - XBMC Server Management
    menu_Server.mainLabel = NSLocalizedString(@"XBMC Server", nil);
    menu_Server.upperLabel = @"";
    menu_Server.icon = @"";
    menu_Server.family = 4;
    
#pragma mark - Playlist Artist Albums
    playlistArtistAlbums = [menu_Music copy];
    playlistArtistAlbums.subItem.disableNowPlaying = TRUE;
    playlistArtistAlbums.subItem.subItem.disableNowPlaying = TRUE;
    
#pragma mark - Plalist Movies
    playlistMovies = [menu_Movie copy];
    playlistMovies.subItem.disableNowPlaying = TRUE;
    playlistMovies.subItem.subItem.disableNowPlaying = TRUE;
    
#pragma mark - Playlist TV Shows
    playlistTvShows = [menu_TVShows copy];
    playlistTvShows.subItem.disableNowPlaying = TRUE;
    playlistTvShows.subItem.subItem.disableNowPlaying = TRUE;

#pragma mark - XBMC Settings 
    xbmcSettings = [[mainMenu alloc] init];
    xbmcSettings.subItem = [[mainMenu alloc] init];
    xbmcSettings.subItem.subItem = [[mainMenu alloc] init];
    
    xbmcSettings.mainLabel = NSLocalizedString(@"XBMC Settings", nil);
    xbmcSettings.icon = @"icon_home_picture_alt";
    xbmcSettings.family = 1;
    xbmcSettings.enableSection = YES;
    xbmcSettings.rowHeight = 65;
    xbmcSettings.thumbWidth = 44;
    xbmcSettings.disableNowPlaying = YES;
    xbmcSettings.mainButtons = [NSArray arrayWithObjects:@"st_filemode", @"st_addons", @"st_video_addon", @"st_audio_addon", @"st_kodi_action", @"st_kodi_window", nil];
    
    xbmcSettings.mainMethod = [NSMutableArray arrayWithObjects:
                               
                               [NSArray arrayWithObjects:@"Settings.GetSections", @"method", nil],
                               
                               [NSArray arrayWithObjects:@"Addons.GetAddons", @"method", nil],
                               
                               [NSArray arrayWithObjects:@"Addons.GetAddons", @"method", nil],
                               
                               [NSArray arrayWithObjects:@"Addons.GetAddons", @"method", nil],

                               [NSArray arrayWithObjects:@"JSONRPC.Introspect", @"method", nil],
                               
                               [NSArray arrayWithObjects:@"JSONRPC.Introspect", @"method", nil],
                               
                               nil];
    
    xbmcSettings.mainParameters = [NSMutableArray arrayWithObjects:
                                   
                                   [NSMutableArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"expert", @"level",
                                     nil], @"parameters", NSLocalizedString(@"XBMC Settings", nil), @"label", @"nocover_settings", @"defaultThumb",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"53", @"separatorInset",
                                     nil], @"itemSizes",
                                    animationStartX, @"animationStartX",
                                    animationStartBottomScreen, @"animationStartBottomScreen",
                                    nil],
                                   
                                   [NSMutableArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"xbmc.addon.executable", @"type",
                                     [NSNumber numberWithBool:YES], @"enabled",
                                     [[NSArray alloc] initWithObjects: @"name", @"version", @"summary", @"thumbnail", nil], @"properties",
                                     nil], @"parameters", NSLocalizedString(@"Programs", nil), @"label", @"nocover_filemode", @"defaultThumb", @"65", @"rowHeight", @"65", @"thumbWidth",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                      [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                                      [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                                     @"65", @"separatorInset",
                                     nil], @"itemSizes",
                                    @"YES", @"enableCollectionView",
                                    nil],
                                   
                                   [NSMutableArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"xbmc.addon.video", @"type",
                                     [NSNumber numberWithBool:YES], @"enabled",
                                     [[NSArray alloc] initWithObjects: @"name", @"version", @"summary", @"thumbnail", nil], @"properties",
                                     nil], @"parameters", NSLocalizedString(@"Video Add-ons", nil), @"label", @"nocover_filemode", @"defaultThumb", @"65", @"rowHeight", @"65", @"thumbWidth",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                      [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                                      [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                                     @"65", @"separatorInset",
                                     nil], @"itemSizes",
                                    @"YES", @"enableCollectionView",
                                    nil],
                                   
                                   [NSMutableArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"xbmc.addon.audio", @"type",
                                     [NSNumber numberWithBool:YES], @"enabled",
                                     [[NSArray alloc] initWithObjects: @"name", @"version", @"summary", @"thumbnail", nil], @"properties",
                                     nil], @"parameters", NSLocalizedString(@"Music Add-ons", nil), @"label", @"nocover_filemode", @"defaultThumb", @"65", @"rowHeight", @"65", @"thumbWidth",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:itemMusicWidthIphone], @"width",
                                      [NSNumber numberWithFloat:itemMusicHeightIphone], @"height", nil], @"iphone",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:itemMusicWidthIpad], @"width",
                                      [NSNumber numberWithFloat:itemMusicHeightIpad], @"height", nil], @"ipad",
                                     @"65", @"separatorInset",
                                     nil], @"itemSizes",
                                    @"YES", @"enableCollectionView",
                                    nil],
                                   
                                   [NSMutableArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"Input.ExecuteAction", @"id",
                                      @"method", @"type", nil], @"filter",
                                     nil], @"parameters",
                                    NSLocalizedString(@"Kodi actions", nil), @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", @"0", @"thumbWidth", NSLocalizedString(@"Execute a specific action", nil), @"morelabel",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"0", @"separatorInset",
                                     nil], @"itemSizes",
                                    nil],
                                   
                                   [NSMutableArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"GUI.ActivateWindow", @"id",
                                      @"method", @"type", nil], @"filter",
                                     nil], @"parameters",
                                    NSLocalizedString(@"Kodi windows", nil), @"label", @"nocover_filemode", @"defaultThumb", filemodeRowHeight, @"rowHeight", @"0", @"thumbWidth", NSLocalizedString(@"Activate a specific window", nil), @"morelabel",
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"0", @"separatorInset",
                                     nil], @"itemSizes",
                                    nil],
                                   
                                   nil];
    
    xbmcSettings.mainFields = [NSArray arrayWithObjects:
                               [NSDictionary  dictionaryWithObjectsAndKeys:
                                @"sections",@"itemid",
                                @"label", @"row1",
                                @"help", @"row2",
                                @"id", @"row3",
                                @"id", @"row4",
                                @"id",@"row5",
                                @"id",@"row6",
                                [NSNumber numberWithInt:2], @"playlistid",
                                @"sectionid",@"row8",
                                @"id", @"row9",
                                nil],
                               
                               [NSDictionary  dictionaryWithObjectsAndKeys:
                                @"addons",@"itemid",
                                @"name", @"row1",
                                @"summary", @"row2",
                                @"blank", @"row3",
                                @"blank", @"row4",
                                @"addonid",@"row5",
                                @"addonid",@"row6",
                                [NSNumber numberWithInt:2], @"playlistid",
                                @"addonid",@"row8",
                                @"addonid", @"row9",
                                nil],
                               
                               [NSDictionary  dictionaryWithObjectsAndKeys:
                                @"addons",@"itemid",
                                @"name", @"row1",
                                @"summary", @"row2",
                                @"blank", @"row3",
                                @"blank", @"row4",
                                @"addonid",@"row5",
                                @"addonid",@"row6",
                                [NSNumber numberWithInt:2], @"playlistid",
                                @"addonid",@"row8",
                                @"addonid", @"row9",
                                nil],
                               
                               [NSDictionary  dictionaryWithObjectsAndKeys:
                                @"addons",@"itemid",
                                @"name", @"row1",
                                @"summary", @"row2",
                                @"blank", @"row3",
                                @"blank", @"row4",
                                @"addonid",@"row5",
                                @"addonid",@"row6",
                                [NSNumber numberWithInt:2], @"playlistid",
                                @"addonid",@"row8",
                                @"addonid", @"row9",
                                nil],
                               
                               [NSDictionary  dictionaryWithObjectsAndKeys:
                                @"types",@"itemid",
                                @"Input.Action", @"typename",
                                @"enums", @"fieldname",
                                @"name", @"row1",
                                @"summary", @"row2",
                                @"blank", @"row3",
                                @"blank", @"row4",
                                @"addonid",@"row5",
                                @"addonid",@"row6",
                                [NSNumber numberWithInt:2], @"playlistid",
                                @"addonid",@"row8",
                                @"addonid", @"row9",
                                @"default-right-action-icon", @"thumbnail",
                                nil],
                               
                               [NSDictionary  dictionaryWithObjectsAndKeys:
                                @"types",@"itemid",
                                @"GUI.Window", @"typename",
                                @"enums", @"fieldname",
                                @"name", @"row1",
                                @"summary", @"row2",
                                @"blank", @"row3",
                                @"blank", @"row4",
                                @"addonid",@"row5",
                                @"addonid",@"row6",
                                [NSNumber numberWithInt:2], @"playlistid",
                                @"addonid",@"row8",
                                @"addonid", @"row9",
                                @"default-right-window-icon", @"thumbnail",
                                nil],
                               
                               nil];
    
    xbmcSettings.sheetActions = [NSArray arrayWithObjects:
                                 [NSArray array],
                                 [NSArray arrayWithObjects: NSLocalizedString(@"Execute program", nil), NSLocalizedString(@"Add button", nil), nil],
                                 [NSArray arrayWithObjects: NSLocalizedString(@"Execute video add-on", nil), NSLocalizedString(@"Add button", nil), nil],
                                 [NSArray arrayWithObjects: NSLocalizedString(@"Execute audio add-on", nil), NSLocalizedString(@"Add button", nil), nil],
                                 [NSArray arrayWithObjects: NSLocalizedString(@"Execute action", nil), NSLocalizedString(@"Add action button", nil), nil],
                                 [NSArray arrayWithObjects: NSLocalizedString(@"Activate window", nil), NSLocalizedString(@"Add window activation button", nil), nil],
                                 nil];
    
    
    xbmcSettings.subItem.disableNowPlaying = YES;
    xbmcSettings.subItem.mainMethod = [NSMutableArray arrayWithObjects:
                                       
                                       [NSArray arrayWithObjects:@"Settings.GetCategories", @"method", nil],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],

                                       nil];
    
    xbmcSettings.subItem.mainParameters = [NSMutableArray arrayWithObjects:
                                           [NSMutableArray arrayWithObjects:
                                            NSLocalizedString(@"Settings", nil), @"label", @"nocover_filemode", @"defaultThumb", @"65", @"rowHeight", @"32", @"thumbWidth",
                                            [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"40", @"separatorInset",
                                             nil], @"itemSizes",
                                            nil],
                                           
                                           [NSMutableArray arrayWithObjects:
                                            [NSNumber numberWithBool:YES], @"forceActionSheet",
                                            nil],
                                           
                                           [NSMutableArray arrayWithObjects:
                                            [NSNumber numberWithBool:YES], @"forceActionSheet",
                                            nil],
                                           
                                           [NSMutableArray arrayWithObjects:
                                            [NSNumber numberWithBool:YES], @"forceActionSheet",
                                            nil],
                                           
                                           [NSMutableArray arrayWithObjects:
                                            [NSNumber numberWithBool:YES], @"forceActionSheet",
                                            nil],
                                           
                                           [NSMutableArray arrayWithObjects:
                                            [NSNumber numberWithBool:YES], @"forceActionSheet",
                                            nil],
                                           
                                           nil];
    xbmcSettings.subItem.mainFields = [NSArray arrayWithObjects:
                                       [NSDictionary  dictionaryWithObjectsAndKeys:
                                        @"categories",@"itemid",
                                        @"label", @"row1",
                                        @"help", @"row2",
                                        @"id", @"row3",
                                        @"id", @"row4",
                                        @"id",@"row5",
                                        @"id",@"row6",
                                        [NSNumber numberWithInt:2], @"playlistid",
                                        @"categoryid",@"row8",
                                        @"id", @"row9",
                                        nil],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],
                                       
                                       [NSArray array],
                                       
                                       nil];
    
    xbmcSettings.subItem.rowHeight = 65;
    xbmcSettings.subItem.thumbWidth = 44;
    
    xbmcSettings.subItem.subItem.disableNowPlaying = YES;
    xbmcSettings.subItem.subItem.mainMethod = [NSMutableArray arrayWithObjects:
                                               
                                               [NSArray arrayWithObjects:@"Settings.GetSettings", @"method", nil],
                                               
                                               nil];
    
    xbmcSettings.subItem.subItem.mainParameters = [NSMutableArray arrayWithObjects:
                                                   [NSMutableArray arrayWithObjects:
                                                    NSLocalizedString(@"Settings", nil), @"label", @"nocover_filemode", @"defaultThumb", @"65", @"rowHeight", @"0", @"thumbWidth",
                                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"8", @"separatorInset",
                                                     nil], @"itemSizes",
                                                    nil],
                                                   
                                                   nil];
    xbmcSettings.subItem.subItem.mainFields = [NSArray arrayWithObjects:
                                               [NSDictionary  dictionaryWithObjectsAndKeys:
                                                @"settings",@"itemid",
                                                @"label", @"row1",
                                                @"help", @"row2",
                                                @"type", @"row3",
                                                @"default", @"row4",
                                                @"enabled",@"row5",
                                                @"id",@"row6",
                                                [NSNumber numberWithInt:2], @"playlistid",
                                                @"delimiter",@"row7",
                                                @"id",@"row8",
                                                @"id", @"row9",
                                                @"parent", @"row10",
                                                @"control", @"row11",
                                                @"value", @"row12",
                                                @"options", @"row13",
                                                @"allowempty", @"row14",
                                                @"addontype", @"row15",
                                                @"maximum", @"row16",
                                                @"minimum", @"row17",
                                                @"step", @"row18",
                                                @"definition", @"row19",
                                                nil],
                                               
                                               nil];
    xbmcSettings.subItem.subItem.sheetActions = [NSArray arrayWithObjects:
                                                 [NSArray array],
                                                 nil];
    
    xbmcSettings.subItem.subItem.rowHeight = 65;
    xbmcSettings.subItem.subItem.thumbWidth = 44;
    
#pragma mark - Host Right Menu
    rightMenuItems = [NSMutableArray arrayWithCapacity:1];
    mainMenu *rightmenu_Music = [[mainMenu alloc] init];
    rightmenu_Music.mainLabel = NSLocalizedString(@"XBMC Server", nil);
    rightmenu_Music.family = 1;
    rightmenu_Music.enableSection = YES;
    rightmenu_Music.mainMethod = [NSArray arrayWithObjects:
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSArray arrayWithObjects:
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                @"ServerInfo", @"label",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:.208f], @"red",
                                 [NSNumber numberWithFloat:.208f], @"green",
                                 [NSNumber numberWithFloat:.208f], @"blue",
                                 nil], @"bgColor",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:.702f], @"red",
                                 [NSNumber numberWithFloat:.702f], @"green",
                                 [NSNumber numberWithFloat:.702f], @"blue",
                                 nil], @"fontColor",

                                [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Wake On Lan", nil), @"label",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:.741f], @"red",
                                 [NSNumber numberWithFloat:.141f], @"green",
                                 [NSNumber numberWithFloat:.141f], @"blue",
                                 nil], @"bgColor",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:1], @"red",
                                 [NSNumber numberWithFloat:1], @"green",
                                 [NSNumber numberWithFloat:1], @"blue",
                                 nil], @"fontColor",
                                [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                @"icon_power", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"System.WOL", @"command",
                                 nil], @"action",
                                nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"LED Torch", nil), @"label",
                                @"torch", @"icon",
                                nil],
                               nil],@"offline",
                              
                              [NSArray arrayWithObjects:
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"LED Torch", nil), @"label",
                                @"torch", @"icon",
                                nil],
                               nil],@"utility",
                              
                              [NSArray arrayWithObjects:
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                @"ServerInfo", @"label",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:.208f], @"red",
                                 [NSNumber numberWithFloat:.208f], @"green",
                                 [NSNumber numberWithFloat:.208f], @"blue",
                                 nil], @"bgColor",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:.702f], @"red",
                                 [NSNumber numberWithFloat:.702f], @"green",
                                 [NSNumber numberWithFloat:.702f], @"blue",
                                 nil], @"fontColor",
                                [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Power off System", nil), @"label",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:.741f], @"red",
                                 [NSNumber numberWithFloat:.141f], @"green",
                                 [NSNumber numberWithFloat:.141f], @"blue",
                                 nil], @"bgColor",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:1], @"red",
                                 [NSNumber numberWithFloat:1], @"green",
                                 [NSNumber numberWithFloat:1], @"blue",
                                 nil], @"fontColor",
                                [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                @"icon_power", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"System.Shutdown", @"command",
                                 NSLocalizedString(@"Are you sure you want to power off your XBMC system now?", nil), @"message",
//                                 @"If you do nothing, the XBMC system will shutdown automatically in", @"countdown_message",
                                 [NSNumber numberWithInt:5], @"countdown_time",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Power off", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Hibernate", nil), @"label",
                                @"icon_hibernate", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"System.Hibernate",@"command",
                                 NSLocalizedString(@"Are you sure you want to hibernate your XBMC system now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Hibernate", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Suspend", nil), @"label",
                                @"icon_sleep", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"System.Suspend",@"command",
                                 NSLocalizedString(@"Are you sure you want to suspend your XBMC system now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Suspend", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Reboot", nil), @"label",
                                @"icon_reboot", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"System.Reboot",@"command",
                                 NSLocalizedString(@"Are you sure you want to reboot your XBMC system now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Reboot", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Quit XBMC application", nil), @"label",
                                @"icon_exit", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Application.Quit",@"command",
                                 NSLocalizedString(@"Are you sure you want to quit XBMC application now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Quit", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Update Audio Library", nil), @"label",
                                @"icon_update_audio", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"AudioLibrary.Scan",@"command",
                                 NSLocalizedString(@"Are you sure you want to update your audio library now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Update Audio", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Clean Audio Library", nil), @"label",
                                @"icon_clean_audio", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"AudioLibrary.Clean",@"command",
                                 NSLocalizedString(@"Are you sure you want to clean your audio library now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Clean Audio", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Update Video Library", nil), @"label",
                                @"icon_update_video", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"VideoLibrary.Scan",@"command",
                                 NSLocalizedString(@"Are you sure you want to update your video library now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Update Video", nil), @"ok_button",
                                 nil], @"action",
                                nil],
                               
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Clean Video Library", nil), @"label",
                                @"icon_clean_video", @"icon",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"VideoLibrary.Clean",@"command",
                                 NSLocalizedString(@"Are you sure you want to clean your video library now?", nil), @"message",
                                 NSLocalizedString(@"Cancel", nil), @"cancel_button",
                                 NSLocalizedString(@"Clean Video", nil), @"ok_button",
                                 nil], @"action",
                                nil],

                               [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"LED Torch", nil), @"label",
                                @"torch", @"icon",
                                nil],
                               nil],@"online",
                        
                              nil],
                             nil];
    [rightMenuItems addObject:rightmenu_Music];
    
#pragma mark - Now Playing Right Menu
    nowPlayingMenuItems = [NSMutableArray arrayWithCapacity:1];
    mainMenu *nowPlayingmenu_Music = [[mainMenu alloc] init];
    nowPlayingmenu_Music.mainLabel = @"VolumeControl";
    nowPlayingmenu_Music.family = 2;
    nowPlayingmenu_Music.mainMethod = [NSArray arrayWithObjects:
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"ServerInfo", @"label",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.208f], @"red",
                                      [NSNumber numberWithFloat:.208f], @"green",
                                      [NSNumber numberWithFloat:.208f], @"blue",
                                      nil], @"bgColor",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.702f], @"red",
                                      [NSNumber numberWithFloat:.702f], @"green",
                                      [NSNumber numberWithFloat:.702f], @"blue",
                                      nil], @"fontColor",
                                     [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                     nil],
                                    nil],@"offline",
                                   
                                   [NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"ServerInfo", @"label",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.208f], @"red",
                                      [NSNumber numberWithFloat:.208f], @"green",
                                      [NSNumber numberWithFloat:.208f], @"blue",
                                      nil], @"bgColor",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.702f], @"red",
                                      [NSNumber numberWithFloat:.702f], @"green",
                                      [NSNumber numberWithFloat:.702f], @"blue",
                                      nil], @"fontColor",
                                     [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"VolumeControl", @"label",
                                     @"volume", @"icon",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     NSLocalizedString(@"Keyboard", nil), @"label",
                                     @"keyboard_icon", @"icon",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"RemoteControl", @"label",
                                     nil],
                                    nil],@"online",
                                   
                                   nil],
                                  nil];
    [nowPlayingMenuItems addObject:nowPlayingmenu_Music];
    
#pragma mark - Remote Control Right Menu
    remoteControlMenuItems = [NSMutableArray arrayWithCapacity:1];
    mainMenu *remoteControlmenu_Music = [[mainMenu alloc] init];
    remoteControlmenu_Music.mainLabel = @"RemoteControl";
    remoteControlmenu_Music.family = 3;
    remoteControlmenu_Music.enableSection = YES;

    remoteControlmenu_Music.mainMethod = [NSArray arrayWithObjects:
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"ServerInfo", @"label",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.208f], @"red",
                                      [NSNumber numberWithFloat:.208f], @"green",
                                      [NSNumber numberWithFloat:.208f], @"blue",
                                      nil], @"bgColor",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.702f], @"red",
                                      [NSNumber numberWithFloat:.702f], @"green",
                                      [NSNumber numberWithFloat:.702f], @"blue",
                                      nil], @"fontColor",
                                     [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     NSLocalizedString(@"LED Torch", nil), @"label",
                                     @"torch", @"icon",
                                     nil],
                                    nil],@"offline",
                                   
                                   [NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"ServerInfo", @"label",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.208f], @"red",
                                      [NSNumber numberWithFloat:.208f], @"green",
                                      [NSNumber numberWithFloat:.208f], @"blue",
                                      nil], @"bgColor",
                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:.702f], @"red",
                                      [NSNumber numberWithFloat:.702f], @"green",
                                      [NSNumber numberWithFloat:.702f], @"blue",
                                      nil], @"fontColor",
                                     [NSNumber numberWithBool:YES], @"hideLineSeparator",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"VolumeControl", @"label",
                                     @"volume", @"icon",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     NSLocalizedString(@"Keyboard", nil), @"label",
                                     @"keyboard_icon", @"icon",
                                     [NSNumber numberWithBool:YES], @"revealViewTop",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     NSLocalizedString(@"Button Pad/Gesture Zone", nil), @"label",
                                     @"buttons-gestures", @"icon",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     NSLocalizedString(@"Help Screen", nil), @"label",
                                     @"button_info", @"icon",
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     NSLocalizedString(@"LED Torch", nil), @"label",
                                     @"torch", @"icon",
                                     nil],
                                    nil],@"online",
                                   
                                   nil],
                                  nil];
    [remoteControlMenuItems addObject:remoteControlmenu_Music];
    
//    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProximityChangeNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];

#pragma mark - Attaching menu to view

    self.serverName = NSLocalizedString(@"No connection", nil);
    InitialSlidingViewController *initialSlidingViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [mainMenuItems addObject:menu_Server];
        [mainMenuItems addObject:menu_Music];
        [mainMenuItems addObject:menu_Favourite];
        [mainMenuItems addObject:menu_Radio];
        [mainMenuItems addObject:menu_Addons];
        //[mainMenuItems addObject:menu_Movie];
        //[mainMenuItems addObject:menu_TVShows];
        //[mainMenuItems addObject:menu_Picture];
        //[mainMenuItems addObject:menu_LiveTV];
        [mainMenuItems addObject:menu_NowPlaying];
        //[mainMenuItems addObject:menu_Remote];
        initialSlidingViewController = [[InitialSlidingViewController alloc] initWithNibName:@"InitialSlidingViewController" bundle:nil];
        initialSlidingViewController.mainMenu = mainMenuItems;
        self.window.rootViewController = initialSlidingViewController;
    }
    else {
        [mainMenuItems addObject:menu_Server];
        [mainMenuItems addObject:menu_Music];
        [mainMenuItems addObject:menu_Favourite];
        [mainMenuItems addObject:menu_Radio];
        [mainMenuItems addObject:menu_Addons];
        //[mainMenuItems addObject:menu_NowPlaying];
        //[mainMenuItems addObject:menu_Movie];
        //[mainMenuItems addObject:menu_TVShows];
        //[mainMenuItems addObject:menu_Picture];
        //[mainMenuItems addObject:menu_LiveTV];
        //[mainMenuItems addObject:menu_Remote];
        self.windowController = [[ViewControllerIPad alloc] initWithNibName:@"ViewControllerIPad" bundle:nil];
        self.windowController.mainMenu = mainMenuItems;
        self.window.rootViewController = self.windowController;
    }
    return YES;
}

-(NSURL *)getServerJSONEndPoint {
    NSString *serverJSON = [NSString stringWithFormat:@"http://%@:%@/jsonrpc", obj.serverIP, obj.serverPort];
    return [NSURL URLWithString:serverJSON];
}

-(NSDictionary *)getServerHTTPHeaders {
    NSString *authCredential = [NSString stringWithFormat:@"%@:%@", obj.serverUser, obj.serverPass];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", AFBase64EncodedStringFromString(authCredential)];
    NSDictionary *httpHeaders = [NSDictionary dictionaryWithObjectsAndKeys:authValue, @"Authorization", nil];
    return httpHeaders;
}

static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

#pragma mark -

-(void)handleProximityChangeNotification:(id)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    UIApplication *xbmcRemote = [UIApplication sharedApplication];
    if([[UIDevice currentDevice] proximityState]){
        xbmcRemote.idleTimerDisabled = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationDidEnterBackgroundNotification" object: nil];
    }
    else{
        if ([[userDefaults objectForKey:@"lockscreen_preference"] boolValue]==YES){
            xbmcRemote.idleTimerDisabled = YES;
        }
        else {
            xbmcRemote.idleTimerDisabled = NO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationWillEnterForegroundNotification" object: nil];
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    }
}

-(void)wake:(NSString *)macAddress{
    Wake_on_LAN("255.255.255.255", [macAddress UTF8String]);
}

-(void)sendWOL:(NSString *)MAC withPort:(NSInteger)WOLport {
    CFSocketRef     WOLsocket;
    WOLsocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, 0, NULL, NULL);
    if (WOLsocket) {
        int desc = -1;
        desc = CFSocketGetNative(WOLsocket);
        int yes = -1;
        
        if (setsockopt (desc, SOL_SOCKET, SO_BROADCAST, (char *)&yes, sizeof (yes)) < 0) {
            NSLog(@"Set Socket options failed");
        }
        
        unsigned char ether_addr[6];
        
        int idx;
        
        for (idx = 0; idx + 2 <= [MAC length]; idx += 3)
        {
            NSRange     range = NSMakeRange(idx,2);
            NSString    *hexStr = [MAC substringWithRange:range];
            
            NSScanner   *scanner = [NSScanner scannerWithString:hexStr];
            unsigned int intValue;
            [scanner scanHexInt:&intValue];
            
            ether_addr[idx/3] = intValue;
        }
        
        /* Build the message to send - 6 x 0xff then 16 x MAC address */
        
        unsigned char message [102];
        unsigned char *message_ptr = message;
        
        memset(message_ptr, 0xFF, 6);
        message_ptr += 6;
        for (int i = 0; i < 16; ++i) {
            memcpy(message_ptr, ether_addr, 6);
            message_ptr += 6;
        }
        
        struct sockaddr_in addr;
        
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = 0xffffffff;
        addr.sin_port = htons(WOLport);
        
        CFDataRef message_data = CFDataCreate(NULL, (unsigned char*)&message, sizeof(message));
        CFDataRef destinationAddressData = CFDataCreate(NULL, (const UInt8 *)&addr, sizeof(addr));
        
        CFSocketError CFSocketSendData_error = CFSocketSendData(WOLsocket, destinationAddressData, message_data, 30);
        
        if (CFSocketSendData_error) {
            NSLog(@"CFSocketSendData error: %li", CFSocketSendData_error);
        }
    }
}

int Wake_on_LAN(char *ip_broadcast,const char *wake_mac){
	int i,sockfd,an=1;
	char *x;
	char mac[102];
	char macpart[2];
	char test[103];
	
	struct sockaddr_in serverAddress;
	
	if ( (sockfd = socket( AF_INET, SOCK_DGRAM,17)) < 0 ) {
		return 1;
	}
	
	setsockopt(sockfd,SOL_SOCKET,SO_BROADCAST,&an,sizeof(an));
	
	bzero( &serverAddress, sizeof(serverAddress) );
	serverAddress.sin_family = AF_INET;
	serverAddress.sin_port = htons( 9 );
	
	inet_pton( AF_INET, ip_broadcast, &serverAddress.sin_addr );
	
	for (i=0;i<6;i++) mac[i]=255;
	for (i=1;i<17;i++) {
		macpart[0]=wake_mac[0];
		macpart[1]=wake_mac[1];
		mac[6*i]=strtol(macpart,&x,16);
		macpart[0]=wake_mac[3];
		macpart[1]=wake_mac[4];
		mac[6*i+1]=strtol(macpart,&x,16);
		macpart[0]=wake_mac[6];
		macpart[1]=wake_mac[7];
		mac[6*i+2]=strtol(macpart,&x,16);
		macpart[0]=wake_mac[9];
		macpart[1]=wake_mac[10];
		mac[6*i+3]=strtol(macpart,&x,16);
		macpart[0]=wake_mac[12];
		macpart[1]=wake_mac[13];
		mac[6*i+4]=strtol(macpart,&x,16);
		macpart[0]=wake_mac[15];
		macpart[1]=wake_mac[16];
		mac[6*i+5]=strtol(macpart,&x,16);
	}
	for (i=0;i<103;i++) test[i]=mac[i];
	test[102]=0;
	
	sendto(sockfd,&mac,102,0,(struct sockaddr *)&serverAddress,sizeof(serverAddress));
	close(sockfd);
	
	return 0;
}


- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    UIApplication *xbmcRemote = [UIApplication sharedApplication];
    if ([[userDefaults objectForKey:@"lockscreen_preference"] boolValue]==YES ){
        xbmcRemote.idleTimerDisabled = YES;
        
    }
    else {
        xbmcRemote.idleTimerDisabled = NO;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationWillEnterForegroundNotification" object: nil];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(event.type == UIEventSubtypeMotionShake){
        [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationShakeNotification" object: nil]; 
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void)saveServerList{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) { 
        [NSKeyedArchiver archiveRootObject:arrayServerList toFile:self.dataFilePath];
    }
}

-(void)clearAppDiskCache{
    // OLD SDWEBImageCache
    NSString *fullNamespace = @"ImageCache"; 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fullNamespace];
    [[NSFileManager defaultManager] removeItemAtPath:diskCachePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[paths objectAtIndex:0] error:nil];
    
    // TO BE CHANGED!!!
    fullNamespace = @"com.hackemist.SDWebImageCache.default";
    diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fullNamespace];
    [[NSFileManager defaultManager] removeItemAtPath:diskCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.libraryCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.libraryCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.epgCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.epgCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    
    // Clean NetworkCache
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, TRUE) objectAtIndex:0];
    NSString *appID = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *path = [NSString stringWithFormat:@"%@/%@/Cache.db-wal", caches, appID];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    path = [NSString stringWithFormat:@"%@/%@/Cache.db-shm", caches, appID];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    path = [NSString stringWithFormat:@"%@/%@/Cache.db", caches, appID];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    path = [NSString stringWithFormat:@"%@/%@/fsCachedData", caches, appID];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
