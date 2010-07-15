framework 'Cocoa'
HERE = File.expand_path(File.dirname(__FILE__))
require File.join(HERE, '..', 'graphics')
require File.join(HERE, 'app_wrapper')

class CustomView < NSView
  include MRGraphics

  def drawRect(rect)
    dimensions = [CGRectGetWidth(rect), CGRectGetHeight(rect)]
    Canvas.for_current_context(:size => dimensions) do |canvas|
      canvas.background(Color.white)
      canvas.font('Skia')
      canvas.font_size(14)
      canvas.fill(Color.black)
      canvas.stroke(Color.red)

      # load an image
      img = Image.new(File.join(HERE, 'images', 'v2.jpg'))

      # SCALE (multiply both dimensions by a scaling factor)
      img.scale(0.2)
      canvas.draw(img, 10, 240) # draw the image at the specified coordinates
      canvas.text("scale to 20%", 10, 220)

      # FIT (scale to fit within the given dimensions, maintaining original aspect ratio)
      img.reset # first reset the image to its original size
      img.fit(100,100)
      canvas.fill(Color.white)
      canvas.rect(120,240,100,100)
      canvas.fill(Color.black)
      canvas.draw(img,143,240)
      canvas.text("fit into 100x100",130,220)

      # RESIZE (scale to fit exactly within the given dimensions)
      img.reset
      img.resize(100,100)
      canvas.draw(img,250,240)
      canvas.text("resize to 100x100",250,220)

      # CROP (to the largest square containing image data)
      img.reset
      img.scale(0.2).crop
      canvas.draw(img,10,100)
      canvas.text("crop max square",10,80)

      # CROP (within a rectangle starting at x,y with width,height)
      img.reset
      img.scale(0.3).crop(0,0,100,100)
      canvas.draw(img,130,100)
      canvas.text("crop to 100x100",130,80)

      # ROTATE
      img.origin(:center)
      img.rotate(45)
      canvas.draw(img,310,140)
      canvas.text("rotate 45 degrees",260,50)
    end
  end
  
end

app = AppWrapper.new(400,400)
app.window.contentView = CustomView.alloc.initWithFrame(app.frame)
app.start