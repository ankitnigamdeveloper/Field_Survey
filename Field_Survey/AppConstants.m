//
//  AppConstants.m
//  Field_Survey
//
//  Created by Martin on 2016/04/29.
//

#import "AppConstants.h"

// Bit values. Used for creating the bitwise flag for turning points.
NSInteger const BIT_0 = 1;
NSInteger const BIT_1 = 2;
NSInteger const BIT_2 = 4;
NSInteger const BIT_3 = 8;
NSInteger const BIT_4 = 16;
NSInteger const BIT_5 = 32;
NSInteger const BIT_6 = 64;
NSInteger const BIT_7 = 128;
NSInteger const BIT_8 = 256;
NSInteger const BIT_9 = 512;
NSInteger const BIT_10 = 1024;
NSInteger const BIT_11 = 2048;

// Total number of shots on each side.
NSInteger const MAX_SIDE_SHOTS = 12;

// Shot Types.
NSString* const SHOT_TYPE_RS = @"RS";
NSString* const SHOT_TYPE_FS = @"FS";
NSString* const SHOT_TYPE_IFS = @"IFS";

// Formatter strings.
NSString* const CREATION_DATE_FORMAT = @"yyyy/MM/dd";
NSString* const SUBSCRIPTION_DATE_DOWNLOADED_FORMAT = @"yyyy/MM/dd HH:mm:ss";
NSString* const SUBSCRIPTION_COMPARE_FORMAT = @"yyyy/MM/dd";
NSString* const TRAVERSE_EXPORT_DATE_FORMAT = @"yyyyMMdd";

// Traverse cell config keys.
NSString* const CELL_KEY_EASTING = @"cell_easting";
NSString* const CELL_KEY_NORTHING = @"cell_northing";
NSString* const CELL_KEY_ELEVATION = @"cell_elevation";
// Station cell config keys.
NSString* const CELL_KEY_STATION_INDEX = @"cell_index";
NSString* const CELL_KEY_STATION_IS_INVALID = @"cell_is_invalid";
NSString* const CELL_KEY_STATION = @"cell_station";
NSString* const CELL_KEY_SHOT_TYPE = @"cell_shot_type";
NSString* const CELL_KEY_PREVIOUS_CELL_SHOT_TYPE = @"cell_prev_shot_type";
NSString* const CELL_KEY_FOREAZIM = @"cell_foreazim";
NSString* const CELL_KEY_HORIZONTAL_DISTANCE = @"cell_hor_dist";
NSString* const CELL_KEY_SLOPE_DISTANCE = @"cell_slp_dist";
NSString* const CELL_KEY_SLOPE_PERCENTAGE = @"cell_slp_per";
NSString* const CELL_KEY_SSL = @"cell_ssl";
NSString* const CELL_KEY_SSR = @"cell_ssr";
NSString* const CELL_KEY_GROUND = @"cell_gnd";
NSString* const CELL_KEY_CREEK = @"cell_creek";
NSString* const CELL_KEY_LABEL = @"cell_label";
// SideShot cell config keys.
NSString* const CELL_KEY_SHOW_TURNING_POINT = @"cell_show_tp";
NSString* const CELL_KEY_TITLE = @"cell_title";
NSString* const CELL_KEY_INDEX = @"cell_index";
NSString* const CELL_KEY_SIDE_SHOT = @"cell_side_shot";
NSString* const CELL_KEY_CURRENT_COLLECTION = @"cell_curr_collection";

// Used when we're creating new stations.
NSString* const DEFAULTS_KEY_TYPE = @"defaults_type";
NSString* const DEFAULTS_KEY_FOREAZIM = @"defaults_foreazim";
NSString* const DEFAULTS_KEY_HORIZONTAL_DISTANCE = @"defaults_hor_dist";
NSString* const DEFAULTS_KEY_SLOPE_DISTANCE = @"defaults_slp_dist";
NSString* const DEFAULTS_KEY_SLOPE_PERCENTAGE = @"defaults_slp_per";
NSString* const KEY_CALCULATED_SLOPE_DISTANCE = @"calc_slp_dist";
NSString* const KEY_CALCULATED_HORIZONTAL_DISTANCE = @"calc_hor_dist";

// Regular expressions.
NSString* const REGEX_INPUT_ONLY_NUMBERS = @"[0-9]";
NSString* const REGEX_INPUT_NUMBERS_AND_DECIMAL = @"[0-9]|\\.|\\-";
NSString* const REGEX_INPUT_ONLY_ALPHABETIC_CHARACTERS = @"[a-zA-Z]";
NSString* const REGEX_INPUT_NUMBERS_AND_COLON = @"[0-9]|\\:";
NSString* const REGEX_STATION_INDEX = @"^([0-9]+(\\:[0-9]+)?)";

// DataController
NSInteger const ALL_STATIONS_VALID = -1;

// Server url & endpoints
NSString* const SERVER_BASE_URL = @"https://fieldsurvey-production.herokuapp.com/";//@"https://fieldsurvey-development.herokuapp.com/";//
NSString* const SERVER_MOBILE_LOGIN_ENDPOINT = @"mobile_login";
NSString* const SERVER_MOBILE_LOGOUT_ENDPOINT = @"mobile_logout";
NSString* const SERVER_MOBILE_SYNC_LICENSE_ENDPOINT = @"mobile_sync_license?";

// NSUserDefaults keys & secret.
NSString* const UD_KEY_USERNAME = @"udk_username";
NSString* const UD_KEY_PASSWORD = @"udk_password";
NSString* const UD_KEY_SUBSCRIPTION_EXPIRY_DATE = @"udk_sub_expiry_date";
NSString* const UD_KEY_COMPANY = @"udk_company";
NSString* const UD_KEY_LAST_TIME_SYNCED = @"udk_last_time_synced";
NSString* const UD_SECRET = @"ajdazrigakrwztpvskqpsksmkorfgyqqurbqycth"; // DO NOT CHANGE THIS VALUE.

// Misc. site urls.
NSString* const BAWTREE_PRODUCT_URL = @"https://www.bawtreesoftware.com";
NSString* const SOFTREE_PRODUCT_URL = @"https://www.softree.com/";
