# frozen_string_literal: true

FactoryBot.define do
  factory :gre_stacks, class: 'Hash' do
    defaults = {
      'effectiveLocation' => {
        'institution' => {},
        'campus' => {
          'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5'
        },
        'library' => {
          'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
          'code' => 'GREEN'
        },
        'id' => '4573e824-9273-4f13-972f-cff7bf504217',
        'code' => 'GRE-STACKS',
        'name' => 'Stacks'
      }
    }
    initialize_with { defaults }
  end

  factory :gre_locked_stacks, class: 'Hash' do
    defaults = {
      'effectiveLocation' => {
        'institution' => {},
        'campus' => {
          'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5'
        },
        'library' => {
          'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
          'code' => 'GREEN'
        },
        'id' => 'c796f782-db95-40f9-85b4-2e9158fae035',
        'code' => 'GRE-LOCKED-STK',
        'name' => 'Locked stacks: Ask at circulation desk'
      }
    }
    initialize_with { defaults }
  end

  factory :ear_stacks, class: 'Hash' do
    defaults = {
      'effectiveLocation' => {
        'institution' => {},
        'campus' => {
          'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5'
        },
        'library' => {
          'id' => '96630997-201d-49b3-b8d5-e4ba43a6cde8',
          'code' => 'EARTH-SCI'
        },
        'id' => '13c2ee3e-5d88-453e-bb64-890e2936bebf',
        'code' => 'EAR-STACKS',
        'name' => 'Stacks'
      }
    }
    initialize_with { defaults }
  end

  factory :spec_stacks, class: 'Hash' do
    defaults = {
      'effectiveLocation' => {
        'institution' => {},
        'campus' => {
          'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5'
        },
        'library' => {
          'id' => '5b61a365-6b39-408c-947d-f8861a7ba8ae',
          'code' => 'SPEC-COLL'
        },
        'id' => '0902cbec-8afd-4307-948c-4995a48e160a',
        'code' => 'SPEC-STACKS',
        'name' => 'Locked stacks: Ask at circulation desk'
      }
    }
    initialize_with { defaults }
  end

  factory :hila_stacks, class: 'Hash' do
    defaults = {
      'effectiveLocation' => {
        'institution' => {},
        'campus' => {
          'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5'
        },
        'library' => {
          'id' => 'ffe6ea8e-1e14-482f-b3e9-66e05efb04dd',
          'code' => 'HILA'
        },
        'id' => 'c9cef3c6-5874-4bae-b90b-2e1d1f4674db',
        'code' => 'HILA-STACKS',
        'name' => 'Stacks'
      }
    }
    initialize_with { defaults }
  end
end
