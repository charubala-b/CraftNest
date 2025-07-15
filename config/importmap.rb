# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap" # @5.3.7
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "@rails/ujs", to: "rails-ujs.js"

pin "enums", to: "enums.js"
pin_all_from "app/javascript/modifiers", under: "modifiers"

pin "chartkick", to: "chartkick.js"
pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js"
pin "chartjs-adapter-date-fns", to: "https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3.0.0/dist/chartjs-adapter-date-fns.bundle.min.js"
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4
