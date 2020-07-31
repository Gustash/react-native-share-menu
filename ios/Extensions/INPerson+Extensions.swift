//
//  INPerson+Extensions.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 31/07/2020.
//

import Intents

@available(iOS 10.0, *)
public extension INPerson {
    @available(iOS 12.0, *)
    convenience init(parse recipient: [String:Any?]) {
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

        self.init(personHandle: INPersonHandle(value: handle, type: handleType),
                  nameComponents: nameComponents,
                  displayName: displayName,
                  image: image,
                  contactIdentifier: contactIdentifier,
                  customIdentifier: customIdentifier,
                  isMe: isMe)
    }
}
