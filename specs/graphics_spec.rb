require 'minitest/spec'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'graphics')
MiniTest::Unit.autorun

describe 'MRGraphics module methods' do

  it "should convert degrees to radians" do
    MRGraphics.radians(30).must_be_close_to(0.523598776)
    MRGraphics.radians(90).must_be_close_to(1.57079633)
    MRGraphics.radians(360).must_be_close_to(6.28318531)
  end
  
  it "should convert radians to degrees" do
    MRGraphics.degrees(0.523598776).must_be_close_to(30)
    MRGraphics.degrees(1.57079633).must_be_close_to(90)
    MRGraphics.degrees(6.28318531).must_be_close_to(360)
  end
  
  it "should calculate the angle of the line joining two points" do
    MRGraphics.angle(0,0, 10,0).must_be_close_to(0)
    MRGraphics.angle(0,0, 10,10).must_be_close_to(45)
    MRGraphics.angle(0,0, 0,10).must_be_close_to(90)
  end
  
  it "should calculate the distance between 2 points" do
    MRGraphics.distance(0,0, 10,0).must_be_close_to(10)
    MRGraphics.distance(0,0, 10,10).must_be_close_to(14.14, 0.1)
  end
  
  it "should calculate the coordinate of a new point" do
    point = MRGraphics.coordinates(0, 0, 10, 45)
    point.first.must_be_close_to(7.07, 0.1)
    point.last.must_be_close_to(7.07, 0.1)
  end
  
  it "should let you randomly choose an integer from a range" do
    from_range = MRGraphics.choose(0..100)
    from_range.must_be_instance_of(Fixnum)
    (0..100).must_include(from_range)
    randoms = []
    50.times{randoms << MRGraphics.choose(0..1000) }
    randoms.uniq.size.must_be_close_to(randoms.size, 5)
  end
  
  it "should let you randomly choose a float from a range" do
    from_range = MRGraphics.choose(0.0..10.0)
    from_range.must_be_instance_of(Float)
    (0.0..10.0).must_include(from_range)
    randoms = []
    50.times{randoms << MRGraphics.choose(0.0..100.0) }
    randoms.uniq.size.must_be_close_to(randoms.size, 5)
  end
  
  it "should let you randomly choose an item from an array" do
    from_range = MRGraphics.choose([1,2,3,4,5])
    from_range.must_be_instance_of(Fixnum)
    (1..5).must_include(from_range)
  end
  
  it "should return the point to reorient an item" do
    new_location = MRGraphics.reorient(0, 0, 100, 100, :center)
    new_location.must_be_instance_of(Array)
    new_location.first.must_be_same_as(-50)
    new_location.last.must_be_same_as(-50)
  end
  
end
