import Blacklight from "blacklight-frontend"
import { Tooltip } from "bootstrap"

Blacklight.onLoad(() => {
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  tooltipTriggerList.forEach(tooltipTriggerEl => Tooltip.getOrCreateInstance(tooltipTriggerEl))
})
