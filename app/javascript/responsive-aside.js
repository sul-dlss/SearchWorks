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
    const sidebar = document.querySelector('.sidebar')

    if (!aside || !aside.checkVisibility ) return

    const currentState = {
      asideVisible: aside.checkVisibility()
    }

    const stateChanged = !lastState ||
                        currentState.asideVisible !== lastState.asideVisible

    if (stateChanged) {
      lastState = currentState

      if (currentState.asideVisible) {
        reparentAltCatalog(aside)
      } else {
        reparentAltCatalog(sidebar)
      }
    }
  }

  function reparentAltCatalog(parent) {
    const altCatalog = document.querySelector('.responsive-aside')
    if (altCatalog)
      parent.appendChild(altCatalog)
  }
})();
