// Bootstrap runs data-bs-* attribute values through JSON.parse, so text such as
// "[1932]" or "1932" (e.g. MHLD "Library has" statements) becomes an array or a
// number and fails Bootstrap's config type check. Passing the raw attribute
// strings explicitly takes precedence over the parsed data attributes.
export default function popoverTextOptions(element) {
  const options = {}
  for (const name of ["title", "content"]) {
    const value = element.getAttribute(`data-bs-${name}`)
    if (value !== null) options[name] = value
  }
  return options
}
