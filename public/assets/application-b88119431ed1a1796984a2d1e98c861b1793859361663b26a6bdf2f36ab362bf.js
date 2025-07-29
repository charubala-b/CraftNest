// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import Chart from "chart.js";
import adapter from "chartjs-adapter-date-fns";
import "chartkick";

// 👇 register adapter manually
Chart.register(...Object.values(adapter));

// 👇 expose Chart globally for Chartkick
window.Chart = Chart;


document.addEventListener("DOMContentLoaded", () => {
  const flashMessages = document.querySelectorAll('.flash');
  flashMessages.forEach(flash => {
    setTimeout(() => {
      flash.style.display = 'none';
    }, 3000); // 3 seconds
  });
});
import "enums";

