import L from "leaflet"
import fetchJsonp from 'fetch-jsonp';

(function() {
  function stackMap(element) {
    const container = element
    const stackMapApiUrl = container.dataset.stackmapUrl
    const location = container.dataset.location
    const tplMap = container.querySelector(".map-template")

    const params = {
      "callno": container.dataset.callnumber,
      "library": container.dataset.library,
      "location": location
    }

    const queryString = Object.keys(params)
      .map(key => encodeURIComponent(key) + '=' + encodeURIComponent(params[key]))
      .join('&')

    fetchJsonp(stackMapApiUrl + '?' + queryString)
      .then(response => response.json())
      .then(response => {
        if (response.stat === "OK" && response.results.maps.length > 0) {
          plugContent(response)
        } else {
          container.innerHTML = '<p>No map available for this item</p>'
        }
      })

    function plugContent(data) {
      const maps = data.results.maps

      container.querySelector(".callnumber").textContent = data.results.callno

      maps.forEach((map, index) => {
        const tpl = tplMap.cloneNode(true)
        const zoomControls = tpl.querySelector(".zoom-controls")

        container.querySelector(".library").textContent = map.library
        container.querySelector(".floorname").textContent = map.floorname

        tpl.querySelector(".osd").id = 'osd-' + index
        tpl.querySelector(".text-directions").innerHTML = map.directions

        const zoomIn = tpl.querySelector(".zoom-in")
        const zoomOut = tpl.querySelector(".zoom-out")
        const zoomFit = tpl.querySelector(".zoom-fit")

        zoomIn.id = 'zoom-in-' + index
        zoomOut.id = 'zoom-out-' + index
        zoomFit.id = 'zoom-fit-' + index

        tplMap.replaceWith(tpl)
        addOsd(map, index, zoomControls)
        attachEvents(container, index)
      })
    }

    function addOsd(map, index, zoomControls) {
      const viewer = L.map('osd-' + index, {
        crs: L.CRS.Simple,
        minZoom: -2,
        zoomControl: false,
        attributionControl: false
      })
      const bounds = [[0, 0], [map.height, map.width]]
      L.imageOverlay(
        map.mapurl + '&marker=1&type=.png',
        bounds
      ).addTo(viewer)
      viewer.fitBounds(bounds)

      zoomControls.querySelector('.zoom-in').addEventListener('click', function(e) {
        e.preventDefault()
        viewer.zoomIn()
      })
      zoomControls.querySelector('.zoom-out').addEventListener('click', function(e) {
        e.preventDefault()
        viewer.zoomOut()
      })
      zoomControls.querySelector('.zoom-fit').addEventListener('click', function(e) {
        e.preventDefault()
        viewer.fitBounds(bounds)
      })
    }

    function attachEvents(container, index) {
      container.querySelectorAll('[data-action="reveal-text-directions"]').forEach(button => {
        button.addEventListener('click', (e) => {
          const textSwap = button.querySelector('.text-swap')
          const stackmap = button.closest('.map-template')
          const osd = stackmap.querySelector('.osd')
          const textDirections = stackmap.querySelector('.text-directions')
          const zoomControls = stackmap.querySelector('.zoom-controls')

          if (/show/i.test(textSwap.textContent)) {
            textSwap.textContent = 'Hide'
            osd.style.display = 'none'
            zoomControls.style.visibility = 'hidden'
            textDirections.style.display = 'block'
          } else {
            textSwap.textContent = 'Show'
            osd.style.display = 'block'
            zoomControls.style.visibility = 'visible'
            textDirections.style.display = 'none'
          }

          e.preventDefault()
        })
      })
    }
  }

  Blacklight.onLoad(() => {
    document.querySelectorAll('[data-behavior=stackmap]').forEach(element => {
      stackMap(element)
    })

    document.addEventListener('show.blacklight.blacklight-modal', () => {
      document.querySelectorAll('[data-behavior=stackmap]').forEach(element => {
        stackMap(element)
      })
    })
  })
})()
