# encoding: utf-8

require "spec_helper"

describe CJKQuery do
  let(:controller) { double('CatalogController') }
  let(:cjk_mm) { '3<86%' }
  let(:q_str) { '舊小說' }
  before do
    controller.extend(CJKQuery)
  end
  describe "modify_params_for_cjk_advanced" do
    let(:user_params) { {'search' => q_str, 'search_title' => q_str,'search_author' => q_str, 'subject_terms' => q_str, 'series_search' => q_str, 'pub_search' => q_str, 'isbn_search' => q_str} }
    let(:solr_params) { {q: solr_q} }
    let(:local_params) { "mm=#{cjk_mm} qs=0" }
    before do
      allow(controller).to receive(:modifiable_params_keys) { ['search', 'search_author', 'search_title', 'subject_terms', 'series_search', 'pub_search', 'isbn_search'] }
      controller.send(:modify_params_for_cjk_advanced, solr_params, user_params)
    end
    describe "unprocessed" do
      let(:solr_q) {"_query_:\"{!edismax pf2=$p2 pf3=$pf3}#{q_str}\" AND
                     _query_:\"{!edismax qf=$qf_title pf=$pf_title pf3=$pf3_title pf2=$pf2_title}#{q_str}\" AND
                     _query_:\"{!edismax qf=$qf_author pf=$pf_author pf3=$pf3_author pf2=$pf2_author}#{q_str}\" AND
                     _query_:\"{!edismax qf=$qf_subject pf=$pf_subject pf3=$pf3_subject pf2=$pf2_subject}#{q_str}\" AND
                     _query_:\"{!edismax qf=$qf_series pf=$pf_series pf3=$pf3_series pf2=$pf2_series}#{q_str}\" AND
                     _query_:\"{!edismax qf=$qf_pub_info pf=$pf_pub_info pf3=$pf3_pub_info pf2=$pf2_pub_info}#{q_str}\" AND
                     _query_:\"{!edismax qf=$qf_number pf=$pf_number pf3=$pf3_number pf2=$pf2_number}#{q_str}\""}

      it "should handle the non-fielded pf/qf" do
        expect(solr_params[:q]).to include "{!edismax qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk #{local_params} }#{q_str}"
      end
      it "should handle title pf/qf" do
        expect(solr_params[:q]).to include "{!edismax  qf=$qf_title_cjk pf=$pf_title_cjk pf3=$pf3_title_cjk pf2=$pf2_title_cjk #{local_params} }#{q_str}"
      end
      it "should handle author pf/qf" do
        expect(solr_params[:q]).to include "{!edismax  qf=$qf_author_cjk pf=$pf_author_cjk pf3=$pf3_author_cjk pf2=$pf2_author_cjk #{local_params} }#{q_str}"
      end
      it "should handle subject pf/qf" do
        expect(solr_params[:q]).to include "{!edismax  qf=$qf_subject_cjk pf=$pf_subject_cjk pf3=$pf3_subject_cjk pf2=$pf2_subject_cjk #{local_params} }#{q_str}"
      end
      it "should handle series pf/qf" do
        expect(solr_params[:q]).to include "{!edismax  qf=$qf_series_cjk pf=$pf_series_cjk pf3=$pf3_series_cjk pf2=$pf2_series_cjk #{local_params} }#{q_str}"
      end
      it "should handle pub_info pf/qf" do
        expect(solr_params[:q]).to include "{!edismax  qf=$qf_pub_info_cjk pf=$pf_pub_info_cjk pf3=$pf3_pub_info_cjk pf2=$pf2_pub_info_cjk #{local_params} }#{q_str}"
      end
      it "should not do anything w/ the number qf/pf" do
        expect(solr_params[:q]).to include "{!edismax qf=$qf_number pf=$pf_number pf3=$pf3_number pf2=$pf2_number}#{q_str}"
      end
    end
    describe "pre-processed" do
      let(:solr_q) { "_query_:\"{!edismax  qf=$qf_title_cjk pf=$pf_title_cjk pf3=$pf3_title_cjk pf2=$pf2_title_cjk #{local_params} }#{q_str}\"" }
      it "should not try to append _cjk onto already processed solr params logic" do
        expect(solr_params[:q]).to include "{!edismax  qf=$qf_title_cjk pf=$pf_title_cjk pf3=$pf3_title_cjk pf2=$pf2_title_cjk #{local_params} }#{q_str}"
        expect(solr_params[:q]).to_not include "_cjk_cjk"
      end
    end
  end
  
  describe "cjk_query_addl_params" do
    it "should leave unrelated solr params alone" do
      user_params = {:q => '舊小說', :search_field => 'search_title'}
      my_solr_params = {'key1'=>'val1', 'key2'=>'val2'}
      solr_params = my_solr_params
      controller.send(:modify_params_for_cjk, solr_params, user_params)
      expect(solr_params).to include(my_solr_params)
    end
    describe "mm and qs solr params" do
      it "if only 1 CJK char, it shouldn't send in additional Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => '飘'})
        expect(solr_params).to_not have_key("mm")
        expect(solr_params).to_not have_key("qs")
      end
      it "if only 2 CJK chars, it shouldn't send in additional Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => '三國'})
        expect(solr_params).to_not have_key("mm")
        expect(solr_params).to_not have_key("qs")
      end
      it "should detect Han - Traditional and add mm and qs to Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => '舊小說'})
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Han - Simplified and add mm and qs to Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => '旧小说'})
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Hiragana and add mm and qs to Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => 'まんが'})
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Katakana and add mm and qs to Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => 'マンガ'})
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Hangul and add mm and qs to Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => '한국경제'})
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect CJK mixed with other alphabets and add mm and qs to Solr params" do
        solr_params = {}
        controller.send(:modify_params_for_cjk, solr_params, {:q => 'abcけいちゅうabc'})
        # mm is changed:  minimum adds in non-cjk tokens
        expect(solr_params['mm']).to eq '5<86%'
        expect(solr_params['qs']).to eq 0
      end        
    end

    describe "qf and pf local solr params" do
      it "everything search should add cjk local params to q if CJK detected" do
        user_params = {:q => q_str, :search_field => 'search'}
        solr_params = {:q=>"{!pf2=$pf2 pf3=$pf3}#{q_str}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include({:q=>"{!qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk}#{q_str}"})
        expect(solr_params).to_not include({:q=>"{!pf2=$pf2 pf3=$pf3}#{q_str}"})
      end
      it "should exhibit the same behavior when search_field = 'search' or no search_field at all" do
        user_params = {:q => q_str, :search_field => 'search'}
        solr_params = {:q=>"{!pf2=$pf2 pf3=$pf3}#{q_str}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        first_q = solr_params[:q]
        user_params = {:q => q_str}
        solr_params = {:q=>"{!pf2=$pf2 pf3=$pf3}#{q_str}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(first_q).to eq solr_params[:q]
      end
      it "should add cjk local params to q if it is a CJK unigram" do
        q_uni = '飘'
        user_params = {:q => q_uni, :search_field => 'search'}
        solr_params = {:q=>"{!pf2=$pf2 pf3=$pf3}#{q_uni}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include({:q=>"{!qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk}#{q_uni}"})
        expect(solr_params).to_not include({:q=>"{!pf2=$pf2 pf3=$pf3}#{q_uni}"})
      end
      it "title search should add CJK local params to q if CJK detected" do
        user_params = {:q => q_str, :search_field => 'search_title'}
        solr_params = {:q=>"{!qf=$qf_title pf=$pf_title pf2=$pf2_title pf3=$pf3_title}#{q_str}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include({:q=>"{!qf=$qf_title_cjk pf=$pf_title_cjk pf3=$pf3_title_cjk pf2=$pf2_title_cjk}#{q_str}"})
        expect(solr_params).to_not include({:q=>"{!qf=$qf_title pf=$pf_title pf2=$pf2_title pf3=$pf3_title}#{q_str}"})
      end
      it "author search should add CJK local params to q if CJK detected" do
        user_params = {:q => q_str, :search_field => 'search_author'}
        solr_params = {:q=>"{!qf=$qf_author pf=$pf_author pf2=$pf2_author pf3=$pf3_author}#{q_str}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include({:q=>"{!qf=$qf_author_cjk pf=$pf_author_cjk pf3=$pf3_author_cjk pf2=$pf2_author_cjk}#{q_str}"})
      end
      it "subject search should add CJK local params to q if CJK detected" do
        user_params = {:q => q_str, :search_field => 'subject_terms'}
        solr_params = {:q=>"{!qf=$qf_subject pf=$pf_subject pf2=$pf2_subject pf3=$pf3_subject}#{q_str}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include({:q=>"{!qf=$qf_subject_cjk pf=$pf_subject_cjk pf3=$pf3_subject_cjk pf2=$pf2_subject_cjk}#{q_str}"})
      end
      it "series search should add CJK local params to q if CJK detected" do
        user_params = {:q => q_str, :search_field => 'search_series'}
        solr_params = {:q=>"{!qf=$qf_series pf=$pf_series pf2=$pf2_series pf3=$pf3_series}#{q_str}"}
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include({:q=>"{!qf=$qf_series_cjk pf=$pf_series_cjk pf3=$pf3_series_cjk pf2=$pf2_series_cjk}#{q_str}"})
      end
      it "advanced search should NOT add CJK local params to q if CJK detected" do
        user_params = {:description => q_str, :search_field => 'advanced'}
        q_solr_param = {:q=>"_query_:\"{!edismax pf=$pf_description qf=$qf_description pf2=$pf_description2 pf3=$pf_description3}+#{q_str}\""}
        solr_params = q_solr_param
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include(q_solr_param)
      end
      it "author-title search should NOT add CJK local params to q if CJK detected" do
        user_params = {:q => q_str, :search_field => 'author_title'}
        q_solr_param = {:q=>"{!qf=author_title_search pf=author_title_search^10 pf2=author_title_search^2 pf3=author_title_search^5}#{q_str}"}
        solr_params = q_solr_param
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include(q_solr_param)
      end
      it "call number search should NOT add CJK local params to q if CJK detected" do
        user_params = {:q => q_str, :search_field => 'call_number'}
        q_solr_param = {:q=>"{!df=callnum_search'}\"#{q_str}\""}
        solr_params = q_solr_param
        controller.send(:modify_params_for_cjk, solr_params, user_params)
        expect(solr_params).to include(q_solr_param)
      end
    end

    it "should add mm, qs and CJK local params to q if CJK detected" do
      user_params = {:q => q_str, :search_field => 'search'}
      solr_params = {:q=>"{!pf2=$pf2 pf3=$pf3}#{q_str}"}
      controller.send(:modify_params_for_cjk, solr_params, user_params)
      expect(solr_params).to include({:q=>"{!qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk}#{q_str}"})
      expect(solr_params).to include({'mm'=>cjk_mm, 'qs'=>0})
    end
  end

  describe "#cjk_unigrams_size" do
    it "should detect hangul" do
      expect(controller.send(:cjk_unigrams_size, '한국주택은행')).to eq 6
    end
    it "should detect Han - Traditional" do
      expect(controller.send(:cjk_unigrams_size, '舊小說')).to eq 3
    end
    it "should detect Han - Simplified" do
      expect(controller.send(:cjk_unigrams_size, '旧小说')).to eq 3
    end
    it "should detect Modern Kanji" do
      expect(controller.send(:cjk_unigrams_size, '漫画')).to eq 2
    end
    it "should detect Traditional Kanji" do
      expect(controller.send(:cjk_unigrams_size, '漫畫')).to eq 2
    end
    it "should detect Hiragana" do
      expect(controller.send(:cjk_unigrams_size, "まんが")).to eq 3
    end
    it "should detect Katakana" do
      expect(controller.send(:cjk_unigrams_size, "マンガ")).to eq 3
    end
    it "should detect Hancha traditional" do
      expect(controller.send(:cjk_unigrams_size, "廣州")).to eq 2
    end
    it "should detect Hancha simplified" do
      expect(controller.send(:cjk_unigrams_size, "光州")).to eq 2
    end
    it "should detect Hangul" do
      expect(controller.send(:cjk_unigrams_size, "한국경제")).to eq 4
    end
    it "should detect mixed scripts" do
      expect(controller.send(:cjk_unigrams_size, "近世仮名遣い")).to eq 6
    end
    it "should detect first character CJK" do
      expect(controller.send(:cjk_unigrams_size, "舊小說abc")).to eq 3
      expect(controller.send(:cjk_unigrams_size, "旧小说 abc")).to eq 3
      expect(controller.send(:cjk_unigrams_size, " 漫画 abc")).to eq 2
    end
    it "should detect last character CJK" do
      expect(controller.send(:cjk_unigrams_size, "abc漫畫")).to eq 2
      expect(controller.send(:cjk_unigrams_size, "abc まんが")).to eq 3
      expect(controller.send(:cjk_unigrams_size, "abc マンガ ")).to eq 3
    end
    it "should detect (latin)(CJK)(latin)" do
      expect(controller.send(:cjk_unigrams_size, "abc廣州abc")).to eq 2
      expect(controller.send(:cjk_unigrams_size, "abc 한국경제abc")).to eq 4
      expect(controller.send(:cjk_unigrams_size, "abc近世仮名遣い abc")).to eq 6
      expect(controller.send(:cjk_unigrams_size, "abc 近世仮名遣い abc")).to eq 6
    end
  end
  describe "#cjk_mm_qs_params" do
    describe "Solr mm and ps parameters" do
      describe "should not send in a Solr mm param if only 1 or 2 CJK chars" do
        it "1 CJK char" do
          expect(controller.send(:cjk_mm_qs_params, "飘")['mm']).to be_nil
        end
        it "2 CJK (adj) char" do
          expect(controller.send(:cjk_mm_qs_params, "三國")['mm']).to be_nil
        end
        describe "mixed with non-CJK scripts" do
          describe "bigram" do
            it "first CJK" do
              expect(controller.send(:cjk_mm_qs_params, "董桥abc")['mm']).to be_nil
              expect(controller.send(:cjk_mm_qs_params, "董桥 abc")['mm']).to be_nil
              expect(controller.send(:cjk_mm_qs_params, " 董桥 abc")['mm']).to be_nil
            end
            it "last CJK" do
              expect(controller.send(:cjk_mm_qs_params, "abc董桥")['mm']).to be_nil
              expect(controller.send(:cjk_mm_qs_params, "abc 董桥")['mm']).to be_nil
              expect(controller.send(:cjk_mm_qs_params, "abc 董桥 ")['mm']).to be_nil
            end
            it "(latin)(CJK)(latin)" do
              expect(controller.send(:cjk_mm_qs_params, "abc董桥abc")['mm']).to be_nil
              expect(controller.send(:cjk_mm_qs_params, "abc 董桥abc")['mm']).to be_nil
              expect(controller.send(:cjk_mm_qs_params, "abc董桥 abc")['mm']).to be_nil
              expect(controller.send(:cjk_mm_qs_params, "abc 董桥 abc")['mm']).to be_nil
            end
          end
        end # mixed      
      end # 1 or 2 CJK chars

      describe "only CJK chars in query" do
        let(:cjk_mm_val) { controller.send(:cjk_mm_val) }
        let(:cjk_qs_val) { controller.send(:cjk_qs_val) }
        it "3 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(controller.send(:cjk_mm_qs_params, "マンガ")).to eq({'mm'=>cjk_mm_val, 'qs'=>cjk_qs_val})
        end
        it "4 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(controller.send(:cjk_mm_qs_params, "历史研究")).to eq({'mm'=>cjk_mm_val, 'qs'=>cjk_qs_val})
        end
        it "5 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(controller.send(:cjk_mm_qs_params, "妇女与婚姻")).to eq({'mm'=>cjk_mm_val, 'qs'=>cjk_qs_val})
        end
        it "6 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(controller.send(:cjk_mm_qs_params, "한국주택은행")).to eq({'mm'=>cjk_mm_val, 'qs'=>cjk_qs_val})
        end
        it "7 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(controller.send(:cjk_mm_qs_params, "中国地方志集成")).to eq({'mm'=>cjk_mm_val, 'qs'=>cjk_qs_val})
        end
      end

      describe "mixed with non-CJK scripts" do
        let(:mm_plus_1) { '4<86%' }
        let(:mm_plus_2) { '5<86%' }
        let(:cjk_qs_val) { controller.send(:cjk_qs_val) }
        # for each non-cjk token, add 1 to the lower limit of mm
        it "first CJK" do
          expect(controller.send(:cjk_mm_qs_params, "マンガabc")).to eq({'mm'=>mm_plus_1, 'qs'=>cjk_qs_val})
          expect(controller.send(:cjk_mm_qs_params, "マンガ abc")).to eq({'mm'=>mm_plus_1, 'qs'=>cjk_qs_val})
          expect(controller.send(:cjk_mm_qs_params, " マンガ abc")).to eq({'mm'=>mm_plus_1, 'qs'=>cjk_qs_val})
        end
        it "last CJK" do
          expect(controller.send(:cjk_mm_qs_params, "abcマンガ")).to eq({'mm'=>mm_plus_1, 'qs'=>cjk_qs_val})
          expect(controller.send(:cjk_mm_qs_params, "abc マンガ")).to eq({'mm'=>mm_plus_1, 'qs'=>cjk_qs_val})
          expect(controller.send(:cjk_mm_qs_params, "abc マンガ ")).to eq({'mm'=>mm_plus_1, 'qs'=>cjk_qs_val})
        end
        it "(latin)(CJK)(latin)" do
          expect(controller.send(:cjk_mm_qs_params, "abcマンガabc")).to eq({'mm'=>mm_plus_2, 'qs'=>cjk_qs_val})
          expect(controller.send(:cjk_mm_qs_params, "abc マンガabc")).to eq({'mm'=>mm_plus_2, 'qs'=>cjk_qs_val})
          expect(controller.send(:cjk_mm_qs_params, "abcマンガ abc")).to eq({'mm'=>mm_plus_2, 'qs'=>cjk_qs_val})
          expect(controller.send(:cjk_mm_qs_params, "abc マンガ abc")).to eq({'mm'=>mm_plus_2, 'qs'=>cjk_qs_val})
        end
      end
    end
  end
end
