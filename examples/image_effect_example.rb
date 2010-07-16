framework 'Cocoa'
HERE = File.expand_path(File.dirname(__FILE__))
require File.join(HERE, '..', 'graphics')
require File.join(HERE, 'app_wrapper')


class CustomView < NSView
  include MRGraphics

  def drawRect(rect)
    Canvas.for_current_context(:size => [CGRectGetWidth(rect), CGRectGetHeight(rect)]) do |canvas|
      canvas.background(Color.white)
      canvas.font('Skia')
      canvas.font_size(14)
      canvas.fill(Color.black)

      # load image file
      img = Image.new(File.join(HERE, 'images', 'v2.jpg'))

      # set image width/height, starting position, and increment position
      w,h = [100,100]
      x,y = [10,290]
      x_offset = 105
      y_offset = 130

      # ORIGINAL image, resized to fit within w,h:
      img.fit(w,h)
      canvas.draw(img,x,y)
      canvas.text("original",x,y-15)
      x += x_offset

      # CRYSTALLIZE: apply a "crystallize" effect with the given radius
      img.reset.fit(w,h)
      img.crystallize(5.0)
      canvas.draw(img,x,y)
      canvas.text("crystallize",x,y-15)
      x += x_offset

      # BLOOM: apply a "bloom" effect with the given radius and intensity
      img.reset.fit(w,h)
      img.bloom(10, 1.0)
      canvas.draw(img,x,y)
      canvas.text("bloom",x,y-15)
      x += x_offset

      # EDGES: detect edges
      img.reset.fit(w,h)
      img.edges(10)
      canvas.draw(img,x,y)
      canvas.text("edges",x,y-15)
      x += x_offset

      # (go to next row)
      x = 10
      y -= y_offset

      # POSTERIZE: reduce image to the specified number of colors
      img.reset.fit(w,h)
      img.posterize(8)
      canvas.draw(img,x,y)
      canvas.text("posterize",x,y-15)
      x += x_offset

      # TWIRL: rotate around x,y with radius and angle
      img.reset.fit(w,h)
      img.twirl(35,50,40,90)
      canvas.draw(img,x,y)
      canvas.text("twirl",x,y-15)
      x += x_offset

      # EDGEWORK: simulate a woodcut print
      img.reset.fit(w,h)
      canvas.rect(x,y,img.width,img.height) # needs a black background
      img.edgework(0.5)
      canvas.draw(img,x,y)
      canvas.text("edgework",x,y-15)
      x += x_offset

      # DISPLACEMENT: use a second image as a displacement map
      img.reset.fit(w,h)
      img2 = Image.new(File.join(HERE, 'images', 'italy.jpg')).resize(img.width,img.height)
      img.displacement(img2, 30.0)
      canvas.draw(img,x,y)
      canvas.text("displacement",x,y-15)
      x += x_offset

      # (go to next row)
      x = 10
      y -= y_offset

      # DOTSCREEN: simulate a dot screen: center point, angle(0-360), width(1-50), and sharpness(0-1)
      img.reset.fit(w,h)
      img.dotscreen(0,0,45,5,0.7)
      canvas.draw(img,x,y)
      canvas.text("dotscreen",x,y-15)
      x += x_offset

      # SHARPEN: sharpen using the given radius and intensity
      img.reset.fit(w,h)
      img.sharpen(2.0,2.0)
      canvas.draw(img,x,y)
      canvas.text("sharpen",x,y-15)
      x += x_offset

      # BLUR: apply a gaussian blur with the given radius
      img.reset.fit(w,h)
      img.blur(3.0)
      canvas.draw(img,x,y)
      canvas.text("blur",x,y-15)
      x += x_offset

      # MOTION BLUR: apply a motion blur with the given radius and angle
      img.reset.fit(w,h)
      img.motionblur(10.0,90)
      canvas.draw(img,x,y)
      canvas.text("motion blur",x,y-15)
      x += x_offset
    end
   end

end

app = AppWrapper.new(410,400)
app.window.contentView = CustomView.alloc.initWithFrame(app.frame)
app.start