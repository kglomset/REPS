const { getDefaultConfig } = require('expo/metro-config');
const { withNativeWind } = require('nativewind/metro');
const path = require('path');

const config = getDefaultConfig(__dirname);

// Force Metro to use CJS (commonjs) builds instead of ESM exports.
// ESM packages use import.meta which Metro's web bundler cannot handle.
config.resolver.unstable_enablePackageExports = false;

// Keep the @/ alias pointing to src/
config.resolver.alias = {
  '@': path.resolve(__dirname, 'src'),
};

module.exports = withNativeWind(config, { input: './src/global.css' });
