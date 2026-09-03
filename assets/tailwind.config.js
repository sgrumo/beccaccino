const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/averziano_web.ex",
    "../lib/averziano_web/**/*.*ex"
  ],
  theme: {
    extend: {
      fontFamily: {
        // Funnel Display for headings, Funnel Sans for everything else.
        display: ["Funnel Display", "Funnel Sans", "ui-sans-serif", "sans-serif"],
        sans: ["Funnel Sans", "-apple-system", "Segoe UI", "sans-serif"],
        mono: ["ui-monospace", "SFMono-Regular", "Menlo", "monospace"]
      },
      colors: {
        // Brand violet ramp: buttons, felt gradient, highlights.
        brand: {
          DEFAULT: "#5E30E6",
          dark: "#4B24BF",
          deep: "#391A99",
          night: "#241C3D",
          light: "#A98EFF"
        },
        // Type and surfaces on light screens (lobby).
        lilac: {DEFAULT: "#C2B0FF", soft: "#DDD2FF"},
        ink: "#1E1E1E",
        paper: "#F7F7F8",
        prose: "#3A3D4F",
        muted: "#71717A",
        inactive: "#8F92A3",
        edge: "#D8D8DD",
        line: "#EDEDED",
        // Neutral placeholder card faces — real artwork replaces these.
        card: {face: "#FFFFFF", weave: "#F2F1F6", picked: "#EDE9FB", edge: "#B9BBC6"},
        // Per-table accent dots in the lobby list.
        table: {blue: "#0759C4", green: "#059669", olive: "#AEBF32"}
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Hero icons
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        try {
          fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
            let name = path.basename(file, ".svg") + suffix
            values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
          })
        } catch (_e) {}
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("googletag.width") || "1.25rem"
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
