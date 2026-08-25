import handleFilmstripFetchRequest from "./handleFilmstripFetchRequest"
import handleFilmstripFrameMissing from "./handleFilmstripFrameMissing"

document.addEventListener("turbo:before-fetch-request", handleFilmstripFetchRequest)
document.addEventListener("turbo:frame-missing", handleFilmstripFrameMissing)
