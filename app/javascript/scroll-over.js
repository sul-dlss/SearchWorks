// Scroll to the current document
export default function(element, gallery) {
  const galleryWidth = gallery.offsetWidth
  const elementWidth = element.offsetWidth

  // Get the element's position relative to its offsetParent.
  let left = 0
  let currentElement = element
  while (currentElement) {
    left += currentElement.offsetLeft
    currentElement = currentElement.offsetParent
  }

  const scrollAmount = left - galleryWidth / 2 + elementWidth / 2
  element.classList.add('current-document')

  gallery.scrollTo({ left: scrollAmount })
}
