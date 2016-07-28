FactoryGirl.define do
  factory :label do
    sequence( :id ) { |n| "#{n}" }
    sequence(:vlabel) { |n| "vlabel_map_#{n}" }
    description "im a label"
    initialize_with {|x| Label.new(x)}
  end

  factory :segment do
    sequence( :id ) { |n| "#{n}" }
    days "0000000"
    start_time 0
    end_time 0

    trait "mon/wed/fri" do
      days "0101010"
    end

    trait :weekend do
      days "1000001"
    end

    trait :tuesday do
      days "0010000"
    end

    trait :not_tuesday do
      days "1101111"
    end

    trait :weekday do
      days "0111110"
    end

    trait "24_7" do
      start_time 0
      end_time 1439
    end

    factory :weekend_24_7, traits: [:weekend,"24_7"]
    factory :weekday_24_7, traits: [:weekday, "24_7"]

    factory :netflix_tuesday, traits: [:tuesday]
    factory :netflix_other, traits: [:not_tuesday]

    initialize_with {|x| Segment.new(x)}
  end

  factory :allocation do
    sequence( :id ) { |n| "#{n}" }
    destination_id 1
    percentage 0
    priority 1
    initialize_with {|x| Allocation.new(x)}
  end
end

class Segment < OpenStruct
  def build_utc_segments
    self.utc_segments = Proto::TimeZone::Range.new(self).convert_timezone("UTC")
  end
end
class Label < OpenStruct
end
class Allocation < OpenStruct
end
