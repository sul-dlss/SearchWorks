import Blacklight from "blacklight-frontend"
import BlacklightRangeLimit from "blacklight-range-limit"

BlacklightRangeLimit.init({
  onLoadHandler: Blacklight.onLoad,
  callback: (instance) => {
    instance.container.setAttribute("data-range-limit-initialized", "true")
  },
  containerQuerySelector: ".limit_content.range_limit:not([data-range-limit-initialized])"
})
