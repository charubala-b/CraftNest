// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@rails/ujs" // ✅ Rails UJS attaches itself globally
Rails.start()
document.addEventListener("DOMContentLoaded", () => {
  const flashMessages = document.querySelectorAll('.flash');
  flashMessages.forEach(flash => {
    setTimeout(() => {
      flash.style.display = 'none';
    }, 3000); // 3 seconds
  });
});
