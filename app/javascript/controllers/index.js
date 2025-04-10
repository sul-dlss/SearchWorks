// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import LiveLookupController from "./live_lookup_controller"
application.register("live-lookup", LiveLookupController)

import LongTableController from "./long_table_controller"
application.register("long-table", LongTableController)

import PreviewBriefController from "./preview_brief_controller"
application.register("preview-brief", PreviewBriefController)

import PreviewFilmstripController from "./preview_filmstrip_controller"
application.register("preview-filmstrip", PreviewFilmstripController)

import LookupTitleController from "./lookup_title_controller"
application.register("lookup-title", LookupTitleController)
