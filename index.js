import { NativeModules, NativeEventEmitter, Image } from "react-native";

const { ShareMenu } = NativeModules;

const EventEmitter = new NativeEventEmitter(ShareMenu);

const NEW_SHARE_EVENT_NAME = "NewShareEvent";

const prepareImage = (image) =>
  typeof image === "number" ? Image.resolveAssetSource(image) : image;

export const ShareMenuReactView = {
  dismissExtension(error = null) {
    NativeModules.ShareMenuReactView.dismissExtension(error);
  },
  openApp() {
    NativeModules.ShareMenuReactView.openApp();
  },
  continueInApp(extraData = null) {
    NativeModules.ShareMenuReactView.continueInApp(extraData);
  },
  data() {
    return NativeModules.ShareMenuReactView.data();
  },
};

export default {
  /**
   * @deprecated Use `getInitialShare` instead. This is here for backwards compatibility.
   */
  getSharedText(callback) {
    this.getInitialShare(callback);
  },
  getInitialShare(callback) {
    ShareMenu.getSharedText(callback);
  },
  addNewShareListener(callback) {
    const subscription = EventEmitter.addListener(
      NEW_SHARE_EVENT_NAME,
      callback
    );

    return subscription;
  },
  donateShareIntent(options) {
    const transformedOptions = {
      ...options,
      image: prepareImage(options.image),
      recipients: options.recipients?.map(({ image, ...recipient }) => ({
        ...recipient,
        image: prepareImage(image),
      })),
      sender: options.sender
        ? {
            ...options.sender,
            image: prepareImage(options.sender.image),
          }
        : null,
    };

    return ShareMenu.donateShareIntent(transformedOptions);
  },
};
