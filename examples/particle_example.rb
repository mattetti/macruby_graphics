framework 'Cocoa'
HERE = File.expand_path(File.dirname(__FILE__))
require File.join(HERE, '..', 'graphics')
require File.join(HERE, 'app_wrapper')

class CustomView < NSView
  include MRGraphics

  def drawRect(rect)
    dimensions = [CGRectGetWidth(rect), CGRectGetHeight(rect)]
    Canvas.for_current_context(:size => dimensions) do |c|
      c.background(Color.black)

      # load images and grab colors
      img = Image.new(File.join(HERE, 'images', 'italy.jpg')).saturation(1.9)
      red_colors = img.colors(100)
      img = Image.new(File.join(HERE, 'images', 'v2.jpg')).saturation(1.9)
      blue_colors = img.colors(100)

      # create flower head shape
      head = Path.new.oval(0,0,10,10,:center)
      petals = 3
      petals.times do
        head.rotate(360/petals)
        head.oval(0,10,5,5,:center)
        head.oval(0,17,2,2,:center)
      end
      # randomize head attributes
      head.randomize(:fill, red_colors)
      head.randomize(:stroke, blue_colors)
      head.randomize(:scale, 0.2..2.0)
      head.randomize(:rotation, 0..360)

      # create particles
      numparticles = 200
      numframes    = 200
      particles    = []
      numparticles.times do |i|
        # start particle at random point at bottom of canvas
        x = MRGraphics.random(c.width/2 - 50, c.width/2 + 50)
        p = Particle.new(x,0)
        p.velocity_x = MRGraphics.random(-0.5,0.5) # set initial x velocity
        p.velocity_y = MRGraphics.random(1.0,3.0) # set initial y velocity
        p.acceleration = 0.1 # set drag or acceleration
        particles[i] = p # add particle to array
      end

      # animate particles
      numframes.times do |frame|
        numparticles.times do |i|
          particles[i].move
        end
      end

      # draw particle trails and heads
      numparticles.times do |i|
        c.push
        # choose a stem color
        color = MRGraphics.choose(blue_colors).a(0.7).analog(20,0.7)
        c.stroke(color)
        c.stroke_width(MRGraphics.random(0.5,2.0))

        # draw the particle
        particles[i].draw(c)
        
        # go to the last particle position and draw the flower head
        c.translate(particles[i].points[-1][0],particles[i].points[-1][1])
        c.draw(head)
        c.pop
      end
    end
  end
  
end

app = AppWrapper.new(800,600)
app.window.contentView = CustomView.alloc.initWithFrame(app.frame)
app.start