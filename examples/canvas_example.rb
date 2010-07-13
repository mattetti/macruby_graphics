framework 'Cocoa'
here = File.expand_path(File.dirname(__FILE__))
require File.join(here, '..', 'graphics')
require File.join(here, 'app_wrapper')

class CustomView < NSView
  include MRGraphics

  def drawRect(rect)
    dimensions = [CGRectGetWidth(rect), CGRectGetHeight(rect)]
    Canvas.for_current_context(:size => dimensions) do |c|
      c.background(Color.black)
      white = Color.white
      c.fill(white)
      c.stroke(0.2)
      c.stroke_width(1)   
      c.font("Zapfino")

      80.times do 
        c.font_size rand(170)
        c.fill(white.copy.darken(rand(0.8)))
        letters = %W{ g i a n a } 
        c.text(letters[rand(letters.size)],
                rand(c.width),
                rand(c.height))
      end
    end
  end
  
end

app = AppWrapper.new
app.window.contentView = CustomView.alloc.initWithFrame(app.frame)
app.start