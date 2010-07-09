framework 'Cocoa'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'graphics')


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
        letters = %W{ g i a n a} 
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

class AppDelegate
  def applicationDidFinishLaunching(notification)
  end
  
  def windowWillClose(notification)
    puts "Bye!"
    exit
  end
  
end

app = NSApplication.sharedApplication
app.delegate = AppDelegate.new
frame  = [0.0, 0.0, 400, 400]

# window
window = NSWindow.alloc.initWithContentRect(frame,
    styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask, 
    backing:NSBackingStoreBuffered, 
    defer:false)
window.delegate = app.delegate

# assign a content view instance
content_view = CustomView.alloc.initWithFrame(frame)
window.contentView = content_view

# show the window
window.display
window.makeKeyAndOrderFront(nil)
window.orderFrontRegardless
app.run