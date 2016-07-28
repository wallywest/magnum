def netflix_profile
  @profile = Magnum::SP.new(
    :time_zone => "UTC",
    :status => "new", 
    :tree => {},
    :labels => [],
    :segments => [],
    :allocations => []
  )
  @vlabels = FactoryGirl.build_list(:label, 200)
  @segments = []
  @allocations = []
  @allocations2 = []
  @s = 0
  @e = 59

  @allocations << FactoryGirl.build(:allocation, :destination_id => "1", :percentage => "0")
  @allocations << FactoryGirl.build(:allocation, :destination_id => "2", :percentage => "100")
  @allocations << FactoryGirl.build(:allocation, :destination_id => "3", :percentage => "0")
  @allocations << FactoryGirl.build(:allocation, :destination_id => "4", :percentage => "0")

  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "1", :percentage => "3")
  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "2", :percentage => "97")
  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "3", :percentage => "0")
  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "4", :percentage => "0")

  @vlabels.each{|x| @profile.add_label(x)}

  def bytesToMeg(bytes)
    bytes/MEGABYTE
  end

  24.times do |x|
    if x > 0
      @s = @e + 1
      @e = @e + 60
    end

    s1 = FactoryGirl.build(:netflix_tuesday, :start_time => @s, :end_time => @e)
    s2 = FactoryGirl.build(:netflix_other, :start_time => @s, :end_time => @e)

    @profile.add_segment(s1)
    @profile.add_segment(s2)

    @profile.labels.each do |label|
      @profile.add_multiple_allocations(s1,label,@allocations)
      @profile.add_multiple_allocations(s2,label,@allocations2)
    end
  end

  @profile
end

def regular_profile
  @profile = Magnum::SP.new(
    :time_zone => "UTC",
    :status => "new", 
    :tree => {},
    :labels => [],
    :segments => [],
    :allocations => []
  )

  @vlabels = FactoryGirl.build_list(:label, 20)
  @segments = []
  @allocations = []
  @allocations2 = []

  @vlabels.each{|x| @profile.add_label(x)}

  @allocations << FactoryGirl.build(:allocation, :destination_id => "1", :percentage => "0")
  @allocations << FactoryGirl.build(:allocation, :destination_id => "2", :percentage => "100")
  @allocations << FactoryGirl.build(:allocation, :destination_id => "3", :percentage => "0")
  @allocations << FactoryGirl.build(:allocation, :destination_id => "4", :percentage => "0")

  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "1", :percentage => "3")
  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "2", :percentage => "97")
  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "3", :percentage => "0")
  @allocations2 << FactoryGirl.build(:allocation, :destination_id => "4", :percentage => "0")

  s1 = FactoryGirl.build(:netflix_tuesday, :start_time => 0, :end_time => 1439)
  s2 = FactoryGirl.build(:netflix_other, :start_time => 0, :end_time => 1439)

  @profile.add_segment(s1)
  @profile.add_segment(s2)

  @profile.labels.each do |label|
    @profile.add_multiple_allocations(s1,label,@allocations)
    @profile.add_multiple_allocations(s2,label,@allocations2)
  end

  @profile
end

def simple_profile
  @profile = Magnum::SP.new(
    :time_zone => "UTC",
    :status => "new", 
    :tree => {},
    :labels => [],
    :segments => [],
    :allocations => []
  )

  @vlabels = FactoryGirl.build_list(:label, 1)
  @segments = []
  @allocations = []

  @vlabels.each{|x| @profile.add_label(x)}

  @allocations << FactoryGirl.build(:allocation, :destination_id => "1", :percentage => "50")
  @allocations << FactoryGirl.build(:allocation, :destination_id => "2", :percentage => "50")

  s1 = FactoryGirl.build(:netflix_tuesday, :start_time => 0, :end_time => 719)
  s2 = FactoryGirl.build(:netflix_tuesday, :start_time => 720, :end_time => 1439)
  s3 = FactoryGirl.build(:netflix_other, :start_time => 0, :end_time => 1439)

  @profile.add_segment(s1)
  @profile.add_segment(s2)
  @profile.add_segment(s3)

  @profile.labels.each do |label|
    @profile.add_multiple_allocations(s1,label,@allocations)
    @profile.add_multiple_allocations(s2,label,@allocations)
    @profile.add_multiple_allocations(s3,label,@allocations)
  end

  @profile
end
