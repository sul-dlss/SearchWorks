import { Controller } from "@hotwired/stimulus"
import PreviewContent from '../preview-content'

export default class extends Controller {
  static values = {
    url: String,
    selector: String
  }

  connect() {
    this.triggerBtn = $('<div class="preview-trigger-btn preview-opacity" data-action="click->preview-filmstrip#showPreview"><span class="bi-chevron-down small"></span></div>')
    this.triggerFocus = $('<div class="preview-trigger-focus preview-opacity" data-action="click->preview-filmstrip#showPreview">Preview <span class="bi-chevron-down small"></span></div>')
    this.arrow = $('<div class="preview-arrow"></div>');

    // NOTE: The filmstrip, viewport, prevew ,and closeBtn are outside of the controller.
    this.filmstrip = $(this.element).closest('.image-filmstrip');
    this.viewport = this.filmstrip.find('.viewport');
    this.preview = $(this.selectorValue)
    this.closeBtn = $(`<button type="button" class="preview-close btn-close close" aria-label="Close">
    <span aria-hidden="true" class="visually-hidden">×</span>
    </button>`);

    this.appendTriggers()
  }

  appendTriggers() {
    $(this.element).append(this.triggerBtn).append(this.triggerFocus);
    this.attachTriggerEvents();
  }

  showPreview() {
    const divContent = $('<div class="preview-content"></div>')
    console.log("Now Preview target is ", this.preview)

    this.preview.addClass('preview').empty();

    this.appendPointer()

    PreviewContent.append(this.urlValue, divContent);

    this.preview
      .append(divContent)
      .append(this.closeBtn)
      .show();

    this.viewport.css('overflow-x', 'hidden');
    this.attachPreviewEvents()
  }

  appendPointer() {
    this.preview.append(this.arrow);

    const maxLeft = this.preview.width() - this.arrow.width() - 1
    let arrowLeft = parseInt($(this.element).position().left + ($(this.element).width()/2) - 20);

    if (arrowLeft < 0) arrowLeft = 0;
    if (arrowLeft > maxLeft) arrowLeft = maxLeft;

    this.arrow.css('left', arrowLeft);
  }

  attachTriggerEvents() {
    $(this.element).on('mouseenter', () => {
      this.triggerBtn.hide()
      this.triggerFocus.fadeIn('fast')
    })

    $(this.element).on('mouseleave', () => {
      this.triggerFocus.hide()
      this.triggerBtn.show()
    })
  }

  // TODO: the preview is outside of this controller's scope.
  attachPreviewEvents() {
    this.closeBtn.on('click', () => this.closePreview());
  }

  closePreview() {
    this.viewport.css('overflow-x', 'scroll');
    this.preview.empty().hide();
  }
}
