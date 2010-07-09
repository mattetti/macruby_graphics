framework 'Cocoa'
require '../graphics'
include MRGraphics

img = Canvas.for_image(:size => [400,400]) do
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

# set the image viewer
viewer = IKImageView.alloc.initWithFrame(frame)
viewer.setImage(img.cgimage, imageProperties: {})
window.contentView.addSubview(viewer)

# show the window
window.display
window.makeKeyAndOrderFront(nil)
window.orderFrontRegardless
app.run