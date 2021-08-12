
// takes a string and parses into an integer, but throws away commas first, to avoid truncation when there is a comma
// use in place of javascript's native parseInt
!function(global) {
  'use strict';

  var previousBlacklightRangeLimit = global.BlacklightRangeLimit;

  function BlacklightRangeLimit(options) {
    this.options = options || {};
  }

  BlacklightRangeLimit.noConflict = function noConflict() {
    global.BlacklightRangeLimit = previousBlacklightRangeLimit;
    return BlacklightRangeLimit;
  };

  BlacklightRangeLimit.parseNum = function parseNum(str) {
    str = String(str).replace(/[^0-9]/g, '');
    return parseInt(str, 10);
  };

  global.BlacklightRangeLimit = BlacklightRangeLimit;
}(this);