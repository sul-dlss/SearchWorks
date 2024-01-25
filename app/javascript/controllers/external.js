// Add controllers from external packages (internal controllers go in index.js)
import { application } from "./application"

import BlacklightHierarchyController from 'blacklight-hierarchy/app/assets/javascripts/blacklight/hierarchy/blacklight_hierarchy_controller'
application.register("b-h-collapsible", BlacklightHierarchyController)