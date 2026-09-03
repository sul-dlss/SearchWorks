// Install request handlers before Turbo upgrades eager frames already in the document.
import "./installEventHandlers"
import "@hotwired/turbo-rails"
import { StreamActions } from "@hotwired/turbo"

import updateOpener from "./updateOpener"

// Let a standalone feedback popup show its result as a toast in the window that opened it, then close itself.
StreamActions.updateOpener = updateOpener
