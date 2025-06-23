// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
document.addEventListener("DOMContentLoaded", () => {
  const flashMessages = document.querySelectorAll('.flash');
  flashMessages.forEach(flash => {
    setTimeout(() => {
      flash.style.display = 'none';
    }, 3000); // 3 seconds
  });
});
