import { StreamActions } from "@hotwired/turbo"

import handleFilmstripFrameMissing from "./handleFilmstripFrameMissing"
import updateOpener from "./updateOpener"

document.addEventListener("turbo:frame-missing", handleFilmstripFrameMissing)
StreamActions.updateOpener = updateOpener
