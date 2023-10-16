require 'rails_helper'

RSpec.describe CatalogController do
  include Devise::Test::ControllerHelpers

  it 'should include the AdvancedSearchParamsMapping concern' do
    expect(subject).to be_a(AdvancedSearchParamsMapping)
  end
  it "should include the DatabaseAccessPoint concern" do
    expect(subject).to be_a(DatabaseAccessPoint)
  end
  it "should include the CallnumberSearch concern" do
    expect(subject).to be_a(CallnumberSearch)
  end
  it "should include the AllCapsParams concern" do
    expect(subject).to be_a(AllCapsParams)
  end
  it "should include the ReplaceSpecialQuotes concern" do
    expect(subject).to be_a(ReplaceSpecialQuotes)
  end

  it "should include the EmailValidation concern" do
    expect(subject).to be_a(EmailValidation)
  end
  describe "#index" do
    it "should set the search modifier" do
      get :index
      expect(assigns(:search_modifier)).to be_a SearchQueryModifier
    end

    it 'redirects to the home page with a flash message when paging too deep' do
      get :index, params: { page: 251 }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq 'You have paginated too deep into the result set. Please contact us using the feedback form if you have a need to view results past page 250.'
    end

    it 'does not include publication date stats on the home page' do
      get :index

      expect(assigns(:response).dig('responseHeader', 'params')).not_to include 'stats'
    end

    it 'includes publication date stats on search pages' do
      get :index, params: { q: 'x' }

      expect(assigns(:response).dig('responseHeader', 'params')).to include 'stats'
    end
  end

  describe '#email' do
    context 'when the user is not logged in and the recaptcha fails' do
      it 'does not allow emails to be submitted' do
        expect_any_instance_of(CatalogController).to receive(:verify_recaptcha).and_return(false)
        expect do
          post :email, params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief', id: '1' }
        end.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'when the user is logged in' do
      before do
        allow(controller).to receive(:current_user).and_return(User.new(email: 'user@stanford.edu'))
      end

      it 'should set the provided subject' do
        expect { post :email, params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief', id: '1' } }.to change {
          ActionMailer::Base.deliveries.count
        }.by(1)
        expect(ActionMailer::Base.deliveries.last.subject).to eq 'Email Subject'
      end
      it 'should send a brief email when requested' do
        email = double('email')
        expect(SearchWorksRecordMailer).to receive(:email_record).and_return(email)
        expect(email).to receive(:deliver_now)
        post :email, params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief', id: '1' }
      end
      it 'should send a full email when requested' do
        email = double('email')
        expect(SearchWorksRecordMailer).to receive(:full_email_record).and_return(email)
        expect(email).to receive(:deliver_now)
        post :email, params: { to: 'email@example.com', subject: 'Email Subject', type: 'full', id: '1' }
      end

      it 'should be able to send emails to multiple addresses' do
        expect do
          post :email, params: { to: 'e1@example.com, e2@example.com, e3@example.com', subject: 'Subject', type: 'full', id: '1' }
        end.to change { ActionMailer::Base.deliveries.count }.by(3)
      end
      describe 'validations' do
        it 'should prevent incorrect email types from being sent' do
          expect do
            post :email, params: { to: 'email@example.com', type: 'not-a-type' }
          end.not_to change { ActionMailer::Base.deliveries.count }
          expect(flash[:error]).to eq 'Invalid email type provided'
        end

        it 'should validate multiple emails correctly' do
          expect do
            post(
              :email,
              params: {
                to: 'email1@example.com, example.com',
                type: 'full'
              }
            )
          end.not_to change { ActionMailer::Base.deliveries.count }

          expect(flash[:error]).to eq 'You must enter only valid email addresses.'
        end

        it 'should prevent emails with too many addresses from being sent' do
          expect do
            post(
              :email,
              params: {
                to: 'email1@example.com,
                     email2@example.com,
                     email3@example.com,
                     email4@example.com,
                     email5@example.com,
                     email6@example.com',
                type: 'full'
              }
            )
          end.not_to change { ActionMailer::Base.deliveries.count }

          expect(flash[:error]).to eq 'You have entered more than the maximum (5) email addresses allowed.'
        end
      end
    end
  end

  describe "routes" do
    describe "customized from Blacklight" do
      it "should route /view/:id properly" do
        expect({ get: '/view/1234' }).to route_to(controller: 'catalog', action: 'show', id: '1234')
      end
      it "should route solr_document_path to /view" do
        expect(solr_document_path('1234')).to eq '/view/1234'
      end
      it "should route solr_document_path to /view" do
        expect(solr_document_path('1234')).to eq '/view/1234'
      end
      it "should route the librarian view properly" do
        expect({ get: '/view/1234/librarian_view' }).to route_to(controller: 'catalog', action: 'librarian_view', id: '1234')
      end
      it "should route the stackmap view properly" do
        expect({ get: '/view/1234/stackmap' }).to route_to(controller: 'catalog', action: 'stackmap', id: '1234')
      end
    end

    describe "/databases" do
      it "should route to the database format" do
        expect({ get: "/databases" }).to route_to(controller: 'catalog', action: 'index', f: { "format_main_ssim" => ["Database"] })
      end
    end

    describe "/backend_lookup" do
      it "should route to the backend lookup path as json" do
        expect({ get: "/backend_lookup" }).to route_to(controller: 'catalog', action: 'backend_lookup', format: :json)
      end
    end
  end

  describe "blacklight config" do
    let(:config) { controller.blacklight_config }

    it "should have the correct facet order" do
      keys = config.facet_fields.keys
      expect(keys.index("access_facet")).to be < keys.index("format_main_ssim")
      expect(keys.index("format_main_ssim")).to be < keys.index("format_physical_ssim")
      expect(keys.index("format_physical_ssim")).to be < keys.index("pub_year_tisim")
      expect(keys.index("pub_year_tisim")).to be < keys.index("building_facet")
      expect(keys.index("building_facet")).to be < keys.index("language")
      expect(keys.index("language")).to be < keys.index("author_person_facet")
      expect(keys.index("author_person_facet")).to be < keys.index("callnum_facet_hsim")
      expect(keys.index("callnum_facet_hsim")).to be < keys.index("topic_facet")
      expect(keys.index("topic_facet")).to be < keys.index("genre_ssim")
      expect(keys.index("genre_ssim")).to be < keys.index("geographic_facet")
      expect(keys.index("geographic_facet")).to be < keys.index("era_facet")
      expect(keys.index("era_facet")).to be < keys.index("author_other_facet")
      expect(keys.index("author_other_facet")).to be < keys.index("format")
    end
    describe 'facet sort' do
      it 'should set an index sort for the resource type facet' do
        expect(config.facet_fields['format_main_ssim'].sort).to eq :index
      end
      it 'should set an index sort for the building type facet' do
        expect(config.facet_fields['building_facet'].sort).to eq :index
      end
      it 'should set an index sort for the database topic facet' do
        expect(config.facet_fields['db_az_subject'].sort).to eq :index
      end
    end

    describe "facet limits" do
      it "should set a very high facet limit on building and format" do
        ['building_facet', 'format_main_ssim'].each do |facet|
          expect(config.facet_fields[facet].limit).to eq 100
        end
      end
      it "should set the correct facet limits on standard facets" do
        ['author_person_facet', 'topic_facet', 'genre_ssim'].each do |facet|
          expect(config.facet_fields[facet].limit).to eq 20
        end
      end
    end

    describe 'search types' do
      it 'should include Author+Title search' do
        search_field = config.search_fields["author_title"]
        expect(search_field).to be_present
        expect(search_field.label).to eq "Author + Title"
        expect(search_field.include_in_simple_select).to be_falsey
        expect(search_field.include_in_advanced_search).to be_falsey
      end
    end
  end
end
