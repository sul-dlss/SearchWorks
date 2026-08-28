import { StreamActions } from "@hotwired/turbo"

import handleFrameFetchRequest from "./handleFrameFetchRequest"
import handleFilmstripFrameMissing from "./handleFilmstripFrameMissing"
import updateOpener from "./updateOpener"

document.addEventListener("turbo:before-fetch-request", handleFrameFetchRequest)
document.addEventListener("turbo:frame-missing", handleFilmstripFrameMissing)
StreamActions.updateOpener = updateOpener
