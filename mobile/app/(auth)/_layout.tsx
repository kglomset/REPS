import { Stack, Redirect } from 'expo-router';
import { useAuthStore } from '@/store/useAuthStore';

export default function AuthLayout() {
  const { isAuthenticated, isLoading } = useAuthStore();

  // Already authenticated — send to the app
  if (!isLoading && isAuthenticated) {
    return <Redirect href="/(tabs)/" />;
  }

  return <Stack screenOptions={{ headerShown: false }} />;
}
