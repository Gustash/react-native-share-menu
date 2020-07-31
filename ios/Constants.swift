//
//  Constants.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 29/07/2020.
//

// MARK: Error Codes
public let DISMISS_SHARE_EXTENSION_WITH_ERROR_CODE = 1

// MARK: Error Messages

public let NO_URL_TYPES_ERROR_MESSAGE = "You have not defined CFBundleURLTypes in your Info.plist"
public let NO_URL_SCHEMES_ERROR_MESSAGE = "You have not defined CFBundleURLSchemes in your Info.plist"
public let NO_SCHEME_ERROR_MESSAGE = "You have not defined a scheme under CFBundleURLSchemes in your Info.plist"
public let NO_APP_GROUP_ERROR = "Failed to get App Group User Defaults. Did you set up an App Group on your App and Share Extension?"
public let NO_INFO_PLIST_INDENTIFIER_ERROR = "You haven't defined \(HOST_APP_IDENTIFIER_INFO_PLIST_KEY) in your Share Extension's Info.plist"
public let NO_INFO_PLIST_URL_SCHEME_ERROR = "You haven't defined \(HOST_URL_SCHEME_INFO_PLIST_KEY) in your Share Extension's Info.plist"
public let COULD_NOT_FIND_STRING_ERROR = "Couldn't find string"
public let COULD_NOT_FIND_URL_ERROR = "Couldn't find url"
public let COULD_NOT_FIND_IMG_ERROR = "Couldn't find image"
public let COULD_NOT_PARSE_IMG_ERROR = "Couldn't parse image"
public let COULD_NOT_SAVE_FILE_ERROR = "Couldn't save file on disk"
public let NO_EXTENSION_CONTEXT_ERROR = "No extension context attached"
public let NO_DELEGATE_ERROR = "No ReactShareViewDelegate attached"
public let COULD_NOT_FIND_ITEM_ERROR = "Couldn't find item attached to this share"
public let FEATURE_NOT_SUPPORTED_VERSION = "This feature is not supported on this iOS version"
public let WRONG_RECIPIENT_DATA = "The recipient data was not formatted correctly"

// MARK: Keys

public let USER_DEFAULTS_KEY = "ShareMenuUserDefaults"
public let USER_DEFAULTS_EXTRA_DATA_KEY = "ShareMenuUserDefaultsExtraData"
public let URL_SCHEME_INFO_PLIST_KEY = "AppURLScheme"
public let HOST_APP_IDENTIFIER_INFO_PLIST_KEY = "HostAppBundleIdentifier"
public let HOST_URL_SCHEME_INFO_PLIST_KEY = "HostAppURLScheme"

public let REACT_SHARE_VIEW_BACKGROUND_COLOR_KEY = "ReactShareViewBackgroundColor"
public let COLOR_RED_KEY = "Red"
public let COLOR_GREEN_KEY = "Green"
public let COLOR_BLUE_KEY = "Blue"
public let COLOR_ALPHA_KEY = "Alpha"
public let COLOR_TRANSPARENT_KEY = "Transparent"

public let MIME_TYPE_KEY =  "mimeType"
public let DATA_KEY =  "data"
public let EXTRA_DATA_KEY =  "extraData"

public let RECIPIENTS_KEY = "recipients"
public let HANDLE_KEY = "handle"
public let HANDLE_TYPE_KEY = "handleType"
public let NAME_KEY = "name"
public let NAME_PREFIX_KEY = "prefix"
public let GIVEN_NAME_KEY = "givenName"
public let MIDDLE_NAME_KEY = "middleName"
public let FAMILY_NAME_KEY = "familyName"
public let NAME_SUFFIX_KEY = "suffix"
public let NICKNAME_KEY = "nickname"
public let PHONETIC_REPRESENTATION_KEY = "phoneticRepresentation"
public let IMAGE_KEY = "image"
public let IDENTIFIER_KEY = "identifier"
public let CUSTOM_IDENTIFIER_KEY = "customIdentifier"
public let IS_ME_KEY = "isMe"
public let CONTENT_KEY = "content"
public let SPOKEN_PHRASE_KEY = "spokenPhrase"
public let CONVERSATION_ID_KEY = "conversationId"
public let SERVICE_NAME_KEY = "serviceName"
public let SENDER_KEY = "sender"

// MARK: Events

public let NEW_SHARE_EVENT = "NewShareEvent"
