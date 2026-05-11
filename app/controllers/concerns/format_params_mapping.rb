# frozen_string_literal: true

module FormatParamsMapping
  extend ActiveSupport::Concern

  included do
    before_action :map_format_params, only: :index if respond_to?(:before_action) # rubocop:disable Rails/LexicallyScopedActionFilter
  end

  private

  def map_format_params
    return unless params.dig(:f, :format_main_ssim)

    params[:f][:format_hsim] ||= []
    params[:f][:format_hsim] += params.dig(:f, :format_main_ssim).map { |f| legacy_format_data_mapping[f] || f }
    params[:f].delete(:format_main_ssim)
  end

  # These were the old format values that need to be mapped to the new format values
  def legacy_format_data_mapping
    {
      'Music recording' => 'Sound recording',
      'Video' => 'Video/Film'
    }
  end
end
