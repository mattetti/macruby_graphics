require 'minitest/spec'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'graphics')
MiniTest::Unit.autorun
include MRGraphics

describe "MRGraphics Canvas" do
  before do
    @destination = File.expand_path("#{File.dirname(__FILE__)}/tmp/test.png")
    @canvas = Canvas.for_image(:filename => @destination) do |c|
      c.background(Color.black)
      c.fill(Color.white)
      c.text('this is a test')
    end
  end
  
  after do
    File.delete(@destination) if File.exist?(@destination)
  end
  
  it "should have a width" do
    @canvas.width
  end
  
  it "should have a height" do
    @canvas.height
  end
  
  it "should save to a file" do
    File.delete(@destination) if File.exist?(@destination)
    @canvas.save
    File.exist?(@destination).must_equal(true)
  end
  
end