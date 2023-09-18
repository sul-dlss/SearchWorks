# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: 'Hash' do
    transient do
      location factory: :gre_stacks
      status { nil }
      reserve_desk { nil }
      course_id { nil }
      loan_period { nil }
      holdings_record_id { '11' }
    end

    initialize_with {
      {
        'id' => SecureRandom.uuid,
        'status' => status,
        'holdingsRecordId' => holdings_record_id,
        "materialType" => "book",
        "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
        "permanentLoanType" => "Can circulate",
        "effectiveLocationId" => "4573e824-9273-4f13-972f-cff7bf504217",
        'location' => location,
        'reserve_desk' => reserve_desk,
        'course_id' => course_id,
        'loan_period' => loan_period
      }.compact
    }

    trait :available do
      transient {
        status { 'Available' }
      }
    end

    trait :in_process do
      transient {
        status { 'In Process' }
      }
    end

    trait :on_reserve do
      transient {
        reserve_desk { 'reserve_desk' }
        course_id { 'course_id' }
        loan_period { 'loan_period' }
      }
    end
  end
end
