Blacklight.onLoad(() => {
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  popoverTriggerList.forEach(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))
});
