import Blacklight from 'blacklight-frontend'

Blacklight.onLoad(() => {
  const fullText = document.querySelector('#toggleFulltext')
  fullText?.addEventListener('show.bs.collapse', () => {
    document.querySelector('#fulltextToggleBar').innerHTML = '<h2>Hide full text <i class="bi bi-chevron-down"></i></h2>'
  })
  fullText?.addEventListener('hide.bs.collapse', () => {
    document.querySelector('#fulltextToggleBar').innerHTML = '<h2>Show full text <i class="bi bi-chevron-right"></i></h2>'
  })
})
