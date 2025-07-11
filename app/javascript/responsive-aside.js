(() => {
  window.addEventListener('resize', handleResponsiveAside);
  document.addEventListener('turbo:load', resetAndHandleResponsiveAside);
  document.addEventListener('DOMContentLoaded', resetAndHandleResponsiveAside);


  let lastState = null

  function resetAndHandleResponsiveAside() {
    lastState = null
    handleResponsiveAside();
  }

  function handleResponsiveAside() {
    const aside = document.getElementById('modules-aside')
    const miniBentoDrawerBtn = document.querySelector('.mini-bento.btn')
    const miniBentoDrawer = document.getElementById('alternate-catalog-offcanvas')
    const sidebar = document.querySelector('.sidebar')

    if (!aside || !aside.checkVisibility || !miniBentoDrawerBtn || !miniBentoDrawerBtn.checkVisibility) return

    const currentState = {
      asideVisible: aside.checkVisibility(),
      miniBentoSidebarVisible: !miniBentoDrawerBtn.checkVisibility()
    }

    const stateChanged = !lastState ||
                        currentState.asideVisible !== lastState.asideVisible ||
                        currentState.miniBentoSidebarVisible !== lastState.miniBentoSidebarVisible

    if (stateChanged) {
      lastState = currentState

      if (currentState.asideVisible) {
        reparentAltCatalog(aside)
      } else if (currentState.miniBentoSidebarVisible) {
        hideDrawer(miniBentoDrawer)
        reparentAltCatalog(sidebar)
      } else {
        reparentAltCatalog(miniBentoDrawer)
      }
    }
  }

  function reparentAltCatalog(parent) {
    const altCatalog = document.querySelector('.alternate-catalog')
    if (altCatalog)
      parent.appendChild(altCatalog)
  }

  function hideDrawer(drawerElement) {
    const drawer = bootstrap.Offcanvas.getInstance(drawerElement)
    if (drawer)
      drawer.hide()
  }
})();
