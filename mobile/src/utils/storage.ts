import { Platform } from 'react-native';

/**
 * Cross-platform key-value storage.
 * Uses localStorage on web, expo-secure-store on native (iOS/Android).
 * expo-secure-store is imported dynamically to avoid crashing on web.
 */
export const storage = {
  async getItem(key: string): Promise<string | null> {
    if (Platform.OS === 'web') {
      return typeof localStorage !== 'undefined' ? localStorage.getItem(key) : null;
    }
    const SecureStore = await import('expo-secure-store');
    return SecureStore.getItemAsync(key);
  },

  async setItem(key: string, value: string): Promise<void> {
    if (Platform.OS === 'web') {
      if (typeof localStorage !== 'undefined') localStorage.setItem(key, value);
      return;
    }
    const SecureStore = await import('expo-secure-store');
    return SecureStore.setItemAsync(key, value);
  },

  async deleteItem(key: string): Promise<void> {
    if (Platform.OS === 'web') {
      if (typeof localStorage !== 'undefined') localStorage.removeItem(key);
      return;
    }
    const SecureStore = await import('expo-secure-store');
    return SecureStore.deleteItemAsync(key);
  },
};
