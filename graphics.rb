# MacRuby Graphics is a graphics library providing a simple object-oriented 
# interface into the power of Mac OS X's Core Graphics and Core Image drawing libraries.  
# With a few lines of easy-to-read code, you can write scripts to draw simple or complex 
# shapes, lines, and patterns, process and filter images, create abstract art or visualize 
# scientific data, and much more.
# 
# Inspiration for this project was derived from Processing and NodeBox.  These excellent 
# graphics programming environments are more full-featured than MRG, but they are implemented 
# in Java and Python, respectively.  MRG was created to offer similar functionality using 
# the Ruby programming language.
#
# Author::    James Reynolds  (mailto:drtoast@drtoast.com), Matt Aimonetti
# Copyright:: Copyright (c) 2008 James Reynolds
# License::   Distributes under the same terms as Ruby 

# More information about Quartz 2D is available on the Apple's website:
# http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_overview/dq_overview.html#//apple_ref/doc/uid/TP30001066-CH202-TPXREF101

framework 'Cocoa'
framework 'Quartz'
framework 'CoreGraphics'

module MRGraphics

  # UTILITY FUNCTIONS (math/geometry)
  TEST = 'OK'

  # convert degrees to radians
  def self.radians(deg)
    deg * (Math::PI / 180.0)
  end

  # convert radians to degrees
  def self.degrees(rad)
    rad * (180 / Math::PI)
  end

  # return the angle of the line joining the two points
  def self.angle(x0, y0, x1, y1)
    degrees(Math.atan2(y1-y0, x1-x0))
  end

  # return the distance between two points
  def self.distance(x0, y0, x1, y1)
    Math.sqrt((x1-x0)**2 + (y1-y0)**2)
  end

  # return the coordinates of a new point at the given distance and angle from a starting point
  def self.coordinates(x0, y0, distance, angle)
    x1 = x0 + Math.cos(radians(angle)) * distance
    y1 = y0 + Math.sin(radians(angle)) * distance
    [x1,y1]
  end

  # return the lesser of a,b
  def self.min(a, b)
    a < b ? a : b
  end

  # return the greater of a,b
  def self.max(a, b)
    a > b ? a : b
  end

  # restrict the value to stay within the range
  def self.in_range(value, min, max)
    if value < min
      min
    elsif value > max
      max
    else
      value
    end
  end

  # return a random number within the range, or a float from 0 to the number
  def self.random(left=nil, right=nil)
    if right
      rand * (right - left) + left
    elsif left
      rand * left
    else
      rand
    end
  end

  def self.reflect(x0, y0, x1, y1, d=1.0, a=180)
    d *= distance(x0, y0, x1, y1)
    a += angle(x0, y0, x1, y1)
    x, y = coordinates(x0, y0, d, a)
    [x,y]
  end

  def self.choose(object)
    case object
    when Range
      case object.first
      when Float
        rand * (object.last - object.first) + object.first
      when Integer
        rand(object.last - object.first + 1) + object.first
      end
    when Array
      object.sample
    else
      object
    end
  end

  # given an object's x,y coordinates and dimensions, return the distance 
  # needed to move in order to orient the object at the given location (:center, :bottom_left, etc)
  def self.reorient(x, y, w, h, location)
    case location
    when :bottom_left
      move_x = -x
      move_y = -y
    when :center_left
      move_x = -x
      move_y = -y - h / 2
    when :top_left
      move_x = -x
      move_y = -x - h
    when :bottom_right
      move_x = -x - w
      move_y = -y
    when :center_right
      move_x = -x - w
      move_y = -y - h / 2
    when :top_right
      move_x = -x - w
      move_y = -y - h
    when :bottom_center
      move_x = -x - w / 2
      move_y = -y
    when :center
      move_x = -x - w / 2
      move_y = -y - h / 2
    when :top_center
      move_x = -x - w / 2
      move_y = -y - h
    else
      raise "ERROR: image origin locator not recognized: #{location}"
    end
    [move_x,move_y]
  end

end

here = File.expand_path(File.dirname(__FILE__))
require File.join(here, 'lib', 'canvas')
require File.join(here, 'lib', 'color')
require File.join(here, 'lib', 'gradient')
require File.join(here, 'lib', 'image')
require File.join(here, 'lib', 'path')
require File.join(here, 'lib', 'pdf')
require File.join(here, 'lib', 'elements/particle')
require File.join(here, 'lib', 'elements/rope')
require File.join(here, 'lib', 'elements/sandpainter')