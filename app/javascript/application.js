// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Copy library and guides to the sidebar that appears for XL
document.addEventListener('turbo:frame-render', (event) => {
  if (event.target.id === 'library_website_api_module') {
    document.getElementById('webside-aside').innerHTML = event.target.innerHTML
    event.target.classList.add('d-xl-none')
  }
  if (event.target.id === 'lib_guides_module') {
    document.getElementById('guides-aside').innerHTML = event.target.innerHTML
    event.target.classList.add('d-xl-none')
  }
})
