require 'spec_helper'

describe "Magnum::Profile" do

  describe '#name' do
    context 'Saturday & Sunday selected' do
      subject(:profile) { Magnum::Profile.new(sat: true, sun: true) }
      its(:name) { should eq('Weekend') }
    end
    context 'All weekdays selected' do
      subject(:profile) { Magnum::Profile.new(mon: true, tue: true, wed: true, thu: true, fri: true) }
      its(:name) { should eq('Weekday') }
    end
    context 'All days selected' do 
      subject(:profile) { Magnum::Profile.new(mon: true, tue: true, wed: true, thu: true, fri: true, sat: true, sun: true) }
      its(:name) { should eq('All Week') }
    end
    context 'display the name of the day when that day is selected' do
      context 'Sunday' do
        subject(:profile) { Magnum::Profile.new(sun: true) }
        its(:name) { should eq('Sunday') }
      end
      context 'Monday' do
        subject(:profile) { Magnum::Profile.new(mon: true) }
        its(:name) { should eq('Monday') }
      end
      context 'Tuesday' do
        subject(:profile) { Magnum::Profile.new(tue: true) }
        its(:name) { should eq('Tuesday') }
      end
      context 'Wednesday' do
        subject(:profile) { Magnum::Profile.new(wed: true) }
        its(:name) { should eq('Wednesday') }
      end
      context 'Thursday' do
        subject(:profile) { Magnum::Profile.new(thu: true) }
        its(:name) { should eq('Thursday') }
      end
      context 'Friday' do
        subject(:profile) { Magnum::Profile.new(fri: true) }
        its(:name) { should eq('Friday') }
      end
      context 'Saturday' do
        subject(:profile) { Magnum::Profile.new(sat: true) }
        its(:name) { should eq('Saturday') }
      end
    end
    context 'Assortment of days' do
      context 'Friday, Saturday' do
        subject(:profile) { Magnum::Profile.new(fri: true, sat: true) }
        its(:name) { should eq('Friday, Saturday') }
      end
      context 'Sunday, Wednesday' do
        subject(:profile) { Magnum::Profile.new(sun: true, wed: true) }
        its(:name) { should eq('Sunday, Wednesday') }
      end
      context 'Saturday, Sunday, Monday' do
        subject(:profile) { Magnum::Profile.new(sat: true, sun: true, mon: true) }
        its(:name) { should eq('Sunday, Monday, Saturday') }
      end
      context 'Saturday, Tuesday, Wednesday, Friday' do
        subject(:profile) { Magnum::Profile.new(sat: true, tue: true, wed: true, fri: true) }
        its(:name) { should eq('Tuesday, Wednesday, Friday, Saturday') }
      end
      context 'Tuesday, Wednesday, Thursday, Friday' do
        subject(:profile) { Magnum::Profile.new(tue: true, wed: true, thu: true, fri: true) }
        its(:name) { should eq('Tuesday, Wednesday, Thursday, Friday') }
      end
      context 'Tuesday, Wednesday, Thursday, Friday, Saturday' do
        subject(:profile) { Magnum::Profile.new(tue: true, wed: true, thu: true, fri: true, sat: true) }
        its(:name) { should eq('Tuesday, Wednesday, Thursday, Friday, Saturday') }
      end
      context 'Tuesday, Wednesday, Thursday, Friday, Sunday' do
        subject(:profile) { Magnum::Profile.new(tue: true, wed: true, thu: true, fri: true, sun: true) }
        its(:name) { should eq('Sunday, Tuesday, Wednesday, Thursday, Friday') }
      end
    end
  end

end
