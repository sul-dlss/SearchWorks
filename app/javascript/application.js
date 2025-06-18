// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.addEventListener('resize', handleResponsiveAside);
document.addEventListener('turbo:load', resetAndHandleResponsiveAside);
document.addEventListener('DOMContentLoaded', resetAndHandleResponsiveAside);


let lastAsideVisibility = false;

function resetAndHandleResponsiveAside() {
  lastAsideVisibility = false;
  handleResponsiveAside();
}

function handleResponsiveAside() {
  const aside = document.getElementById('modules-aside');

  if (aside === undefined || aside.checkVisibility === undefined) return;

  const newVisibility = aside.checkVisibility();

  if (newVisibility !== lastAsideVisibility) {
    lastAsideVisibility = newVisibility;

    if (newVisibility) {
      reparentAsideModules('modules-aside');
    } else {
      reparentAsideModules('modules');
    }
  }
};

function reparentAsideModules(parentId) {
  const els = [
    document.getElementById('library_website_api_module'),
    document.getElementById('lib_guides_module'),
    document.getElementById('specialist-main')
  ];

  els.forEach((el) => {
    document.getElementById(parentId).appendChild(el);
  })
}
