# frozen_string_literal: true

class StanfordOnlyIconComponent < ViewComponent::Base
  def d
    'M4.0761718,8.29784937 C4.0761718,6.99023343 5.47265485,6 6.78027079,6 C7.52929351,6 8.11327733,6.19042951 8.91308125,6.35546841 C8.98925305,7.02831933 9.05272956,' \
      '7.67577965 9.05272956,8.46288828 C9.01464366,8.55175538 8.91308125,8.58984128 8.86230005,8.58984128 C8.72265175,8.58984128 8.49413634,8.60253658 8.46874574,' \
      '8.50097418 C8.36718334,7.79003736 7.77050422,6.71093682 6.79296609,6.71093682 C6.29784937,6.71093682 5.76464675,6.97753813 5.76464675,7.82812326 C5.76464675,' \
      '8.61523188 6.76757549,9.1865204 7.60546531,9.71972302 C8.45605044,10.2656209 9.47167447,10.5956987 9.47167447,12.2841737 C9.47167447,13.6806567 8.10058203,' \
      '14.6328043 6.70409898,14.6328043 C5.95507626,14.6328043 5.05370993,14.4804607 4.29199191,14.3027265 C4.1396483,13.7314379 4,12.550775 4,12.1953066 C4.0253906,' \
      '12.1191348 4.16503891,12.0683536 4.22851541,12.0683536 C4.35546841,12.0683536 4.62206972,12.042963 4.63476502,12.1445254 C4.74902272,12.8300716 5.51074075,' \
      '13.9091721 6.45019298,13.9091721 C7.1611298,13.9091721 7.70702771,13.5410084 7.70702771,12.5253844 C7.70702771,11.7636664 6.56445068,11.1923779 5.92968566,' \
      '10.7607376 C5.00292873,10.1386679 4.0761718,9.61816061 4.0761718,8.29784937 Z'
  end

  def call
    tag.svg(class: 'stanford-only', aria: { label: 'stanford only' }, width: '13px', height: '13px', viewBox: '0 0 13 13') do
      tag.g(stroke: 'none', stroke_width: 1, fill: 'none', fill_rule: 'evenodd') do
        tag.g(transform: 'translate(-1.000000, -1.000000)') do
          tag.g(id: 'stanford-only', transform: 'translate(1.000000, -3.000000)') do
            tag.rect(id: 'Rectangle', fill: '#8F1911', x: '0', y: '4', width: '13', height: '13', rx: '4') +
              tag.path(d:, id: 'S', fill: '#FFFFFF')
          end
        end
      end
    end
  end
end
