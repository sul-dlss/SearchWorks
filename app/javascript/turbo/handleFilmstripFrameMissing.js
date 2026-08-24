// Browse nearby is optional content. If an intermediary response does not include
// its frame, leave the filmstrip empty instead of raising an unhandled Turbo error.
const MAX_RESPONSE_BODY_LENGTH = 10_000
const BIG_IP_SUPPORT_ID_MARKER = "Your support ID is:"

export async function reportMissingFilmstripFrame(event) {
  const response = event.detail?.response
  const context = {
    expected_frame_id: event.target.id,
    page_url: globalThis.location?.href,
    response_content_type: response?.headers?.get("content-type"),
    response_redirected: response?.redirected,
    response_request_id: response?.headers?.get("x-request-id"),
    response_status: response?.status,
    response_status_text: response?.statusText,
    response_url: response?.url
  }

  try {
    const responseBody = await response.clone().text()

    // BIG-IP may replace the optional filmstrip response with its own block page.
    // This is an expected condition and does not need to be reported.
    if (responseBody.includes(BIG_IP_SUPPORT_ID_MARKER)) return

    context.response_body = responseBody.slice(0, MAX_RESPONSE_BODY_LENGTH)
    context.response_body_truncated = responseBody.length > MAX_RESPONSE_BODY_LENGTH
  } catch(error) {
    context.response_body_read_error = error.message
  }

  const error = new Error(`Missing browse nearby Turbo frame: ${event.target.id}`)

  if (globalThis.Honeybadger) {
    globalThis.Honeybadger.notify(error, {
      name: "TurboFilmstripFrameMissing",
      component: "handleFilmstripFrameMissing",
      context,
      tags: ["turbo", "browse-nearby", "frame-missing"]
    })
  } else {
    console.error(error, context)
  }
}

export default function(event) {
  if (!event.target.id?.startsWith("filmstrip_")) return

  event.preventDefault()
  return reportMissingFilmstripFrame(event).catch((error) => console.error(error))
}
