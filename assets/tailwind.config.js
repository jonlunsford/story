// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration


module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      width: {
        "680px": "680px",
        "815px": "815px",
        "800px": "800px",
        "46": "46rem",
        "41": "41rem",
        "85%": "85%"
      }
    }
  },
  daisyui: {
    themes: ["light"],
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/line-clamp'),
    require('daisyui'),
  ]
}
