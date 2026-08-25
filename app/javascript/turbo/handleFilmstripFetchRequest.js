// Browse nearby is optional content. Turbo does not handle a rejected fetch for
// frame src requests, so turn network failures into an empty filmstrip response.
function emptyFilmstripResponse(frameId) {
  const escapedFrameId = frameId.replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")

  return new Response(`<turbo-frame id="${escapedFrameId}"></turbo-frame>`, {
    headers: { "Content-Type": "text/html; charset=utf-8" },
    status: 503
  })
}

export default function(event) {
  const frameId = event.target.id
  if (!frameId?.startsWith("filmstrip_")) return

  const fetchRequest = event.detail.fetchRequest
  const response = fetchRequest?.response || globalThis.fetch(event.detail.url, event.detail.fetchOptions)

  event.detail.fetchRequest = {
    ...fetchRequest,
    response: Promise.resolve(response).catch((error) => {
      if (error.name === "AbortError") throw error

      return emptyFilmstripResponse(frameId)
    })
  }
}
