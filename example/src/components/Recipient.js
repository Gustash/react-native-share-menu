import React from 'react';
import {StyleSheet, Text, View, Image} from 'react-native';

const Recipient = ({name, image}) => {
  return (
    <View style={styles.container}>
      <Image style={styles.image} source={{uri: image}} />
      <Text style={styles.text}>
        {typeof name === 'object'
          ? `${name.prefix} ${name.givenName} ${name.familyName}`
          : name}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 4,
  },
  image: {
    width: 48,
    height: 48,
    borderRadius: 24,
    marginRight: 16,
  },
  text: {
    flex: 1,
  },
});

export default Recipient;
