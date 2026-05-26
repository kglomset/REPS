import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, ScrollView,
  KeyboardAvoidingView, Platform, ActivityIndicator,
} from 'react-native';
import { router } from 'expo-router';
import { useAuthStore } from '@/store/useAuthStore';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';
import { Ionicons } from '@expo/vector-icons';

type Mode = 'login' | 'register';

export default function LoginScreen() {
  const [mode, setMode] = useState<Mode>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { login } = useAuthStore();

  const clearError = () => { if (error) setError(null); };

  const handleSubmit = async () => {
    setError(null);
    if (!email.trim() || !password) {
      setError('Please enter your email and password.');
      return;
    }
    if (mode === 'register' && !name.trim()) {
      setError('Please enter your name.');
      return;
    }

    setIsLoading(true);
    try {
      if (mode === 'login') {
        await login(email.trim(), password);
        router.replace('/(tabs)/');
      } else {
        // Pass credentials to onboard screen which completes registration
        router.push({
          pathname: '/(auth)/onboard',
          params: { email: email.trim(), password, name: name.trim() },
        });
      }
    } catch (e: any) {
      // Show a friendly inline message for auth failures
      const msg: string = e?.message ?? '';
      if (msg.toLowerCase().includes('401') || msg.toLowerCase().includes('unauthorized')
          || msg.toLowerCase().includes('invalid') || msg.toLowerCase().includes('credentials')) {
        setError('Username or password is incorrect.');
      } else {
        setError(msg || 'Something went wrong. Please try again.');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1, backgroundColor: Colors.surface }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView
        contentContainerStyle={{ flexGrow: 1, padding: Spacing.lg, justifyContent: 'center' }}
        keyboardShouldPersistTaps="handled"
      >
        {/* Logo */}
        <View style={{ alignItems: 'center', marginBottom: Spacing.xxl }}>
          <Text style={{ fontSize: 42, fontWeight: FontWeight.bold, color: Colors.primary,
            letterSpacing: 4 }}>
            REPS
          </Text>
          <Text style={{ fontSize: FontSize.md, color: Colors.textSecondary, marginTop: 6 }}>
            Track every rep. Own your progress.
          </Text>
        </View>

        {/* Mode toggle */}
        <View style={{
          flexDirection: 'row', backgroundColor: Colors.surfaceSubtle,
          borderRadius: Radius.full, padding: 4, marginBottom: Spacing.xl,
        }}>
          {(['login', 'register'] as Mode[]).map((m) => (
            <TouchableOpacity
              key={m}
              onPress={() => { setMode(m); setError(null); }}
              style={{
                flex: 1, paddingVertical: 10, alignItems: 'center',
                borderRadius: Radius.full,
                backgroundColor: mode === m ? Colors.surface : 'transparent',
                ...(mode === m ? Shadow.card : {}),
              }}
            >
              <Text style={{
                fontWeight: mode === m ? FontWeight.semibold : FontWeight.regular,
                color: mode === m ? Colors.textPrimary : Colors.textSecondary,
                fontSize: FontSize.md,
              }}>
                {m === 'login' ? 'Sign In' : 'Create Account'}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Form fields */}
        {mode === 'register' && (
          <Field
            label="Name"
            value={name}
            onChangeText={(v) => { setName(v); clearError(); }}
            placeholder="Your full name"
            autoCapitalize="words"
          />
        )}
        <Field
          label="Email"
          value={email}
          onChangeText={(v) => { setEmail(v); clearError(); }}
          placeholder="you@example.com"
          keyboardType="email-address"
          autoCapitalize="none"
          autoComplete="email"
        />
        <Field
          label="Password"
          value={password}
          onChangeText={(v) => { setPassword(v); clearError(); }}
          placeholder="Min 8 characters"
          secureTextEntry
          autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
        />

        {/* Inline error message */}
        {error && (
          <View style={{
            flexDirection: 'row', alignItems: 'center', gap: 6,
            backgroundColor: Colors.errorTint,
            borderRadius: Radius.md, padding: Spacing.sm,
            marginBottom: Spacing.sm,
          }}>
            <Ionicons name="alert-circle-outline" size={16} color={Colors.error} />
            <Text style={{ flex: 1, fontSize: FontSize.sm, color: Colors.error }}>
              {error}
            </Text>
          </View>
        )}

        <TouchableOpacity
          onPress={handleSubmit}
          disabled={isLoading}
          style={{
            backgroundColor: Colors.primary, borderRadius: Radius.md,
            paddingVertical: 16, alignItems: 'center', marginTop: Spacing.md,
            opacity: isLoading ? 0.7 : 1,
          }}
        >
          {isLoading
            ? <ActivityIndicator color={Colors.textInverse} />
            : <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>
                {mode === 'login' ? 'Sign In' : 'Continue →'}
              </Text>
          }
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

function Field({ label, ...props }: { label: string } & React.ComponentProps<typeof TextInput>) {
  return (
    <View style={{ marginBottom: Spacing.md }}>
      <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.medium,
        color: Colors.textSecondary, marginBottom: 6 }}>{label}</Text>
      <TextInput
        style={{
          backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
          paddingHorizontal: Spacing.md, paddingVertical: 14,
          fontSize: FontSize.md, color: Colors.textPrimary,
          borderWidth: 1, borderColor: Colors.border,
        }}
        placeholderTextColor={Colors.textMuted}
        {...props}
      />
    </View>
  );
}
