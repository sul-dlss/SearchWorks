import { Controller } from "@hotwired/stimulus"
import PreviewContent from '../preview-content'

// Connects to data-controller="gallery-preview"
export default class extends Controller {
  static values = {
    url: String,
    previewSelector: String
  }

  connect() {
    this.$item = $(this.element)
    this.$previewTarget = $(this.previewSelectorValue)

    this.itemWidth = this.$item.outerWidth() + 10
    this.$triggerBtn = this.$item.find('*[data-behavior="preview-button-trigger"]')
    this.$closeBtn = $(`<button type="button" class="preview-close btn-close" aria-label="Close">
    <span aria-hidden="true" class="visually-hidden">×</span>
    </button>`)
    this.$arrow = $('<div class="preview-arrow"></div>')
    this.$gallery = $('.gallery-document')
    this.reorderPreviewDivs()
    $(window).resize(() => this.reorderPreviewDivs())
    this.attachTriggerEvents()
  }

  showPreview() {
    const previewUrl = this.urlValue

    this.$previewTarget.addClass('preview').empty()

    PreviewContent.append(previewUrl, this.$previewTarget)

    this.appendPointer()

    this.$previewTarget.css('display', 'inline-block')

    this.$previewTarget.append(this.$closeBtn).show()

    this.$triggerBtn.html('Close')

    this.attachPreviewEvents()

    this.$triggerBtn.addClass('preview-open')
  }

  clamp(x, min, max) {
    return Math.min(Math.max(x, min), max)
  }

  appendPointer() {
    this.$previewTarget.append(this.$arrow)

    const maxLeft = this.$previewTarget.width() - this.$arrow.width() - 1
    const { left, width } = this.element.getBoundingClientRect()
    const docsLeft = document.getElementById('documents').getBoundingClientRect().left
    const arrowLeft = this.clamp(left - docsLeft + width / 2 - 10, 0, maxLeft)

    this.$arrow.css('left', arrowLeft);
  }

  attachTriggerEvents() {
    this.$item.find(this.$triggerBtn).on('click', $.proxy(function(e) {
      if (this.previewOpen()){
        this.closePreview()
      } else {
        this.showPreview()
      }
    }, this))

    $("#documents").on('click', $.proxy(function(e) {
      if (!this.currentPreview(e)){
        this.closePreview();
      }
    }, this))
  }

  currentPreview(e){
    // Check if we're clicking in a preview
    if ($(e.target).parents('.preview-container').length > 0){
      return true
    } else {
      if (e.target === this.$triggerBtn[0]) {
        return true
      } else {
        return false
      }
    }
  }

  previewOpen() {
    return this.$triggerBtn.hasClass('preview-open')
  }

  attachPreviewEvents() {
    this.$previewTarget.find(this.$closeBtn).on('click', $.proxy(function() {
      this.closePreview()
    }, this))
  }

  closePreview() {
    this.$previewTarget.removeClass('preview')
    this.$triggerBtn.removeClass('preview-open')
    this.$previewTarget.hide()
    this.$triggerBtn.html('Preview')
  }

  itemsPerRow() {
    const width = $('#documents').width()
    return Math.floor(width/this.itemWidth)
  }

  reorderPreviewDivs() {
    const docId = this.$previewTarget.data('document-id');
    const galleryDocs = $(`.gallery-document`)
    let previewIndex = galleryDocs.index($(`.gallery-document[data-doc-id='${docId}']`)) + 1

    const itemsPerRow = this.itemsPerRow()
    /*
    / If $itemsPerRow is NaN or 0 we should return here. If not we are going
    / to have a bad time with an infinite while loop. This only manifests
    / on the show page when using the "back" button to get back to a show
    / page using the browse nearby feature.
    /
    / Reproduction steps for NaN:
    / 1. visit https://searchworks.stanford.edu/view/2279186
    / 2. click on the bound-with link "Copy 1 bound with v. 5, no. 1. 36105026515499 (item id)"
    / 3. click the back button
    /
    */
    if (Number.isNaN(itemsPerRow) || itemsPerRow === 0) {
      return
    }

    if (this.$previewTarget.find(this.$arrow)) {
      this.appendPointer()
    }

    while (previewIndex % itemsPerRow !== 0) {
      previewIndex++
    }
    if (previewIndex > galleryDocs.length) {
      previewIndex = galleryDocs.length
    }
    this.$previewTarget.detach()
    $(this.$gallery[(previewIndex-1)]).after(this.$previewTarget)
  }
}
