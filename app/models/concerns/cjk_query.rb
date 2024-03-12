# encoding: UTF-8
# frozen_string_literal: true

# adjust Solr params as required for CJK chars in user query string
# if a query string has CJK characters in it, adjust the mm and ps Solr parameters as necessary
module CJKQuery
  extend ActiveSupport::Concern

  def modify_params_for_cjk(solr_params)
    return unless blacklight_params && blacklight_params[:q].present?

    q_str = blacklight_params[:q]
    number_of_unigrams = cjk_unigrams_size(q_str)
    solr_params.merge!(cjk_mm_qs_params(q_str)) if number_of_unigrams > 2
    # adjust q local params to use cjk flavored fields for qf, pf

    return if cjk_config.blank?
    return unless number_of_unigrams.positive?

    solr_params[:qf] = cjk_config[:qf]
    solr_params[:pf] = cjk_config[:pf]
    solr_params[:pf2] = cjk_config[:pf2]
    solr_params[:pf3] = cjk_config[:pf3]
  end

  def modify_params_for_cjk_advanced(solr_params)
    return if blacklight_params&.dig(:clause).blank? || solr_params[:q] =~ /_cjk/

    modifiable_params_keys.each do |param|
      hash = blacklight_params[:clause].values.find { |v| v[:field] == param } || {}
      query = hash[:query]

      next unless cjk_unigrams_size(query) > 0

      cjk_local_params = cjk_mm_qs_params(query)
      if param == 'search'
        solr_params[:q] = solr_params[:q].gsub("pf2=$pf2 pf3=$pf3", "qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk mm=#{cjk_local_params['mm']} qs=#{cjk_local_params['qs']} ")
      else
        stripped_param = modify_field_key_for_cjk(param)
        if cjk_local_params.present?
          solr_params[:q] = solr_params[:q].gsub(/\{!edismax(.*(q|p)f\d?=\$(q|p)f?\d?_(#{stripped_param})\s?)}#{Regexp.escape(query)}/, '{!edismax \1 mm=' + cjk_local_params['mm'].to_s + ' qs=' + cjk_local_params['qs'].to_s + ' }' + query)
        end
        solr_params[:q] = solr_params[:q].gsub(/((q|p)f\d?=\$(q|p)f?\d?_(#{stripped_param}))/, '\1_cjk')
      end
    end
  end

  private

  def cjk_config
    if search_field.nil? && blacklight_config&.search_fields&.values&.first&.cjk_solr_parameters
      blacklight_config.search_fields.values.first.cjk_solr_parameters
    elsif search_field&.cjk_solr_parameters
      search_field.cjk_solr_parameters
    else
      {}
    end
  end

  def modifiable_params_keys
    blacklight_config.search_fields.keys
  end


  def modify_field_key_for_cjk(field_key)
    field_key.gsub(/(_?search_?)|(_terms)/, '').gsub(/^pub$/, 'pub_info')
  end

  def cjk_qf_pf_params(field, query)
    "{!#{cjk_field('qf', field)} #{cjk_field('pf', field)} #{cjk_field('pf3', field)} #{cjk_field('pf2', field)}}#{query}"
  end

  def cjk_field(kind, field)
    "#{kind}=$#{[kind, field, 'cjk'].compact.join('_')}"
  end

  def cjk_unigrams_size(str)
    if str && str.kind_of?(String)
      str.scan(/\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/).size
    else
      0
    end
  end

  # return a hash containing mm and qs Solr parameters based on the CJK characters in the str
  def cjk_mm_qs_params(str)
    number_of_unigrams = cjk_unigrams_size(str)
    if number_of_unigrams > 2
      num_non_cjk_tokens = str.scan(/[[:alnum]]+/).size
      if num_non_cjk_tokens > 0
        lower_limit = cjk_mm_val[0].to_i
        mm = (lower_limit + num_non_cjk_tokens).to_s + cjk_mm_val[1, cjk_mm_val.size]
        { 'mm' => mm, 'qs' => cjk_qs_val }
      else
        { 'mm' => cjk_mm_val, 'qs' => cjk_qs_val }
      end
    else
      {}
    end
  end

  def cjk_mm_val
    "3<86%"
  end

  def cjk_qs_val
    0
  end
end
