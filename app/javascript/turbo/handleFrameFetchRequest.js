const FALLBACK_FRAME_ID_PREFIXES = ["availability_", "filmstrip_"]

// Turbo does not handle rejected fetches for frame src requests. These frames
// enhance content that is already present on the page, so replace network
// failures with an empty frame response instead of leaving an unhandled promise.
function emptyFrameResponse(frameId) {
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
  if (!FALLBACK_FRAME_ID_PREFIXES.some((prefix) => frameId?.startsWith(prefix))) return

  const fetchRequest = event.detail.fetchRequest
  const response = fetchRequest?.response || globalThis.fetch(event.detail.url, event.detail.fetchOptions)

  event.detail.fetchRequest = {
    ...fetchRequest,
    response: Promise.resolve(response).catch((error) => {
      if (error.name === "AbortError") throw error

      return emptyFrameResponse(frameId)
    })
  }
}
