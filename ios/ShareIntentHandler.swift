//
//  ShareIntentHandler.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 05/08/2020.
//

protocol ShareIntentHandler {
    var userDefaults: UserDefaults { get }
    
    var savedShareIntents: [[String:Any]] { get }
}

extension ShareIntentHandler {
    var savedShareIntents: [[String:Any]]
    {
        get {
            if let intents = userDefaults.object(forKey: USER_DEFAULTS_SHARE_INTENTS_KEY) as? Data {
                do {
                    return try JSONSerialization.jsonObject(with: intents) as? [[String:Any]] ?? []
                } catch {
                    print("Error: \(COULD_NOT_LOAD_INTENT_DATA_ERROR)")
                }
            }
            
            return []
        }
    }
}
