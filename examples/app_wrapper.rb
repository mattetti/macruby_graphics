class AppWrapper
  
  attr_reader :app, :window, :frame
  
  class AppDelegate
    def applicationDidFinishLaunching(notification)
    end
  
    def windowWillClose(notification)
      puts "Bye!"
      exit
    end
  end

  def initialize(width=400, height=400)
    @app = NSApplication.sharedApplication
    @app.delegate = AppDelegate.new
    @frame  = [0.0, 0.0, width,height]

    # window
    @window = NSWindow.alloc.initWithContentRect(frame,
        styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask, 
        backing:NSBackingStoreBuffered, 
        defer:false)
    @window.delegate = app.delegate
  end
  
  def start
    window.center
    window.display
    window.makeKeyAndOrderFront(nil)
    window.orderFrontRegardless
    app.run
  end

end