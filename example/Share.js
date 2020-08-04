import React, {useEffect, useState} from 'react';
import {View, Text, Pressable, Image, StyleSheet} from 'react-native';
import {ShareMenuReactView} from 'react-native-share-menu';

import Recipient from './src/components/Recipient';

const Button = ({onPress, title, style}) => (
  <Pressable onPress={onPress}>
    <Text style={[{fontSize: 16, margin: 16}, style]}>{title}</Text>
  </Pressable>
);

const Share = () => {
  const [sharedData, setSharedData] = useState('');
  const [sharedMimeType, setSharedMimeType] = useState('');
  const [sharedIntentData, setSharedIntentData] = useState(null);
  const [sending, setSending] = useState(false);

  useEffect(() => {
    ShareMenuReactView.data().then(({mimeType, data, intentData}) => {
      setSharedData(data);
      setSharedMimeType(mimeType);
      setSharedIntentData(intentData);
    });
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Button
          title="Dismiss"
          onPress={() => {
            ShareMenuReactView.dismissExtension();
          }}
          style={styles.destructive}
        />
        <Button
          title={sending ? 'Sending...' : 'Send'}
          onPress={() => {
            setSending(true);

            setTimeout(() => {
              ShareMenuReactView.dismissExtension();
            }, 3000);
          }}
          disabled={sending}
          style={sending ? styles.sending : styles.send}
        />
      </View>
      {sharedMimeType === 'text/plain' && <Text>{sharedData}</Text>}
      {sharedMimeType.startsWith('image/') && (
        <Image
          style={styles.image}
          resizeMode="contain"
          source={{uri: sharedData}}
        />
      )}
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
      <View style={styles.buttonGroup}>
        <Button
          title="Dismiss with Error"
          onPress={() => {
            ShareMenuReactView.dismissExtension('Dismissed with error');
          }}
          style={styles.destructive}
        />
        <Button
          title="Continue In App"
          onPress={() => {
            ShareMenuReactView.continueInApp();
          }}
        />
        <Button
          title="Continue In App With Extra Data"
          onPress={() => {
            ShareMenuReactView.continueInApp({hello: 'from the other side'});
          }}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  destructive: {
    color: 'red',
  },
  send: {
    color: 'blue',
  },
  sending: {
    color: 'grey',
  },
  image: {
    width: '100%',
    height: 200,
  },
  buttonGroup: {
    alignItems: 'center',
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
});

export default Share;
