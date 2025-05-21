Blacklight.onLoad(() => {
  document.querySelectorAll('[data-behavior="purl-embed"]').forEach((element) => purlEmbed(element))
})

function purlEmbed(element) {
    const embedURL = element.dataset.embedUrl
    fetch(embedURL)
      .then(response => response.json())
      .then(data => {
        if (data !== null) {
          element.innerHTML = data.html
        }
      })
}
