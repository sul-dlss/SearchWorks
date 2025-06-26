(() => {
  window.addEventListener('resize', handleResponsiveAside);
  document.addEventListener('turbo:load', resetAndHandleResponsiveAside);
  document.addEventListener('DOMContentLoaded', resetAndHandleResponsiveAside);


  let lastAsideVisibility = false

  function resetAndHandleResponsiveAside() {
    lastAsideVisibility = false
    handleResponsiveAside();
  }

  function handleResponsiveAside() {
    const aside = document.getElementById('modules-aside')

    if (aside === null || aside.checkVisibility === undefined) return

    const newVisibility = aside.checkVisibility()

    if (newVisibility !== lastAsideVisibility) {
      lastAsideVisibility = newVisibility

      if (newVisibility) {
        reparentAsideModules(aside)
      } else {
        reparentAsideModules(document.querySelector('.sidebar'));
      }
    }
  };

  function reparentAsideModules(parent) {
    document.querySelector('.alternate-catalog')?.forEach(el => parent.appendChild(el))
  }
})();
