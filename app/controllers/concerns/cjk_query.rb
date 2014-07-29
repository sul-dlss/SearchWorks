# adjust Solr params as required for CJK chars in user query string
# if a query string has CJK characters in it, adjust the mm and ps Solr parameters as necessary
module CJKQuery
  extend ActiveSupport::Concern
  
  included do
    if self.respond_to?(:before_filter)
      before_filter :add_cjk_params_logic, only: :index
    end
  end

  private

  def add_cjk_params_logic
    if self.class.respond_to?(:solr_search_params_logic)
      self.class.solr_search_params_logic << :modify_params_for_cjk
    end
  end

  def modify_params_for_cjk(solr_params,user_params)
    if user_params && user_params[:q].present?
      q_str = user_params[:q]
      number_of_unigrams = cjk_unigrams_size(q_str)
      if number_of_unigrams > 2
        solr_params.merge!(cjk_mm_qs_params(q_str))
      end
      # adjust q local params to use cjk flavored fields for qf, pf
      if number_of_unigrams > 0
        case user_params[:search_field]
          when 'search', nil
            solr_params[:q] = "{!qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk}#{q_str}"
          when 'search_title'
            solr_params[:q] = "{!qf=$qf_title_cjk pf=$pf_title_cjk pf3=$pf3_title_cjk pf2=$pf2_title_cjk}#{q_str}"
          when 'search_author'
            solr_params[:q] = "{!qf=$qf_author_cjk pf=$pf_author_cjk pf3=$pf3_author_cjk pf2=$pf2_author_cjk}#{q_str}"
          when 'search_series'
            solr_params[:q] = "{!qf=$qf_series_cjk pf=$pf_series_cjk pf3=$pf3_series_cjk pf2=$pf2_series_cjk}#{q_str}"
          when 'subject_terms'
            solr_params[:q] = "{!qf=$qf_subject_cjk pf=$pf_subject_cjk pf3=$pf3_subject_cjk pf2=$pf2_subject_cjk}#{q_str}"
          # do not change for  author_title, call_number or advanced
        end
      end
    end
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
