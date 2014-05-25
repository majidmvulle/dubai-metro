//
//  constants.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#ifndef DubaiMetro_constants_h
#define DubaiMetro_constants_h
#endif

//#define DM_DEBUG "Comment this line to remove NSLog for some statements"

#define BACKGROUND_COLOR [UIColor colorWithRed:23/255.0 green:30/255.0 blue:49/255.0 alpha:1.0]
#define LIGHT_COLOR [UIColor colorWithRed:29/255.0 green:98/255.0 blue:240/255.0 alpha:1.0]

    //Menu TableView
#define MENU_TABLE_COLOR [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0]
#define MENU_TABLE_CELL_COLOR [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0]
#define MENU_TABLE_CELL_SELECTED_COLOR [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1.0]

#define DM_MANAGED_DOCUMENT @"DubaiMetro"

#define DM_FONT_NAME @"Frutiger LT 55 Roman"
//#define DM_NAVIGATION_TITLE_FONT_NAME @"Frutiger LT 57 Cn"
#define DM_NAVIGATION_TITLE_FONT_NAME @"Frutiger LT 47 Light Cn"
#define DM_STATION_ACTIVE @"OPEN"
#define DM_STATION_NOT_ACTIVE @"CLOSED"

#define LOCALE_US @"en_US"

#define HOW_RECENT_INTERVAL 3.0 //seconds

#define NEAREST_STATION_THRESHOLD 5500.0 //Nearest threshold = 5.5 km
#define TRAIN_TIME_UPDATE_INTERVAL 5.0 //seconds
#define AT_STATION_RADIUS 120.0 //metres
#define FIRST_TRAIN_TIME 900.f //15 minutes (60*15)


#define LINE_LATITUDE @"lineLatitude"
#define LINE_LONGITUDE @"lineLongitude"

#define LINE_GREEN_CODE @"MGr"
#define LINE_RED_CODE @"MRed"

#define AT_STATION_TEXT @"You Are Here"

#define SAFARI @"Safari"
#define CHROME @"Chrome"
#define APP_WEBPAGE @"http://majidmvulle.com/dubaimetro?utm_source=dubaimetroapp&utm_medium=app&utm_campaign=aboutpage"
#define APPSTORE_SHORT_URL @"https://appsto.re/ae/HcFEU.i"

#define FONT_COURIER @"Courier"