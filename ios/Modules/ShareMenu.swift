import Intents
import IntentsUI

@objc(ShareMenu)
class ShareMenu: RCTEventEmitter {

    private(set) static var _shared: ShareMenu?
    @objc public static var shared: ShareMenu
    {
        get {
            return ShareMenu._shared!
        }
    }

    var sharedData: [String:String]?

    static var initialShare: (UIApplication, URL, [UIApplication.OpenURLOptionsKey : Any])?

    var hasListeners = false

    var _targetUrlScheme: String?
    var targetUrlScheme: String
    {
        get {
            return _targetUrlScheme!
        }
    }

    public override init() {
        super.init()
        ShareMenu._shared = self

        if let (app, url, options) = ShareMenu.initialShare {
            share(application: app, openUrl: url, options: options)
        }
    }

    override static public func requiresMainQueueSetup() -> Bool {
        return false
    }

    open override func supportedEvents() -> [String]! {
        return [NEW_SHARE_EVENT]
    }

    open override func startObserving() {
        hasListeners = true
    }

    open override func stopObserving() {
        hasListeners = false
    }

    public static func messageShare(
        application app: UIApplication,
        openUrl url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any]
    ) {
        guard (ShareMenu._shared != nil) else {
            initialShare = (app, url, options)
            return
        }
        
        ShareMenu.shared.share(application: app, openUrl: url, options: options)
    }
    
    func share(
        application app: UIApplication,
        openUrl url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any]) {
        if _targetUrlScheme == nil {
            guard let bundleUrlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [NSDictionary] else {
                print("Error: \(NO_URL_TYPES_ERROR_MESSAGE)")
                return
            }
            guard let bundleUrlSchemes = bundleUrlTypes.first?.value(forKey: "CFBundleURLSchemes") as? [String] else {
                print("Error: \(NO_URL_SCHEMES_ERROR_MESSAGE)")
                return
            }
            guard let expectedUrlScheme = bundleUrlSchemes.first else {
                print("Error \(NO_URL_SCHEMES_ERROR_MESSAGE)")
                return
            }

            _targetUrlScheme = expectedUrlScheme
        }

        guard let scheme = url.scheme, scheme == targetUrlScheme else { return }
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        guard let userDefaults = UserDefaults(suiteName: "group.\(bundleId)") else {
            print("Error: \(NO_APP_GROUP_ERROR)")
            return
        }

        let extraData = userDefaults.object(forKey: USER_DEFAULTS_EXTRA_DATA_KEY) as? [String:Any]

        if let data = userDefaults.object(forKey: USER_DEFAULTS_KEY) as? [String:String] {
            sharedData = data
            dispatchEvent(with: data, and: extraData)
            userDefaults.removeObject(forKey: USER_DEFAULTS_KEY)
        }
    }

    @objc(getSharedText:)
    func getSharedText(callback: RCTResponseSenderBlock) {
        guard var data: [String:Any] = sharedData else {
            callback([])
            return
        }

        if let bundleId = Bundle.main.bundleIdentifier, let userDefaults = UserDefaults(suiteName: "group.\(bundleId)") {
            data[EXTRA_DATA_KEY] = userDefaults.object(forKey: USER_DEFAULTS_EXTRA_DATA_KEY) as? [String:Any]
        } else {
            print("Error: \(NO_APP_GROUP_ERROR)")
        }

        callback([data as Any])
        sharedData = nil
    }
    
    @objc(donateShareIntent:resolve:reject:)
    func donateShareIntent(options: [String:Any],
                           resolve: @escaping RCTPromiseResolveBlock,
                           reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 11.0, *) else  {
            reject("error", FEATURE_NOT_SUPPORTED_VERSION, nil)
            return
        }

        var recipients: [INPerson]?
        var sender: INPerson?

        if #available(iOS 12.0, *) {
            recipients = loadPeople(options)

            if let senderOption = options[SENDER_KEY] as? [String:Any?] {
                sender = loadPerson(senderOption)
            }
        }

        let content = options[CONTENT_KEY] as? String ?? nil

        var groupName: INSpeakableString?

        if let spokenPhrase = options[SPOKEN_PHRASE_KEY] as? String {
            groupName = INSpeakableString(spokenPhrase: spokenPhrase)
        }

        var conversationId: String?

        if let identifier = options[CONVERSATION_ID_KEY] as? String {
            conversationId = identifier
        }

        var serviceName: String?

        if let service = options[SERVICE_NAME_KEY] as? String {
            serviceName = service
        }

        let sendMessageIntent = INSendMessageIntent(recipients: recipients,
                                                    content: content,
                                                    speakableGroupName: groupName,
                                                    conversationIdentifier: conversationId,
                                                    serviceName: serviceName,
                                                    sender: sender)

        if #available(iOS 12.0, *) {
            var image: INImage?

            if let imageUrl = options[IMAGE_KEY] as? String, let url = URL(string: imageUrl) {
                image = INImage(url: url)
            } else if let imageSource = options[IMAGE_KEY] {
                DispatchQueue.main.sync {
                    if let uiImage = RCTConvert.uiImage(imageSource) {
                        image = INImage(uiImage: uiImage)
                    }
                }
            }

            sendMessageIntent.setImage(image, forParameterNamed: \.speakableGroupName)
        }

        // Donate the intent.
        let interaction = INInteraction(intent: sendMessageIntent, response: nil)
        interaction.donate(completion: { error in
            guard error == nil else {
                reject("error", error!.localizedDescription, nil)
                return
            }

            resolve(nil)
        })
    }

    @available(iOS 12.0, *)
    func loadPeople(_ options: [String:Any]) -> [INPerson]? {
        guard options[RECIPIENTS_KEY] != nil else {
            return nil
        }

        guard let recipientsOptions = options[RECIPIENTS_KEY] as? [[String:Any?]] else {
            print("Error: \(WRONG_RECIPIENT_DATA)")
            return nil
        }

        return recipientsOptions.map { loadPerson($0) }
    }

    @available(iOS 12.0, *)
    func loadPerson(_ recipient: [String:Any?]) -> INPerson {
        let handle = recipient[HANDLE_KEY] as! String
        let handleType: INPersonHandleType = {
            switch(recipient[HANDLE_TYPE_KEY] as? String) {
            case "email":
                return .emailAddress
            case "phone":
                return .phoneNumber
            default:
                return .unknown
            }
        }()

        var nameComponents: PersonNameComponents?
        var displayName: String?

        if let nameDetails = recipient[NAME_KEY] as? [String:String] {
            nameComponents = PersonNameComponents(from: nameDetails)
        } else if let name = recipient[NAME_KEY] as? String {
            displayName = name
        }

        let contactIdentifier = recipient[IDENTIFIER_KEY] as? String ?? nil
        let customIdentifier = recipient[CUSTOM_IDENTIFIER_KEY] as? String ?? nil
        let isMe = recipient[IS_ME_KEY] as? Bool ?? false

        var image: INImage?

        if let imageUrl = recipient[IMAGE_KEY] as? String, let url = URL(string: imageUrl) {
            image = INImage(url: url)
        } else if let imageSource = recipient[IMAGE_KEY] {
            DispatchQueue.main.sync {
                if let uiImage = RCTConvert.uiImage(imageSource) {
                    image = INImage(uiImage: uiImage)
                }
            }
        }

        return INPerson(personHandle: INPersonHandle(value: handle, type: handleType),
                        nameComponents: nameComponents,
                        displayName: displayName,
                        image: image,
                        contactIdentifier: contactIdentifier,
                        customIdentifier: customIdentifier,
                        isMe: isMe)
    }

    func dispatchEvent(with data: [String:String], and extraData: [String:Any]?) {
        guard hasListeners else { return }

        var finalData = data as [String:Any]
        if (extraData != nil) {
            finalData[EXTRA_DATA_KEY] = extraData
        }
        
        sendEvent(withName: NEW_SHARE_EVENT, body: finalData)
    }
}
