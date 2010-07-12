# MacRuby Graphics 

MacRuby Graphics is a graphics library providing a simple object-oriented 
interface into the power of Mac OS X's Core Graphics and Core Image drawing libraries.  
With a few lines of easy-to-read code, you can write scripts to draw simple or complex 
shapes, lines, and patterns, process and filter images, create abstract art or visualize 
scientific data, and much more.

Inspiration for this project was derived from Processing and NodeBox.  These excellent 
graphics programming environments are more full-featured than MRG, but they are implemented 
in Java and Python, respectively.  MRG was created to offer similar functionality using 
the Ruby programming language.

The original author of this library is James Reynolds, MacRuby was then called Ruby Cocoa Graphics
and was packaged as part of Hotcocoa. I made the choice to extract it, add more examples and specs
so MacRuby developers could use this library as an addon to their projects without needing HotCocoa.

## Examples

You can see a list of examples in the examples folder, but here is a quick sample:

    class CustomView < NSView
      include MRGraphics

      def drawRect(rect)
        canvas = Canvas.for_image(:size => [400,400]) do |c|
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