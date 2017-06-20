# encoding: UTF-8
# adjust Solr params as required for CJK chars in user query string
# if a query string has CJK characters in it, adjust the mm and ps Solr parameters as necessary
module CJKQuery
  extend ActiveSupport::Concern

  def modify_params_for_cjk(solr_params)
    if blacklight_params && blacklight_params[:q].present?
      q_str = blacklight_params[:q]
      number_of_unigrams = cjk_unigrams_size(q_str)
      if number_of_unigrams > 2
        solr_params.merge!(cjk_mm_qs_params(q_str))
      end
      # adjust q local params to use cjk flavored fields for qf, pf
      if number_of_unigrams > 0
        case blacklight_params[:search_field]
          when 'search', nil
            #solr_params[:q] = "{!qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk}#{q_str}"
            solr_params[:q] = cjk_qf_pf_params(nil, q_str)
          when 'search_title'
            solr_params[:q] = cjk_qf_pf_params('title', q_str)
          when 'search_author'
            solr_params[:q] = cjk_qf_pf_params('author', q_str)
          when 'search_series'
            solr_params[:q] = cjk_qf_pf_params('series', q_str)
          when 'subject_terms'
            solr_params[:q] = cjk_qf_pf_params('subject', q_str)
          # do not change for  author_title, call_number or advanced
        end
      end
    end
  end

  def modify_params_for_cjk_advanced(solr_params)
    if blacklight_params.present? && !(solr_params[:q] =~ /_cjk/)
      modifiable_params_keys.each do |param|
        if blacklight_params[param]
          if cjk_unigrams_size(blacklight_params[param]) > 0
            cjk_local_params = cjk_mm_qs_params(blacklight_params[param])
            if param == 'search'
              solr_params[:q].gsub!("pf2=$p2 pf3=$pf3", "qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk mm=#{cjk_local_params['mm']} qs=#{cjk_local_params['qs']} ")
            else
              stripped_param = modify_field_key_for_cjk(param)
              if cjk_local_params.present?
                solr_params[:q].gsub!(/\{!edismax(.*(q|p)f\d?=\$(q|p)f?\d?_(#{stripped_param})\s?)}#{blacklight_params[param]}/, '{!edismax \1 mm=' + cjk_local_params['mm'].to_s + ' qs=' + cjk_local_params['qs'].to_s + ' }' + blacklight_params[param])
              end
              solr_params[:q].gsub!(/((q|p)f\d?=\$(q|p)f?\d?_(#{stripped_param}))/, '\1_cjk')
            end
          end
        end
      end
    end
  end

  private

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
        {'mm' => mm, 'qs' => cjk_qs_val}
      else
        {'mm' => cjk_mm_val, 'qs' => cjk_qs_val}
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
