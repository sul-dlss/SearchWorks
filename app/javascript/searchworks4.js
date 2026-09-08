// Entry point for the build script in your packageon

import "./turbo"
import "blacklight-frontend"

import "./popover"
import "./feedback_form"
import "./range-limit"
import { configureHoneybadgerFilters } from "./honeybadger"

import "./controllers"
import "./controllers/external"

configureHoneybadgerFilters()
