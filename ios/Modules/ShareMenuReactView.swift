//
//  ShareMenuReactView.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 28/07/2020.
//

import MobileCoreServices

@objc(ShareMenuReactView)
public class ShareMenuReactView: NSObject, ShareIntentHandler {
    static var viewDelegate: ReactShareViewDelegate?
    let userDefaults: UserDefaults
    
    public override init() {
        let hostAppId = Bundle.main.object(forInfoDictionaryKey: HOST_APP_IDENTIFIER_INFO_PLIST_KEY) as? String
        assert(hostAppId != nil, NO_INFO_PLIST_INDENTIFIER_ERROR)

        let userDefaults = UserDefaults(suiteName: "group.\(hostAppId!)")
        assert(userDefaults != nil, NO_APP_GROUP_ERROR)

        self.userDefaults = userDefaults!
    }
    
    @objc
    static public func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    public static func attachViewDelegate(_ delegate: ReactShareViewDelegate!) {
        guard (ShareMenuReactView.viewDelegate == nil) else { return }
        
        ShareMenuReactView.viewDelegate = delegate
    }
    
    public static func detachViewDelegate() {
        ShareMenuReactView.viewDelegate = nil
    }
    
    @objc(dismissExtension:)
    func dismissExtension(_ error: String?) {
        guard let extensionContext = ShareMenuReactView.viewDelegate?.loadExtensionContext() else {
            print("Error: \(NO_EXTENSION_CONTEXT_ERROR)")
            return
        }

        if error != nil {
            let exception = NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: DISMISS_SHARE_EXTENSION_WITH_ERROR_CODE,
                userInfo: ["error": error!]
            )
            extensionContext.cancelRequest(withError: exception)
            return
        }

        extensionContext.completeRequest(returningItems: [], completionHandler: nil)
    }

    @objc
    func openApp() {
        guard let viewDelegate = ShareMenuReactView.viewDelegate else {
            print("Error: \(NO_DELEGATE_ERROR)")
            return
        }

        viewDelegate.openApp()
    }

    @objc(continueInApp:)
    func continueInApp(_ extraData: [String:Any]?) {
        guard let viewDelegate = ShareMenuReactView.viewDelegate else {
            print("Error: \(NO_DELEGATE_ERROR)")
            return
        }

        let extensionContext = viewDelegate.loadExtensionContext()

        guard let item = extensionContext.inputItems.first as? NSExtensionItem else {
            print("Error: \(COULD_NOT_FIND_ITEM_ERROR)")
            return
        }

        viewDelegate.continueInApp(with: item, and: extraData)
    }
    
    @objc(data:reject:)
    func data(_
            resolve: @escaping RCTPromiseResolveBlock,
            reject: @escaping RCTPromiseRejectBlock) {
        guard let extensionContext = ShareMenuReactView.viewDelegate?.loadExtensionContext() else {
            print("Error: \(NO_EXTENSION_CONTEXT_ERROR)")
            return
        }

        extractDataFromContext(context: extensionContext) { (data, mimeType, error) in
            guard (error == nil) else {
                reject("error", error?.description, nil)
                return
            }
            
            var finalData: [String:Any?] = [MIME_TYPE_KEY: mimeType, DATA_KEY: data]
            
            if let conversationId = self.userDefaults.object(forKey: USER_DEFAULTS_CONVERSATION_ID_KEY) as? String,
               let shareIntent = self.savedShareIntents.first(where: { $0[CONVERSATION_ID_KEY] as! String == conversationId }) {
                finalData[INTENT_DATA_KEY] = shareIntent
            }
            
            resolve(finalData)
        }
    }
    
    func extractDataFromContext(context: NSExtensionContext, withCallback callback: @escaping (String?, String?, NSException?) -> Void) {
        let item:NSExtensionItem! = context.inputItems.first as? NSExtensionItem
        let attachments:[NSItemProvider]! = item.attachments
        
        if let provider = attachments.first {
            if provider.isURL {
                provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (item, error) in
                    let url: URL! = item as? URL

                    callback(url.absoluteString, "text/plain", nil)
                }
            } else if provider.isFileURL {
                provider.loadItem(forTypeIdentifier: kUTTypeData as String, options: nil) { (item, error) in
                    let url: URL! = item as? URL

                    callback(url.absoluteString, self.extractMimeType(from: url), nil)
                }
            } else {
                provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (item, error) in
                    let text:String! = item as? String

                    callback(text, "text/plain", nil)
                }
            }
        } else {
            callback(nil, nil, NSException(name: NSExceptionName(rawValue: "Error"), reason:"couldn't find provider", userInfo:nil))
        }
    }
    
    func extractMimeType(from url: URL) -> String {
      let fileExtension: CFString = url.pathExtension as CFString
      guard let extUTI = UTTypeCreatePreferredIdentifierForTag(
              kUTTagClassFilenameExtension,
              fileExtension,
              nil
      )?.takeUnretainedValue() else { return "" }

      guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType)
      else { return "" }

      return mimeUTI.takeUnretainedValue() as String
    }
}
