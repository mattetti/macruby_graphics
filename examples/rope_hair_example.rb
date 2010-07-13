framework 'Cocoa'
HERE = File.expand_path(File.dirname(__FILE__))
require File.join(HERE, '..', 'graphics')
require File.join(HERE, 'app_wrapper')

class CustomView < NSView
  include MRGraphics

  def drawRect(rect)
    dimensions = [CGRectGetWidth(rect), CGRectGetHeight(rect)]
    Canvas.for_current_context(:size => dimensions) do |canvas|
      # choose a random color and set the background to a darker variant
      clr = Color.random.a(0.5)
      canvas.background(clr.copy.darken(0.6))

      # create a new rope with 200 fibers
      rope = Rope.new(canvas, :width => 100, :fibers => 200, :strokewidth => 0.4, :roundness => 3.0)

      # randomly rotate the canvas from its center
      canvas.translate(canvas.width/2, canvas.height/2)
      canvas.rotate(MRGraphics.random(0, 360))
      canvas.translate(-canvas.width/2, -canvas.height/2)

      # draw 20 ropes
      ropes = 20
      ropes.times do
        canvas.stroke(clr.copy.analog(20, 0.8)) # rotate hue up to 20 deg left/right, vary brightness/saturation by up to 70%
        rope.x0 = -100 # start rope off bottom left of canvas
        rope.y0 = -100
        rope.x1 = canvas.width + 100 # end rope off top right of canvas
        rope.y1 = canvas.height + 100
        rope.hair # draw rope in organic ‚Äúhair‚Äù style
      end

    end
  end
  
end

app = AppWrapper.new(400,400)
app.window.contentView = CustomView.alloc.initWithFrame(app.frame)
app.start