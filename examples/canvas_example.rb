framework 'Cocoa'
here = File.expand_path(File.dirname(__FILE__))
require File.join(here, '..', 'graphics')
require File.join(here, 'app_wrapper')

class CustomView < NSView
  include MRGraphics

  def drawRect(rect)
    canvas = Canvas.for_image(:size => [400,400]) do
      background(Color.black)

      white = Color.white
      fill(white)
      stroke(0.2)
      strokewidth(1)   
      font("Zapfino")

      80.times do 
        fontsize rand(170)
        fill(white.copy.darken(rand(0.8)))
        letters = %W{ g i a n a } 
        text(letters[rand(letters.size)],
             rand(width),
             rand(height))
      end
    end
    
    # set the image viewer
    img = NSImage.alloc.initWithCGImage(canvas.cgimage, size: NSZeroSize)
    img.drawAtPoint([0,0], fromRect: NSZeroRect, operation: NSCompositeSourceOver, fraction: 1)
  end
  
end

# wrapper class to keep the examples as clean/simple as possible
app = AppWrapper.new
# assign an instance of our custiom NSView to the window's content view
app.window.contentView = CustomView.alloc.initWithFrame(app.frame)
# start the app
app.start