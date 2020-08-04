/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */
import React, {useState, useEffect, useCallback} from 'react';
import {
  StyleSheet,
  Text,
  View,
  Image,
  Button,
  Alert,
  StatusBar,
} from 'react-native';
import ShareMenu from 'react-native-share-menu';

import Recipient from './src/components/Recipient';

type SharedItem = {
  mimeType: string,
  data: string,
};

const App: () => React$Node = () => {
  const [sharedData, setSharedData] = useState('');
  const [sharedMimeType, setSharedMimeType] = useState('');
  const [sharedExtraData, setSharedExtraData] = useState(null);
  const [sharedIntentData, setSharedIntentData] = useState(null);

  const handleShare = useCallback((item: ?SharedItem) => {
    if (!item) {
      return;
    }

    const {mimeType, data, extraData, intentData} = item;

    setSharedData(data);
    setSharedExtraData(extraData);
    setSharedMimeType(mimeType);
    setSharedIntentData(intentData);
  }, []);

  const donate = useCallback(async () => {
    try {
      await ShareMenu.donateShareIntent({
        groupName: 'The Doe Family',
        conversationId: 'doeFamilyGroup',
        recipients: [
          {
            handle: '00000000',
            handleType: 'phone',
            name: {
              prefix: 'Ms.',
              givenName: 'Jane',
              familyName: 'Doe',
            },
            image: 'https://i.pravatar.cc/300',
          },
          {
            handle: 'john@doe.com',
            handleType: 'email',
            name: 'John Doe',
            image: require('./assets/johndoe.jpeg'),
          },
        ],
      });
      Alert.alert(
        'Donated Contact',
        'Try sharing from another app directly to this contact',
      );
    } catch (err) {
      console.error(err);
    }
  }, []);

  useEffect(() => {
    ShareMenu.getInitialShare(handleShare);
  }, []);

  useEffect(() => {
    const listener = ShareMenu.addNewShareListener(handleShare);

    return () => {
      listener.remove();
    };
  }, []);

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <Text style={styles.welcome}>React Native Share Menu</Text>
      <Text style={styles.instructions}>Shared type: {sharedMimeType}</Text>
      <Text style={styles.instructions}>
        Shared text: {sharedMimeType === 'text/plain' ? sharedData : ''}
      </Text>
      <Text style={styles.instructions}>Shared image:</Text>
      {sharedMimeType.startsWith('image/') && (
        <Image
          style={styles.image}
          source={{uri: sharedData}}
          resizeMode="contain"
        />
      )}
      <Text style={styles.instructions}>
        Shared file:{' '}
        {sharedMimeType !== 'text/plain' && !sharedMimeType.startsWith('image/')
          ? sharedData
          : ''}
      </Text>
      <Text style={styles.instructions}>
        Extra data: {sharedExtraData ? JSON.stringify(sharedExtraData) : ''}
      </Text>
      <Button title="Donate Contact" onPress={donate} />
      {!!sharedIntentData && (
        <>
          <Text style={styles.welcome}>Intent Data</Text>
          <Text style={styles.instructions}>
            Group Name: {sharedIntentData.groupName}
          </Text>
          <Text style={styles.instructions}>
            Conversation ID: {sharedIntentData.conversationId}
          </Text>
          <Text style={styles.instructions}>Recipients:</Text>
          {sharedIntentData.recipients?.map(({name, image, handle}) => {
            return <Recipient key={handle} name={name} image={image} />;
          })}
        </>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  image: {
    width: '100%',
    height: 200,
  },
});

export default App;
