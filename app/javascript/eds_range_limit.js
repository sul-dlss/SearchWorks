const EdsRangeLimit = {
  init: function(el) {
    var $el = $(el);
    var data = $el.data();
    var $begin = $el.find('input.range_begin');
    var $end = $el.find('input.range_end');
    var min = data.edsDateMin;
    var max = data.edsDateMax;
    var begin = data.edsDateBegin; 
    var end = data.edsDateEnd;
    var $target = $($el.find('.eds-slider')[0]);
    
    // Much of this is a copy from BlacklightRangeLimit so that the experience
    // stays consistant
    var placeholder_input = $('<input type="text" data-slider-placeholder="true" style="width:100%;">').appendTo($target);

    if (placeholder_input.slider !== undefined) {
      placeholder_input.slider({
        min: data.edsDateMin,
        max: data.edsDateMax,
        value: [begin, end],
        tooltip: 'hide'
      });
    }

    // Update css to 100%
    $target.find('.slider').css('width', '100%');
    
    $begin.val(begin);
    $end.val(end);

    // Handle slider changes
    placeholder_input.slider().on('slide', function(e) {
      $begin.val(e.value[0])
      $end.val(e.value[1])
    });

    // Handle when form updates
    $begin.change(function() {
      var val = BlacklightRangeLimit.parseNum($(this).val());
      if ( isNaN(val)  || val < min) {
        //for weird data, set slider at min           
        val = min;
      }
      var values = placeholder_input.data('slider').getValue();
      values[0] = val;
      placeholder_input.slider('setValue', values);
    });

    $end.change(function() {
      var val = BlacklightRangeLimit.parseNum($(this).val());
      if ( isNaN(val)  || val > max) {
        //for weird data, set slider at max           
        val = max;
      }
      var values = placeholder_input.data('slider').getValue();
      values[1] = val;
      placeholder_input.slider('setValue', values);
    });
  }
}

Blacklight.onLoad(function() {
  $('.eds_range_slider').each(function(i, element) {
    EdsRangeLimit.init(element);
  })
});
