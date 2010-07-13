framework 'Cocoa'
HERE = File.expand_path(File.dirname(__FILE__))
require File.join(HERE, '..', 'graphics')
require File.join(HERE, 'app_wrapper')


class CustomView < NSView
  include MRGraphics

  def drawRect(rect)
    Canvas.for_current_context(:size => [CGRectGetWidth(rect), CGRectGetHeight(rect)]) do |c|
      c.background(Color.white)
      c.font('Skia')
      c.font_size(14)
      c.fill(Color.black)

      # load image
      img     = Image.new(File.join(HERE, 'images', 'v2.jpg'))
      w,h     = [100,100]
      x,y     = [10,290]
      x_offset = 105
      y_offset = 130

      # original image, resized to fit within w,h:
      img.fit(w,h)
      c.draw(img,x,y)
      c.text("original",x,y-15)
      x += x_offset

      # HUE: rotate color wheel by degrees
      img.reset.fit(w,h)
      img.hue(45)
      c.draw(img,x,y)
      c.text("hue",x,y-15)
      x += x_offset

      # EXPOSURE: increase/decrease exposure by f-stops
      img.reset.fit(w,h)
      img.exposure(1.0)
      c.draw(img,x,y)
      c.text("exposure",x,y-15)
      x += x_offset

      # SATURATION: adjust saturation by multiplier
      img.reset.fit(w,h)
      img.saturation(2.0)
      c.draw(img,x,y)
      c.text("saturation",x,y-15)
      x += x_offset

      # (go to next row)
      x = 10
      y -= y_offset

      # CONTRAST: adjust contrast by multiplier
      img.reset.fit(w,h)
      img.contrast(2.0)
      c.draw(img,x,y)
      c.text("contrast",x,y-15)
      x += x_offset

      # BRIGHTNESS: adjust brightness
      img.reset.fit(w,h)
      img.brightness(0.5)
      c.draw(img,x,y)
      c.text("brightness",x,y-15)
      x += x_offset

      # MONOCHROME: convert to a monochrome image
      img.reset.fit(w,h)
      img.monochrome(Color.orange)
      c.draw(img,x,y)
      c.text("monochrome",x,y-15)
      x += x_offset

      # WHITEPOINT: remap the white point
      img.reset.fit(w,h)
      img.whitepoint(Color.white.ish)
      c.draw(img,x,y)
      c.text("white point",x,y-15)
      x += x_offset

      # (go to next row)
      x = 10
      y -= y_offset

      # CHAINING: apply multiple effects at once
      img.reset.fit(w,h)
      img.hue(60).saturation(2.0).contrast(2.5)
      c.draw(img,x,y)
      c.text("multi effects",x,y-15)
      x += x_offset

      # COLORS: sample random colors from the image and render as a gradient
      img.reset.fit(w,h) # reset the image and scale to fit within w,h
      colors = img.colors(10).sort! # select 10 random colors and sort by brightness
      # gradient
      gradient = Gradient.new(colors) # create a new gradient using the selected colors
      rect = Path.new.rect(x,y,img.width,img.height) # create a rectangle the size of the image
      c.begin_clip(rect) # begin clipping so the gradient will only fill the rectangle
      c.gradient(gradient,x,y,x+img.width,y+img.height) # draw the gradient between opposite corners of the rectangle
      c.end_clip # end clipping so we can draw on the rest of the canvas
      c.text("get colors",x,y-15) # add text label
      x += x_offset
    end
   end

end

# wrapper class to keep the examples as clean/simple as possible
app = AppWrapper.new(410,400)
# assign an instance of our custiom NSView to the window's content view
app.window.contentView = CustomView.alloc.initWithFrame(app.frame)
# start the app
app.start
