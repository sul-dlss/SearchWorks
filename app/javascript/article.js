import Blacklight from 'blacklight-frontend'

Blacklight.onLoad(() => {
  const fullText = document.querySelector('#toggleFulltext')
  fullText?.addEventListener('show.bs.collapse', () => {
    document.querySelector('#fulltextToggleBar h2').innerHTML = 'Hide full text <i class="bi bi-chevron-down"></i>'
  })
  fullText?.addEventListener('hide.bs.collapse', () => {
    document.querySelector('#fulltextToggleBar h2').innerHTML = 'Show full text <i class="bi bi-chevron-right"></i>'
  })
})
