/*
 * Responsive Truncator Plugin (Vanilla JS)
 *
 * Converted from jQuery plugin to vanilla JavaScript
 * Original: https://github.com/jkeck/responsiveTruncator
 *
 * VERSION 0.1.0
 *
**/

class ResponsiveTruncator {
  constructor(element, options = {}) {
    this.element = element;
    this.settings = Object.assign({
      'lines': 3,
      'height': null,
      'more': 'more',
      'less': 'less'
    }, options);

    this.init();
  }

  init() {
    // Bind resize event
    window.addEventListener('resize', () => {
      this.removeTruncation();
      this.addTruncation();
    });

    this.addTruncation();
  }

  addTruncation() {
    if (this.element.querySelector('.responsiveTruncate')) {
      return; // Already truncated
    }

    const parent = this.element;
    const computedStyle = window.getComputedStyle(parent);
    const fontSize = computedStyle.fontSize;
    const lineHeight = computedStyle.lineHeight !== 'normal'
      ? parseFloat(computedStyle.lineHeight.replace('px', ''))
      : Math.floor(parseInt(fontSize.replace('px', '')) * 1.5);

    let truncateHeight;
    if (this.settings.height) {
      truncateHeight = this.settings.height;
    } else {
      truncateHeight = (lineHeight * this.settings.lines);
    }

    if (parent.offsetHeight > truncateHeight) {
      const origContent = parent.innerHTML;

      // Create truncate container
      const truncateDiv = document.createElement('div');
      truncateDiv.className = 'responsiveTruncate';
      truncateDiv.style.height = truncateHeight + 'px';
      truncateDiv.style.overflow = 'hidden';
      truncateDiv.innerHTML = origContent;

      // Create toggle link
      const toggleLink = document.createElement('a');
      toggleLink.className = 'responsiveTruncatorToggle';
      toggleLink.href = '#';
      toggleLink.textContent = this.settings.more;

      // Clear parent and add new elements
      parent.innerHTML = '';
      parent.appendChild(truncateDiv);
      parent.appendChild(toggleLink);

      // Re-initialize popovers if they exist
      const popoverElements = parent.querySelectorAll('[data-bs-toggle="popover"]');
      popoverElements.forEach(elem => {
        if (typeof bootstrap !== 'undefined' && bootstrap.Popover) {
          new bootstrap.Popover(elem);
        }
      });

      // Add click handler to toggle link
      toggleLink.addEventListener('click', (e) => {
        e.preventDefault();
        const text = toggleLink.textContent === this.settings.more ? this.settings.less : this.settings.more;
        toggleLink.textContent = text;

        if (truncateDiv.style.height === truncateHeight + 'px') {
          truncateDiv.style.height = '100%';
        } else {
          truncateDiv.style.height = truncateHeight + 'px';
        }

        return false;
      });
    }
  }

  removeTruncation() {
    const truncateElement = this.element.querySelector('.responsiveTruncate');
    if (truncateElement) {
      const content = truncateElement.innerHTML;
      this.element.innerHTML = content;

      // Re-initialize popovers if they exist
      const popoverElements = this.element.querySelectorAll('[data-bs-toggle="popover"]');
      popoverElements.forEach(elem => {
        if (typeof bootstrap !== 'undefined' && bootstrap.Popover) {
          new bootstrap.Popover(elem);
        }
      });
    }
  }
}

// Add method to HTMLElement prototype for easy usage
HTMLElement.prototype.responsiveTruncate = function(options) {
  if (!this._responsiveTruncator) {
    this._responsiveTruncator = new ResponsiveTruncator(this, options);
  }
  return this;
};

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ResponsiveTruncator;
}
