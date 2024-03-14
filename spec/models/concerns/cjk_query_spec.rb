# encoding: utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CJKQuery do
  # let(:search_builder) { double(SearchBuilder, blacklight_params: blacklight_params) }
  let(:search_builder)  { SearchBuilder.new([], double('ControllerScope', blacklight_config: CatalogController.blacklight_config, search_state_class: nil)).with(blacklight_params.with_indifferent_access) }
  let(:blacklight_params) { {} }
  let(:cjk_mm) { '3<86%' }
  let(:q_str) { '舊小說' }

  describe "modify_params_for_cjk_advanced" do
    let(:blacklight_params) do
      {
        clause: {
          '1': { field: 'search', query: q_str },
          '2': { field: 'search_title', query: q_str },
          '3': { field: 'search_author', query: q_str },
          '4': { field: 'subject_terms', query: q_str },
          '5': { field: 'series_search', query: q_str },
          '6': { field: 'pub_search', query: q_str },
          '7': { field: 'isbn_search', query: q_str }
        }
      }
    end

    let(:solr_params) { { q: solr_q } }
    let(:local_params) { "mm=#{cjk_mm} qs=0" }

    before do
      search_builder.modify_params_for_cjk_advanced(solr_params)
    end

    describe "unprocessed" do
      let(:solr_q) { "_query_:\"{!edismax pf2=$pf2 pf3=$pf3}#{q_str}\" AND
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

      context 'when there are unbalanced parenthesis in the query' do
        let(:q_str) { '((舊小說)' }

        it 'is handled without error' do
          expect(solr_params[:q]).to include "{!edismax qf=$qf_cjk pf=$pf_cjk pf3=$pf3_cjk pf2=$pf2_cjk #{local_params} }#{q_str}"
        end
      end
    end

    describe "pre-processed" do
      let(:solr_q) { "_query_:\"{!edismax  qf=$qf_title_cjk pf=$pf_title_cjk pf3=$pf3_title_cjk pf2=$pf2_title_cjk #{local_params} }#{q_str}\"" }

      it "should not try to append _cjk onto already processed solr params logic" do
        expect(solr_params[:q]).to include "{!edismax  qf=$qf_title_cjk pf=$pf_title_cjk pf3=$pf3_title_cjk pf2=$pf2_title_cjk #{local_params} }#{q_str}"
        expect(solr_params[:q]).not_to include "_cjk_cjk"
      end
    end
  end

  describe "cjk_query_addl_params" do
    it "should leave unrelated solr params alone" do
      blacklight_params.merge!(q: '舊小說', search_field: 'search_title')
      my_solr_params = { 'key1' => 'val1', 'key2' => 'val2' }
      solr_params = my_solr_params
      search_builder.modify_params_for_cjk(solr_params)
      expect(solr_params).to include(my_solr_params)
    end
    describe "mm and qs solr params" do
      it "if only 1 CJK char, it shouldn't send in additional Solr params" do
        blacklight_params[:q] = '飘'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params).not_to have_key("mm")
        expect(solr_params).not_to have_key("qs")
      end
      it "if only 2 CJK chars, it shouldn't send in additional Solr params" do
        blacklight_params[:q] = '三國'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params).not_to have_key("mm")
        expect(solr_params).not_to have_key("qs")
      end
      it "should detect Han - Traditional and add mm and qs to Solr params" do
        blacklight_params[:q] = '舊小說'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Han - Simplified and add mm and qs to Solr params" do
        blacklight_params[:q] = '旧小说'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Hiragana and add mm and qs to Solr params" do
        blacklight_params[:q] = 'まんが'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Katakana and add mm and qs to Solr params" do
        blacklight_params[:q] = 'マンガ'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect Hangul and add mm and qs to Solr params" do
        blacklight_params[:q] = '한국경제'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params['mm']).to eq cjk_mm
        expect(solr_params['qs']).to eq 0
      end
      it "should detect CJK mixed with other alphabets and add mm and qs to Solr params" do
        blacklight_params[:q] = 'abcけいちゅうabc'
        solr_params = {}
        search_builder.modify_params_for_cjk(solr_params)
        # mm is changed:  minimum adds in non-cjk tokens
        expect(solr_params['mm']).to eq '5<86%'
        expect(solr_params['qs']).to eq 0
      end
    end

    describe 'qf and pf local solr params' do
      it 'everything search should add cjk local params to q if CJK detected' do
        blacklight_params.merge!(q: q_str, search_field: 'search')
        solr_params = { q: q_str }
        search_builder.modify_params_for_cjk(solr_params)

        expect(solr_params).to include(
          qf:  '${qf_cjk}',
          pf:  '${pf_cjk}',
          pf2: '${pf2_cjk}',
          pf3: '${pf3_cjk}'
        )
      end

      it 'should exhibit the same behavior without a search_field' do
        blacklight_params[:q] = q_str
        solr_params = { q: q_str }
        search_builder.modify_params_for_cjk(solr_params)

        expect(solr_params).to include(
          qf:  '${qf_cjk}',
          pf:  '${pf_cjk}',
          pf2: '${pf2_cjk}',
          pf3: '${pf3_cjk}'
        )
      end

      it 'should add cjk local params to q if it is a CJK unigram' do
        q_uni = '飘'
        blacklight_params.merge!(q: q_uni, search_field: 'search')
        solr_params = { q: q_uni }
        search_builder.modify_params_for_cjk(solr_params)

        expect(solr_params).to include(
          qf:  '${qf_cjk}',
          pf:  '${pf_cjk}',
          pf2: '${pf2_cjk}',
          pf3: '${pf3_cjk}'
        )
      end

      it 'title search should add CJK local params to q if CJK detected' do
        blacklight_params.merge!(q: q_str, search_field: 'search_title')
        solr_params = { q: q_str }
        search_builder.modify_params_for_cjk(solr_params)

        expect(solr_params).to include(
          qf:  '${qf_title_cjk}',
          pf:  '${pf_title_cjk}',
          pf2: '${pf2_title_cjk}',
          pf3: '${pf3_title_cjk}'
        )
      end

      it 'author search should add CJK local params to q if CJK detected' do
        blacklight_params.merge!(q: q_str, search_field: 'search_author')
        solr_params = { q: q_str }
        search_builder.modify_params_for_cjk(solr_params)

        expect(solr_params).to include(
          qf:  '${qf_author_cjk}',
          pf:  '${pf_author_cjk}',
          pf2: '${pf2_author_cjk}',
          pf3: '${pf3_author_cjk}'
        )
      end

      it 'subject search should add CJK local params to q if CJK detected' do
        blacklight_params.merge!(q: q_str, search_field: 'subject_terms')
        solr_params = { q: q_str }
        search_builder.modify_params_for_cjk(solr_params)

        expect(solr_params).to include(
          qf:  '${qf_subject_cjk}',
          pf:  '${pf_subject_cjk}',
          pf2: '${pf2_subject_cjk}',
          pf3: '${pf3_subject_cjk}'
        )
      end

      it 'series search should add CJK local params to q if CJK detected' do
        blacklight_params.merge!(q: q_str, search_field: 'search_series')
        solr_params = { q: q_str }
        search_builder.modify_params_for_cjk(solr_params)

        expect(solr_params).to include(
          qf:  '${qf_series_cjk}',
          pf:  '${pf_series_cjk}',
          pf2: '${pf2_series_cjk}',
          pf3: '${pf3_series_cjk}'
        )
      end

      it "advanced search should NOT add CJK local params to q if CJK detected" do
        blacklight_params.merge!(description: q_str, search_field: 'advanced')
        q_solr_param = { q: "_query_:\"{!edismax pf=$pf_description qf=$qf_description pf2=$pf_description2 pf3=$pf_description3}+#{q_str}\"" }
        solr_params = q_solr_param
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params).to include(q_solr_param)
      end
      it "author-title search should NOT add CJK local params to q if CJK detected" do
        blacklight_params.merge!(q: q_str, search_field: 'author_title')
        q_solr_param = { q: "{!qf=author_title_search pf=author_title_search^10 pf2=author_title_search^2 pf3=author_title_search^5}#{q_str}" }
        solr_params = q_solr_param
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params).to include(q_solr_param)
      end
      it "call number search should NOT add CJK local params to q if CJK detected" do
        blacklight_params.merge!(q: q_str, search_field: 'call_number')
        q_solr_param = { q: "{!df=callnum_search'}\"#{q_str}\"" }
        solr_params = q_solr_param
        search_builder.modify_params_for_cjk(solr_params)
        expect(solr_params).to include(q_solr_param)
      end
    end

    it 'should add mm, qs and CJK local params to q if CJK detected' do
      blacklight_params.merge!(q: q_str, search_field: 'search')
      solr_params = { q: q_str }
      search_builder.modify_params_for_cjk(solr_params)

      expect(solr_params).to include(
        'mm' => cjk_mm,
        'qs' => 0
      )
    end
  end

  describe "#cjk_unigrams_size" do
    it "should detect hangul" do
      expect(search_builder.send(:cjk_unigrams_size, '한국주택은행')).to eq 6
    end
    it "should detect Han - Traditional" do
      expect(search_builder.send(:cjk_unigrams_size, '舊小說')).to eq 3
    end
    it "should detect Han - Simplified" do
      expect(search_builder.send(:cjk_unigrams_size, '旧小说')).to eq 3
    end
    it "should detect Modern Kanji" do
      expect(search_builder.send(:cjk_unigrams_size, '漫画')).to eq 2
    end
    it "should detect Traditional Kanji" do
      expect(search_builder.send(:cjk_unigrams_size, '漫畫')).to eq 2
    end
    it "should detect Hiragana" do
      expect(search_builder.send(:cjk_unigrams_size, "まんが")).to eq 3
    end
    it "should detect Katakana" do
      expect(search_builder.send(:cjk_unigrams_size, "マンガ")).to eq 3
    end
    it "should detect Hancha traditional" do
      expect(search_builder.send(:cjk_unigrams_size, "廣州")).to eq 2
    end
    it "should detect Hancha simplified" do
      expect(search_builder.send(:cjk_unigrams_size, "光州")).to eq 2
    end
    it "should detect Hangul" do
      expect(search_builder.send(:cjk_unigrams_size, "한국경제")).to eq 4
    end
    it "should detect mixed scripts" do
      expect(search_builder.send(:cjk_unigrams_size, "近世仮名遣い")).to eq 6
    end
    it "should detect first character CJK" do
      expect(search_builder.send(:cjk_unigrams_size, "舊小說abc")).to eq 3
      expect(search_builder.send(:cjk_unigrams_size, "旧小说 abc")).to eq 3
      expect(search_builder.send(:cjk_unigrams_size, " 漫画 abc")).to eq 2
    end
    it "should detect last character CJK" do
      expect(search_builder.send(:cjk_unigrams_size, "abc漫畫")).to eq 2
      expect(search_builder.send(:cjk_unigrams_size, "abc まんが")).to eq 3
      expect(search_builder.send(:cjk_unigrams_size, "abc マンガ ")).to eq 3
    end
    it "should detect (latin)(CJK)(latin)" do
      expect(search_builder.send(:cjk_unigrams_size, "abc廣州abc")).to eq 2
      expect(search_builder.send(:cjk_unigrams_size, "abc 한국경제abc")).to eq 4
      expect(search_builder.send(:cjk_unigrams_size, "abc近世仮名遣い abc")).to eq 6
      expect(search_builder.send(:cjk_unigrams_size, "abc 近世仮名遣い abc")).to eq 6
    end
  end

  describe "#cjk_mm_qs_params" do
    describe "Solr mm and ps parameters" do
      describe "should not send in a Solr mm param if only 1 or 2 CJK chars" do
        it "1 CJK char" do
          expect(search_builder.send(:cjk_mm_qs_params, "飘")['mm']).to be_nil
        end
        it "2 CJK (adj) char" do
          expect(search_builder.send(:cjk_mm_qs_params, "三國")['mm']).to be_nil
        end
        describe "mixed with non-CJK scripts" do
          describe "bigram" do
            it "first CJK" do
              expect(search_builder.send(:cjk_mm_qs_params, "董桥abc")['mm']).to be_nil
              expect(search_builder.send(:cjk_mm_qs_params, "董桥 abc")['mm']).to be_nil
              expect(search_builder.send(:cjk_mm_qs_params, " 董桥 abc")['mm']).to be_nil
            end
            it "last CJK" do
              expect(search_builder.send(:cjk_mm_qs_params, "abc董桥")['mm']).to be_nil
              expect(search_builder.send(:cjk_mm_qs_params, "abc 董桥")['mm']).to be_nil
              expect(search_builder.send(:cjk_mm_qs_params, "abc 董桥 ")['mm']).to be_nil
            end
            it "(latin)(CJK)(latin)" do
              expect(search_builder.send(:cjk_mm_qs_params, "abc董桥abc")['mm']).to be_nil
              expect(search_builder.send(:cjk_mm_qs_params, "abc 董桥abc")['mm']).to be_nil
              expect(search_builder.send(:cjk_mm_qs_params, "abc董桥 abc")['mm']).to be_nil
              expect(search_builder.send(:cjk_mm_qs_params, "abc 董桥 abc")['mm']).to be_nil
            end
          end
        end # mixed
      end # 1 or 2 CJK chars

      describe "only CJK chars in query" do
        let(:cjk_mm_val) { search_builder.send(:cjk_mm_val) }
        let(:cjk_qs_val) { search_builder.send(:cjk_qs_val) }

        it "3 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(search_builder.send(:cjk_mm_qs_params, "マンガ")).to eq({ 'mm' => cjk_mm_val, 'qs' => cjk_qs_val })
        end
        it "4 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(search_builder.send(:cjk_mm_qs_params, "历史研究")).to eq({ 'mm' => cjk_mm_val, 'qs' => cjk_qs_val })
        end
        it "5 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(search_builder.send(:cjk_mm_qs_params, "妇女与婚姻")).to eq({ 'mm' => cjk_mm_val, 'qs' => cjk_qs_val })
        end
        it "6 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(search_builder.send(:cjk_mm_qs_params, "한국주택은행")).to eq({ 'mm' => cjk_mm_val, 'qs' => cjk_qs_val })
        end
        it "7 CJK (adj) char: mm=cjk_mm_val, qs=cjk_qs_val" do
          expect(search_builder.send(:cjk_mm_qs_params, "中国地方志集成")).to eq({ 'mm' => cjk_mm_val, 'qs' => cjk_qs_val })
        end
      end

      describe "mixed with non-CJK scripts" do
        let(:mm_plus_1) { '4<86%' }
        let(:mm_plus_2) { '5<86%' }
        let(:cjk_qs_val) { search_builder.send(:cjk_qs_val) }
        # for each non-cjk token, add 1 to the lower limit of mm

        it "first CJK" do
          expect(search_builder.send(:cjk_mm_qs_params, "マンガabc")).to eq({ 'mm' => mm_plus_1, 'qs' => cjk_qs_val })
          expect(search_builder.send(:cjk_mm_qs_params, "マンガ abc")).to eq({ 'mm' => mm_plus_1, 'qs' => cjk_qs_val })
          expect(search_builder.send(:cjk_mm_qs_params, " マンガ abc")).to eq({ 'mm' => mm_plus_1, 'qs' => cjk_qs_val })
        end
        it "last CJK" do
          expect(search_builder.send(:cjk_mm_qs_params, "abcマンガ")).to eq({ 'mm' => mm_plus_1, 'qs' => cjk_qs_val })
          expect(search_builder.send(:cjk_mm_qs_params, "abc マンガ")).to eq({ 'mm' => mm_plus_1, 'qs' => cjk_qs_val })
          expect(search_builder.send(:cjk_mm_qs_params, "abc マンガ ")).to eq({ 'mm' => mm_plus_1, 'qs' => cjk_qs_val })
        end
        it "(latin)(CJK)(latin)" do
          expect(search_builder.send(:cjk_mm_qs_params, "abcマンガabc")).to eq({ 'mm' => mm_plus_2, 'qs' => cjk_qs_val })
          expect(search_builder.send(:cjk_mm_qs_params, "abc マンガabc")).to eq({ 'mm' => mm_plus_2, 'qs' => cjk_qs_val })
          expect(search_builder.send(:cjk_mm_qs_params, "abcマンガ abc")).to eq({ 'mm' => mm_plus_2, 'qs' => cjk_qs_val })
          expect(search_builder.send(:cjk_mm_qs_params, "abc マンガ abc")).to eq({ 'mm' => mm_plus_2, 'qs' => cjk_qs_val })
        end
      end
    end
  end
end
