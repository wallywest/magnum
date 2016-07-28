require 'perftools'
require 'proto'
require 'factory_girl'
require 'pry'

def without_gc
  GC.disable
  yield
ensure
  GC.enable
  GC.start
end

FactoryGirl.find_definitions

@profile = Proto::SP.new(
  :time_zone => "UTC",
  :status => "new", 
  :tree => {:segments => {}},
  :labels => [],
  :segments => [],
  :allocations => []
)
@vlabels = FactoryGirl.build_list(:label, 200)
@segments = []
@allocations = []
@allocations2 = []
@s = 0
@e = 1439

@allocations << FactoryGirl.build(:allocation, :destination_id => "1", :percentage => "0")
@allocations << FactoryGirl.build(:allocation, :destination_id => "2", :percentage => "100")
@allocations << FactoryGirl.build(:allocation, :destination_id => "3", :percentage => "0")
@allocations << FactoryGirl.build(:allocation, :destination_id => "4", :percentage => "0")

@allocations2 << FactoryGirl.build(:allocation, :destination_id => "1", :percentage => "3")
@allocations2 << FactoryGirl.build(:allocation, :destination_id => "2", :percentage => "97")
@allocations2 << FactoryGirl.build(:allocation, :destination_id => "3", :percentage => "0")
@allocations2 << FactoryGirl.build(:allocation, :destination_id => "4", :percentage => "0")

@vlabels.each{|x| @profile.add_label(x)}

6.times do |x|
  if x > 0
    @s = @e + 1
    @e = @e + 1440
  end

  s1 = FactoryGirl.build(:netflix_tuesday, :start_time => @s, :end_time => @e)
  s2 = FactoryGirl.build(:netflix_other, :start_time => @s, :end_time => @e)

  @profile.add_segment(s1)
  @profile.add_segment(s2)

  @profile.labels.each do |label|
    @profile.add_allocation(s1,label,@allocations)
    @profile.add_allocation(s2,label,@allocations2)
  end
end

@profile.extend(Proto::SPRepresenter)

#without_gc do
  #puts "Rendering JSON" 
  #PerfTools::CpuProfiler.start("perf/all.profile") do
    #100.times do |n|
      #@profile.to_json
    #end
  #end
#end

binding.pry
#without_gc do
  #puts "Rendering TREE" 
  #PerfTools::CpuProfiler.start("perf/json_tree.profile") do
    #100.times do |n|
      #@profile.tree.to_json
    #end
  #end
#end

Dir.glob("perf/*.profile") do |profile|
  puts "Generating #{profile}.pdf..."
  `bundle exec pprof.rb --pdf #{profile} > #{profile}.pdf`
end
