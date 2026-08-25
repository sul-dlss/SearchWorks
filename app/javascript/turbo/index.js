import { StreamActions } from "@hotwired/turbo"

import handleFilmstripFetchRequest from "./handleFilmstripFetchRequest"
import handleFilmstripFrameMissing from "./handleFilmstripFrameMissing"
import updateOpener from "./updateOpener"

document.addEventListener("turbo:before-fetch-request", handleFilmstripFetchRequest)
document.addEventListener("turbo:frame-missing", handleFilmstripFrameMissing)
StreamActions.updateOpener = updateOpener
