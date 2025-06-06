Blacklight.onLoad(function() {
  // Initialize recent selections functionality
  initRecentSelections();
});

/**
 * Recent selections functionality
 *
 * This module:
 * - Listens for the selections dropdown to be activated
 * - Makes a fetch request to /recent_selections
 * - Updates the list with returned HTML
 */
function initRecentSelections() {
  // Find all elements with the recent-selections behavior
  const selectionElements = document.querySelectorAll('[data-behavior="recent-selections"]');

  selectionElements.forEach(element => {
    const url = element.dataset.url
    element.addEventListener('show.bs.dropdown', () => {
      getRecentSelections(url, element)
    })
  })
}

/**
 * Fetch recent selections from the server
 *
 * @param {string} url - The URL to fetch recent selections from
 * @param {HTMLElement} element - The dropdown element
 */
function getRecentSelections(url, element) {
  fetch(url, {
    method: 'GET',
    headers: {
      'Accept': 'text/html'
    }
  })
  .then(response => response.text())
  .then(html => {
    updateLinks(html);
    updateList(html);

    // Dispatch custom event to notify that selections were updated
    const event = new CustomEvent('updated.selections.dropdown');
    element.dispatchEvent(event);
  })
  .catch(error => {
    console.error('Error fetching recent selections:', error);
  });
}

/**
 * Update the clear list link based on whether there are selections
 *
 * @param {string} html - The HTML content returned from the server
 */
function updateLinks(html) {
  const clearListButton = document.getElementById('clear-list');
  if (!clearListButton) return;

  if (html.trim() === '') {
    clearListButton.classList.add('disabled');
  } else {
    clearListButton.classList.remove('disabled');
  }
}

/**
 * Update the list of recent selections
 *
 * @param {string} html - The HTML content returned from the server
 */
function updateList(html) {
  const showList = document.getElementById('show-list');
  if (!showList) return;

  // Remove existing added list items
  const addedListItems = showList.querySelectorAll('[data-attribute="added-list"]');
  addedListItems.forEach(item => item.remove());

  // Insert the new HTML at the beginning of the list
  showList.insertAdjacentHTML('afterbegin', html);
}
