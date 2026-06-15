/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}", "./app/**/*.{js,jsx,ts,tsx}"],
  darkMode: 'class',
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#4F46E5",
          light: "#818CF8",
          dark: "#3730A3",
        },
        surface: {
          DEFAULT: "#FFFFFF",
          muted: "#F9FAFB",
          subtle: "#F3F4F6",
        },
        text: {
          primary: "#111827",
          secondary: "#6B7280",
          muted: "#9CA3AF",
          inverse: "#FFFFFF",
        },
        accent: {
          green: "#10B981",
          red: "#EF4444",
          yellow: "#F59E0B",
        },
      },
      fontFamily: {
        sans: ["Inter_400Regular", "System"],
        medium: ["Inter_500Medium", "System"],
        semibold: ["Inter_600SemiBold", "System"],
        bold: ["Inter_700Bold", "System"],
      },
    },
  },
};
