// Inlined into the layout immediately after Honeybadger.configure so the filters are in place before any
// other script runs. Registering them from the deferred searchworks4 bundle is too late for errors raised
// while loading that bundle, including the bundle itself failing to parse.
import { configureHoneybadgerFilters } from "./honeybadger"

configureHoneybadgerFilters()
