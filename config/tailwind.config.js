const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  daisyui: {
    themes: ["cupcake"],
  },
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: 'var(--color-primary)',
          50: 'var(--color-primary-50)',
          100: 'var(--color-primary-100)',
          200: 'var(--color-primary-200)',
          300: 'var(--color-primary-300)',
          400: 'var(--color-primary-400)',
          500: 'var(--color-primary-500)',
          600: 'var(--color-primary-600)',
          700: 'var(--color-primary-700)',
          800: 'var(--color-primary-800)',
          900: 'var(--color-primary-900)',
        },
        gray100: 'var(--color-gray-100)',
        gray200: 'var(--color-gray-200)',
        gray300: 'var(--color-gray-300)',
        gray400: 'var(--color-gray-400)',
        gray500: 'var(--color-gray-500)',
        gray600: 'var(--color-gray-600)',
        gray700: 'var(--color-gray-700)',
        gray800: 'var(--color-gray-800)',
        gray900: 'var(--color-gray-900)',
        gray950: 'var(--color-gray-950)',
      },
    },
  },
  plugins: [require('daisyui')],
}

