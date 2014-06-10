module OpenSeadragon
  def open_seadragon_tile_source
    file_ids.map do |file_id|
      "#{Settings.STACKS_URL}/iiif/#{druid}%2F#{file_id.gsub(/\.jp2$/, '')}/info.json"
    end
  end

  def osd_config
    config = {
      crossOriginPolicy: false,
      zoomInButton:      "osd-zoom-in",
      zoomOutButton:     "osd-zoom-out",
      homeButton:        "osd-home",
      fullPageButton:    "osd-full-page",
      nextButton:        "osd-next",
      previousButton:    "osd-previous"
    }
    if open_seadragon_tile_source.length > 1
      config.merge!(showReferenceStrip:            true,
                    referenceStripPosition:        'OUTSIDE',
                    referenceStripScroll:          'vertical',
                    referenceStripWidth:           100,
                    referenceStripBackgroundColor: 'transparent')
    end
    config
  end
end
