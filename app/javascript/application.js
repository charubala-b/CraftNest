import "@hotwired/turbo-rails"
import "controllers"

import "chart.js"                      // ✅ just import for side effects (Chart is global)
import "chartjs-adapter-date-fns"     // ✅ same here
import "chartkick"                     // ✅ chartkick expects global Chart

// ✅ Make Chart globally available for Chartkick
window.Chart = Chart;

document.addEventListener("DOMContentLoaded", () => {
  const flashMessages = document.querySelectorAll('.flash');
  flashMessages.forEach(flash => {
    setTimeout(() => {
      flash.style.display = 'none';
    }, 3000);
  });
});
