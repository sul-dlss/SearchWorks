# frozen_string_literal: true

class QuickReportsController < ApplicationController
  def create
    if request.post?
      FeedbackMailer.submit_wrong_book_cover(params, request.remote_ip).deliver_now
      flash.now[:success] = t("blacklight.feedback_form.success")

      respond_to do |format|
        format.json do
          render json: flash
        end
        format.html do
          redirect_to params[:url]
        end
        format.turbo_stream do
          render 'feedback_forms/create'
        end
      end
    end
  end
end
