# frozen_string_literal: true

# Lets clients check whether the JavaScript they have loaded still matches
# what the server is currently deploying, so long-lived tabs can detect drift.
class AssetVersionController < ApplicationController
  def show
    response.headers["Cache-Control"] = "no-store"
    render json: { revision: Settings.REVISION }
  end
end
