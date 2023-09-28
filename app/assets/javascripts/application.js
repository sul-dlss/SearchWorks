// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3

//= require rails-ujs
//= require turbolinks
//= require responsiveTruncator
//= require trunk8
//= require jquery-scrollspy
//= require leaflet
//= require bootstrap/tab
//
// Required by Blacklight
//= require bootstrap/tooltip
//= require popper
//= require bootstrap
//= require blacklight/blacklight

// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'

//= require_tree .

// Prevent the back-button from trying to add a second instance of recaptcha
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbolinks:before-cache", function () {
  // On the articles page there is a feedback and a connection form.
  // Both have a recaptcha that needs clearing.
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "");
});
