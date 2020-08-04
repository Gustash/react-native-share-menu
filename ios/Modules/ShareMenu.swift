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

    let targetUrlScheme: String
    let userDefaults: UserDefaults

    public override init() {
        let bundleUrlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [NSDictionary]
        assert(bundleUrlTypes != nil, NO_URL_TYPES_ERROR_MESSAGE)

        let bundleUrlSchemes = bundleUrlTypes!.first?.value(forKey: "CFBundleURLSchemes") as? [String]
        assert(bundleUrlSchemes != nil, NO_URL_SCHEMES_ERROR_MESSAGE)

        let expectedUrlScheme = bundleUrlSchemes!.first
        assert(expectedUrlScheme != nil, NO_URL_SCHEMES_ERROR_MESSAGE)

        let bundleId = Bundle.main.bundleIdentifier
        assert(bundleId != nil)

        let userDefaults = UserDefaults(suiteName: "group.\(bundleId!)")
        assert(userDefaults != nil, NO_APP_GROUP_ERROR)

        self.targetUrlScheme = expectedUrlScheme!
        self.userDefaults = userDefaults!

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
        guard let scheme = url.scheme, scheme == targetUrlScheme else { return }

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

        data[EXTRA_DATA_KEY] = userDefaults.object(forKey: USER_DEFAULTS_EXTRA_DATA_KEY) as? [String:Any]

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

        var conversationId: String!

        if let identifier = options[CONVERSATION_ID_KEY] as? String {
            conversationId = identifier
        } else {
            reject("error", NO_CONVERSATION_ID_ERROR, nil)
            return
        }

        var recipients: [INPerson]?
        var sender: INPerson?

        if #available(iOS 12.0, *) {
            recipients = loadPeople(options)

            if let senderOption = options[SENDER_KEY] as? [String:Any?] {
                sender = INPerson.init(parse: senderOption)
            }
        }

        let content = options[CONTENT_KEY] as? String ?? nil

        var groupName: INSpeakableString?

        if let spokenPhrase = options[GROUP_NAME_KEY] as? String {
            groupName = INSpeakableString(spokenPhrase: spokenPhrase)
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

            sendMessageIntent.setImage(image, forParameterNamed: \.conversationIdentifier)
        }

        // Donate the intent.
        let interaction = INInteraction(intent: sendMessageIntent, response: nil)
        interaction.donate(completion: { error in
            guard error == nil else {
                reject("error", error!.localizedDescription, nil)
                return
            }

            do {
                try self.saveShareIntent(options)
            }
            catch {
                reject("error", error.localizedDescription, nil)
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

        return recipientsOptions.map { INPerson.init(parse: $0) }
    }

    func saveShareIntent(_ options: [String:Any]) throws {
        let json = try JSONSerialization.data(withJSONObject: options)
        
        userDefaults.set(json, forKey: USER_DEFAULTS_SHARE_INTENT_KEY)
        
//        let data = Data()
//
//        if let conversationId = options[CONVERSATION_ID_KEY] as? String {
//            data[CONVERSATION_ID_KEY] = conversationId
//            data.setValue(conversationId, forKey: CONVERSATION_ID_KEY)
//        }
//        if let recipients = options[RECIPIENTS_KEY] as? [[String:Any]] {
//            let recipientData = recipients.map { encodePerson($0) }
//            data.setValue(recipientData, forKey: RECIPIENTS_KEY)
//        }
//        if let sender = options[SENDER_KEY] as? [String:Any] {
//            data.setValue(encodePerson(sender), forKey: SENDER_KEY)
//        }
//        if let content = options[CONTENT_KEY] as? String {
//            data.setValue(content, forKey: CONTENT_KEY)
//        }
//        if let groupName = options[GROUP_NAME_KEY] as? String {
//            data.setValue(groupName, forKey: GROUP_NAME_KEY)
//        }
//        if let serviceName = options[SERVICE_NAME_KEY] as? String {
//            data.setValue(serviceName, forKey: SERVICE_NAME_KEY)
//        }
//
//        userDefaults.set(data, forKey: USER_DEFAULTS_SHARE_INTENT_KEY)
    }
    
//    func encodePerson(_ person: [String:Any]) -> NSData {
//        let data = NSData()
//
//        if let handle = person[HANDLE_KEY] as? String {
//            data.setValue(handle, forKey: HANDLE_KEY)
//        }
//        let handleType = person[HANDLE_TYPE_KEY] as? String ?? "unknown"
//        data.setValue(handleType, forKeyPath: HANDLE_TYPE_KEY)
//        if let contactIdentifier = person[IDENTIFIER_KEY] as? String {
//            data.setValue(contactIdentifier, forKeyPath: IDENTIFIER_KEY)
//        }
//        if let customIdentifier = person[CUSTOM_IDENTIFIER_KEY] as? String {
//            data.setValue(customIdentifier, forKeyPath: CUSTOM_IDENTIFIER_KEY)
//        }
//        let isMe = person[IS_ME_KEY] as? Bool ?? false
//        data.setValue(isMe, forKeyPath: IS_ME_KEY)
//
//        if let nameDetails = person[NAME_KEY] as? [String:String] {
//            let nameDetailsData = NSData()
//
//            for key in nameDetails.keys {
//                nameDetailsData.setValue(nameDetails[key], forKeyPath: key)
//            }
//
//            data.setValue(nameDetailsData, forKeyPath: NAME_KEY)
//        } else if let name = person[NAME_KEY] as? String {
//            data.setValue(name, forKeyPath: NAME_KEY)
//        }
//
//        if let imageUrl = person[IMAGE_KEY] as? String {
//            data.setValue(imageUrl, forKeyPath: IMAGE_KEY)
//        } else if let imageSource = person[IMAGE_KEY] {
//            // Learn how to handle later
//        }
//
//        return data
//    }

    func dispatchEvent(with data: [String:String], and extraData: [String:Any]?) {
        guard hasListeners else { return }

        var finalData = data as [String:Any]
        if (extraData != nil) {
            finalData[EXTRA_DATA_KEY] = extraData
        }
        if let shareIntent = userDefaults.object(forKey: USER_DEFAULTS_SHARE_INTENT_KEY) as? Data {
            do {
                let decoded = try JSONSerialization.jsonObject(with: shareIntent) as? [String:Any]
                finalData[INTENT_DATA_KEY] = decoded
            } catch {
                print("Error: \(COULD_NOT_LOAD_INTENT_DATA_ERROR)")
            }
        }
        
        sendEvent(withName: NEW_SHARE_EVENT, body: finalData)
    }
}
