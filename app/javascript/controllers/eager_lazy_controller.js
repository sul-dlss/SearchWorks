import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]
  static values = { watcherId: Number }

  connect() {
  }

  disconnect() {
    this.stopWatching();
  }

  frameTargetConnected() {
    if (!this.watcherValue) this.startWatching();
  }

  startWatching() {
    this.watcherValue = setInterval(() => this.eagerLazyLoad(), 300);
  }

  stopWatching() {
    if (this.watcherValue) {
      clearInterval(this.watcherValue);
      this.watcherValue = null;
    }
  }

  eagerLazyLoad(n = 1) {
    this.frameTargets.filter(frame => frame.loading == 'lazy' && !frame.attributes.complete).slice(0, n).forEach(frame => {
      frame.loading = 'eager';
      delete frame.dataset.eagerLazyTarget;
    });

    this.garbageCollectOtherFrameTargets();
  }

  garbageCollectOtherFrameTargets() {
    this.frameTargets.filter(frame => frame.loading != 'lazy' || frame.attributes.complete).forEach(frame => {
      delete frame.dataset.eagerLazyTarget;
    });

    if (this.frameTargets.length === 0) {
      this.stopWatching();
    }
  }
}
