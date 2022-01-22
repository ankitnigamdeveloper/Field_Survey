//
//  AppConstants.h
//  Field_Survey
//
//  Created by Martin on 2016/04/29.
//

#import <Foundation/Foundation.h>

// Bit values. Used for creating the bitwise flag for turning points.
extern NSInteger const BIT_0;
extern NSInteger const BIT_1;
extern NSInteger const BIT_2;
extern NSInteger const BIT_3;
extern NSInteger const BIT_4;
extern NSInteger const BIT_5;
extern NSInteger const BIT_6;
extern NSInteger const BIT_7;
extern NSInteger const BIT_8;
extern NSInteger const BIT_9;
extern NSInteger const BIT_10;
extern NSInteger const BIT_11;

// Total number of shots on each side.
extern NSInteger const MAX_SIDE_SHOTS;

// Shot types.
extern NSString* const SHOT_TYPE_RS;
extern NSString* const SHOT_TYPE_FS;
extern NSString* const SHOT_TYPE_IFS;

// Formatter strings.
extern NSString* const CREATION_DATE_FORMAT;
extern NSString* const SUBSCRIPTION_DATE_DOWNLOADED_FORMAT;
extern NSString* const SUBSCRIPTION_COMPARE_FORMAT;
extern NSString* const TRAVERSE_EXPORT_DATE_FORMAT;

// Traverse cell config keys.
extern NSString* const CELL_KEY_EASTING;
extern NSString* const CELL_KEY_NORTHING;
extern NSString* const CELL_KEY_ELEVATION;
// Cell config keys.
extern NSString* const CELL_KEY_STATION_INDEX;
extern NSString* const CELL_KEY_STATION_IS_INVALID;
extern NSString* const CELL_KEY_STATION;
extern NSString* const CELL_KEY_SHOT_TYPE;
extern NSString* const CELL_KEY_PREVIOUS_CELL_SHOT_TYPE;
extern NSString* const CELL_KEY_FOREAZIM;
extern NSString* const CELL_KEY_HORIZONTAL_DISTANCE;
extern NSString* const CELL_KEY_SLOPE_DISTANCE;
extern NSString* const CELL_KEY_SLOPE_PERCENTAGE;
extern NSString* const CELL_KEY_SSL;
extern NSString* const CELL_KEY_SSR;
extern NSString* const CELL_KEY_GROUND;
extern NSString* const CELL_KEY_CREEK;
extern NSString* const CELL_KEY_LABEL;
// SideShot cell config keys.
extern NSString* const CELL_KEY_SHOW_TURNING_POINT;
extern NSString* const CELL_KEY_TITLE;
extern NSString* const CELL_KEY_INDEX;
extern NSString* const CELL_KEY_SIDE_SHOT;
extern NSString* const CELL_KEY_CURRENT_COLLECTION;

// Used when we're creating new stations.
extern NSString* const DEFAULTS_KEY_TYPE;
extern NSString* const DEFAULTS_KEY_FOREAZIM;
extern NSString* const DEFAULTS_KEY_HORIZONTAL_DISTANCE;
extern NSString* const DEFAULTS_KEY_SLOPE_DISTANCE;
extern NSString* const DEFAULTS_KEY_SLOPE_PERCENTAGE;
extern NSString* const KEY_CALCULATED_SLOPE_DISTANCE;
extern NSString* const KEY_CALCULATED_HORIZONTAL_DISTANCE;

// Regular expressions.
extern NSString* const REGEX_INPUT_ONLY_NUMBERS;
extern NSString* const REGEX_INPUT_NUMBERS_AND_DECIMAL;
extern NSString* const REGEX_INPUT_ONLY_ALPHABETIC_CHARACTERS;
extern NSString* const REGEX_INPUT_NUMBERS_AND_COLON;
extern NSString* const REGEX_STATION_INDEX;

// DataController
extern NSInteger const ALL_STATIONS_VALID;

// Server url & endpoints
extern NSString* const SERVER_BASE_URL;
extern NSString* const SERVER_MOBILE_LOGIN_ENDPOINT;
extern NSString* const SERVER_MOBILE_LOGOUT_ENDPOINT;
extern NSString* const SERVER_MOBILE_SYNC_LICENSE_ENDPOINT;

// NSUserDefaults keys & secret.
extern NSString* const UD_KEY_USERNAME;
extern NSString* const UD_KEY_PASSWORD;
extern NSString* const UD_KEY_SUBSCRIPTION_EXPIRY_DATE;
extern NSString* const UD_KEY_COMPANY;
extern NSString* const UD_KEY_LAST_TIME_SYNCED;
extern NSString* const UD_SECRET;

// Misc. site urls.
extern NSString* const BAWTREE_PRODUCT_URL;
extern NSString* const SOFTREE_PRODUCT_URL;

/// Defined here for accessibility & to avoid code duplication.
// Used on the tabbar that holds the three entry pages.
typedef enum { TI_COORDINATES=0, TI_STATION_SHOT=1, TI_SIDE_SHOTS=2 } TabbarIndex;
// Used on the traverse edit view.
typedef enum { CLSHOTS=1, SIDE_SHOTS } Tabs;
// Used on c/l coordinate entry view.
typedef enum { SLOPE=1, HORIZONTAL } DistanceMode;
// Used on the traverse list.
typedef enum { EMAIL=1, ITUNES } ExportOption;
// Used when dealing with server responses; these are copies of the codes we've defined on the server and must be kept up to date with any changes that occur there.
typedef enum {
    SUCCESSFUL_REQUEST=0,
    INCOMPLETE_REQUEST=1,
    USER_NOT_FULLY_SETUP=2,
    INACTIVE_USER=3,
    BAD_CREDENTIALS=4,
    WRONG_REQUEST_METHOD=5,
    SUBSCRIPTION_EXPIRED=6,
    ACCOUNT_ALREADY_IN_USE=7
} ServerResponse;
