Blacklight.onLoad(() => {
  const fullText = document.querySelector('#toggleFulltext')
  fullText?.addEventListener('show.bs.collapse', () => {
    document.querySelector('#fulltextToggleBar').innerHTML = '<h2>Hide full text <i class="fa fa-chevron-down"></i></h2>'
  })
  fullText?.addEventListener('hide.bs.collapse', () => {
    document.querySelector('#fulltextToggleBar').innerHTML = '<h2>Show full text <i class="fa fa-chevron-right"></i></h2>'
  })

  // toggles close icon from plus to X and vice versa
  const starterBody = document.querySelector('#research-starter-body')
  starterBody?.addEventListener('show.bs.collapse', () => {
    const icon = document.querySelector('#research-starter-close-icon')
    icon.classList.remove('fa-times-circle')
    icon.classList.add('fa-plus-circle')
  })
  starterBody?.addEventListener('hide.bs.collapse', () => {
    const icon = document.querySelector('#research-starter-close-icon')
    icon.classList.remove('fa-plus-circle')
    icon.classList.add('fa-times-circle')
  })
})
