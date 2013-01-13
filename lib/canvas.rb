# MacRuby Graphics is a graphics library providing a simple object-oriented 
# interface into the power of Mac OS X's Core Graphics and Core Image drawing libraries.  
# With a few lines of easy-to-read code, you can write scripts to draw simple or complex 
# shapes, lines, and patterns, process and filter images, create abstract art or visualize 
# scientific data, and much more.
# 
# Inspiration for this project was derived from Processing and NodeBox.  These excellent 
# graphics programming environments are more full-featured than RCG, but they are implemented 
# in Java and Python, respectively.  RCG was created to offer similar functionality using 
# the Ruby programming language.
#
# Author::    James Reynolds  (mailto:drtoast@drtoast.com), Matt Aimonetti
# Copyright:: Copyright (c) 2008 James Reynolds
# License::   Distributes under the same terms as Ruby 

# In Quartz 2D, the canvas is often referred as the "page".
# Overview of the underlying page concept available at:
# http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_overview/dq_overview.html#//apple_ref/doc/uid/TP30001066-CH202-TPXREF101


module MRGraphics

  # drawing destination for writing a PDF, PNG, GIF, JPG, or TIF file
  class Canvas
    
    BlendModes = {
      :normal     => KCGBlendModeNormal,
      :darken     => KCGBlendModeDarken,
      :multiply   => KCGBlendModeMultiply,
      :screen     => KCGBlendModeScreen,
      :overlay    => KCGBlendModeOverlay,
      :darken     => KCGBlendModeDarken,
      :lighten    => KCGBlendModeLighten,
      :colordodge => KCGBlendModeColorDodge,
      :colorburn  => KCGBlendModeColorBurn,
      :softlight  => KCGBlendModeSoftLight,
      :hardlight  => KCGBlendModeHardLight,
      :difference => KCGBlendModeDifference,
      :exclusion  => KCGBlendModeExclusion,
      :hue        => KCGBlendModeHue,
      :saturation => KCGBlendModeSaturation,
      :color      => KCGBlendModeColor,
      :luminosity => KCGBlendModeLuminosity,
    }
    BlendModes.default(KCGBlendModeNormal)
    
    DefaultOptions = {:quality => 0.8, :width => 400, :height => 400}
  
    attr_accessor :width, :height  
    
    # We make the context available so developers can directly use underlying CG methods
    # on objects created by this wrapper
    attr_reader :ctx
    
    class << self
      def for_rendering(options={}, &block)
        options[:type] = :render
        Canvas.new(options, &block)
      end
      
      def for_pdf(options={}, &block)
        options[:type] = :pdf
        Canvas.new(options, &block)
      end
      
      def for_image(options={}, &block)
        options[:type] = :image
        Canvas.new(options, &block)
      end
      
      def for_context(options={}, &block)
        options[:type] = :context
        Canvas.new(options, &block)
      end
      
      def for_current_context(options={}, &block)
        options[:type] = :context
        options[:context] = NSGraphicsContext.currentContext.graphicsPort
        Canvas.new(options, &block)
      end
      
    end
  
    class ParamsError < StandardError; end
  
    # create a new canvas with the given width, height, and output filename (pdf, png, jpg, gif, or tif)
    def initialize(options={}, &block)
      if options[:size]
        options[:width]  = options[:size][0]
        options[:height] = options[:size][1]
      end
      options = DefaultOptions.merge(options)
    
      @width         = options[:width]
      @height        = options[:height]
      @output        = options[:filename] || 'test'
      @stacksize     = 0
      @colorspace    = CGColorSpaceCreateDeviceRGB() # => CGColorSpaceRef
      @autoclose_path = false
    
      case options[:type]
      when :pdf
        @filetype  = :pdf
        # CREATE A PDF DRAWING CONTEXT
        url        = CFURLCreateFromFileSystemRepresentation(nil, @output, @output.length, false)
        pdfrect    = CGRect.new(CGPoint.new(0, 0), CGSize.new(width, height)) # Landscape
        consumer   = CGDataConsumerCreateWithURL(url);
        pdfcontext = CGPDFContextCreate(consumer, pdfrect, nil);
        CGPDFContextBeginPage(pdfcontext, nil)
        @ctx       = pdfcontext
      when :image, :render
        # CREATE A BITMAP DRAWING CONTEXT
        if options[:type] == :image
          extension = File.extname(@output).downcase[1..-1]
          @filetype = extension.to_sym unless extension.nil?
        end
        @bits_per_component = 8
        @colorspace         = CGColorSpaceCreateDeviceRGB() # => CGColorSpaceRef
        #alpha              = KCGImageAlphaNoneSkipFirst # opaque background
        alpha               = KCGImageAlphaPremultipliedFirst # transparent background
        # 8 integer bits/component; 32 bits/pixel; 3-component colorspace; kCGImageAlphaPremultipliedFirst; 57141 bytes/row.
        bytes = @bits_per_component * 4 * @width.ceil
        @ctx  = CGBitmapContextCreate(nil, @width, @height, @bits_per_component, bytes, @colorspace, alpha) # =>  CGContextRef
      when :context
        @ctx  = options[:context]
      else
        raise ParamsError, "The output file type #{ext} was not recognized"
      end

      # antialiasing
      CGContextSetAllowsAntialiasing(@ctx, true)

      # set defaults
      fill            # set the default fill
      no_stroke       # no stroke by default
      stroke_width    # set the default stroke width
      font            # set the default font
      antialias       # set the default antialias state
      autoclose_path! # set the autoclosepath default
      quality(options[:quality])   # set the compression default
      push            # save the pristine default graphics state (retrieved by calling "reset")
      push            # create a new graphics state for the user to mess up
      block.call(self) if block_given?
    end

    # SET CANVAS GLOBAL PARAMETERS

    # print drawing functions if verbose is true
    def verbose(tf=true)
      @verbose = tf
    end
  
    # set whether or not drawn paths should be antialiased (true/false)
    def antialias(tf=true)
      CGContextSetShouldAntialias(@ctx, tf)
    end
  
    # set the alpha value for subsequently drawn objects
    def alpha(val=1.0)
      CGContextSetAlpha(@ctx, val)
    end
  
    # set compression (0.0 = max, 1.0 = none)
    def quality(factor=0.8)
      @quality = factor
    end
  
    # set the current fill (given a Color object, or RGBA values)
    def fill(r=0, g=0, b=0, a=1)
      case r
      when Color
        g = r.g
        b = r.b
        a = r.a
        r = r.r
      end
      CGContextSetRGBFillColor(@ctx, r, g, b, a) # RGBA
      @fill = true
    end
  
    # remove current fill
    def no_fill
      CGContextSetRGBFillColor(@ctx, 0.0, 0.0, 0.0, 0.0) # RGBA
      @fill = nil
    end
  
    # SET CANVAS STROKE PARAMETERS
  
    # set stroke color (given a Color object, or RGBA values)
    def stroke(r=0, g=0, b=0, a=1.0)
      case r
      when Color
        g = r.g
        b = r.b
        a = r.a
        r = r.r
      end
      CGContextSetRGBStrokeColor(@ctx, r, g, b, a) # RGBA
      @stroke = true
    end

    # don't use a stroke for subsequent drawing operations
    def no_stroke
      CGContextSetRGBStrokeColor(@ctx, 0, 0, 0, 0) # RGBA
      @stroke = false
    end
      
    # set stroke width
    def stroke_width(width=1)
      CGContextSetLineWidth(@ctx, width.to_f)
    end
  
    # set cap style to round, square, or butt
    def line_cap(style=:butt)
      case style
      when :round
        cap = KCGLineCapRound
      when :square
        cap = KCGLineCapSquare
      when :butt
        cap = KCGLineCapButt
      else
        raise "ERROR: line cap style not recognized: #{style}"
      end
      CGContextSetLineCap(@ctx,cap)
    end
  
    # set line join style to round, miter, or bevel
    def line_join(style=:miter)
      case style
      when :round
        join = KCGLineJoinRound
      when :bevel
        join = KCGLineJoinBevel
      when :miter
        join = KCGLineJoinMiter
      else
        raise "ERROR: line join style not recognized: #{style}"
      end
      CGContextSetLineJoin(@ctx,join)
    end
  
    # set lengths of dashes and spaces, and distance before starting dashes
    def line_dash(lengths=[10,2], phase=0.0)
      count=lengths.size
      CGContextSetLineDash(@ctx, phase, lengths, count)
    end
  
    # revert to solid lines
    def no_dash
      CGContextSetLineDash(@ctx, 0.0, nil, 0)
    end
  
    # DRAWING SHAPES ON CANVAS
    
    # draw a rectangle starting at x,y and having dimensions w,h
    def rect(x=0, y=0, w=20, h=20, reg=@registration)
      # center the rectangle
      if (reg == :center)
        x = x - w / 2
        y = y - h / 2
      end
      CGContextAddRect(@ctx, NSMakeRect(x, y, w, h))
      CGContextDrawPath(@ctx, KCGPathFillStroke)
    end
  
    # inscribe an oval starting at x,y inside a rectangle having dimensions w,h
    def oval(x=0, y=0, w=20, h=20, reg=@registration)
      # center the oval
      if (reg == :center)
        x = x - w / 2
        y = y - w / 2
      end
      CGContextAddEllipseInRect(@ctx, NSMakeRect(x, y, w, h))
      CGContextDrawPath(@ctx, KCGPathFillStroke) # apply fill and stroke
    end
  
    # draw a background color (given a Color object, or RGBA values)
    def background(r=1, g=1, b=1, a=1.0)
      case r
      when Color
        g = r.g
        b = r.b
        a = r.a
        r = r.r
      end
      push
      CGContextSetRGBFillColor(@ctx, r, g, b, a) # RGBA
      rect(0,0,@width,@height)
      pop
    end
  
    # draw a radial gradiant starting at sx,sy with radius er
    # optional: specify ending at ex,ey and starting radius sr
    def radial(gradient, sx=@width/2, sy=@height/2, er=@width/2, ex=sx, ey=sy, sr=0.0)
      #options = KCGGradientDrawsBeforeStartLocation
      #options = KCGGradientDrawsAfterEndLocation
      CGContextDrawRadialGradient(@ctx, gradient.gradient, NSMakePoint(sx, sy), sr, NSMakePoint(ex, ey), er, gradient.pre + gradient.post)
    end
  
    # draw an axial(linear) gradient starting at sx,sy and ending at ex,ey
    def gradient(gradient=Gradient.new, start_x=@width/2, start_y=0, end_x=@width/2, end_y=@height)
      #options = KCGGradientDrawsBeforeStartLocation
      #options = KCGGradientDrawsAfterEndLocation
      CGContextDrawLinearGradient(@ctx, gradient.gradient, NSMakePoint(start_x, start_y), NSMakePoint(end_x, end_y), gradient.pre + gradient.post)
    end

    # draw a cartesian coordinate grid for reference
    def cartesian(res=50, stroke=1.0, fsize=10)
      # save previous state
      new_state do
        # set font and stroke
        font_size(fsize)
        fill(Color.black)
        stroke(Color.red)
        stroke_width(stroke)
        # draw vertical numbered grid lines
        (-width / res)..(width / res).each do |x|
          line(x * res, -height, x * res, height)
          text("#{x * res}", x * res, 0)
        end
        # draw horizontal numbered grid lines
        (-height / res)..(height / res).each do |y|
          line(-width, y * res, width, y * res)
          text("#{y * res}", 0, y * res)
        end
        # draw lines intersecting center of canvas
        stroke(Color.black)
        line(-width, -height, width, height)
        line(width, -height, -width, height)
        line(0, height, width, 0)
        line(width / 2, 0, width / 2, height)
        line(0, height / 2, width, height / 2)
        # restore previous state
      end
    end
  
  
    # DRAWING COMPLETE PATHS TO CANVAS
  
    # draw a line starting at x1,y1 and ending at x2,y2
    def line(x1, y1, x2, y2)
      CGContextAddLines(@ctx, [NSPoint.new(x1, y1), NSPoint.new(x2, y2)], 2)
      CGContextDrawPath(@ctx, KCGPathStroke) # apply stroke
      end_path
    end
  
    # draw a series of lines connecting the given array of points
    def lines(points)
      CGContextAddLines(@ctx, points, points.size)
      CGContextDrawPath(@ctx, KCGPathStroke) # apply stroke
      end_path
    end
  
    # draw the arc of a circle with center point x,y, radius, start angle (0 deg = 12 o'clock) and end angle
    def arc(x, y, radius, start_angle, end_angle)
      start_angle = MRGraphics.radians(90-start_angle)
      end_angle = MRGraphics.radians(90-end_angle)
      clockwise = 1 # 1 = clockwise, 0 = counterclockwise
      CGContextAddArc(@ctx, x, y, radius, start_angle, end_angle, clockwise)
      CGContextDrawPath(@ctx, KCGPathStroke)
    end

    # draw the arc of a circle with center point x,y, radius, start angle (0 deg = 12 o'clock) and end angle
    def circle(x, y, radius)
      CGContextAddArc(@ctx, x, y, radius, 0, 2*Math::PI, 1)
      CGContextDrawPath(@ctx, KCGPathFillStroke)
    end
  
    # draw a bezier curve from the current point, given the coordinates of two handle control points and an end point
    def curve(cp1x, cp1y, cp2x, cp2y, x1, y1, x2, y2)
      begin_path(x1, y1)
      CGContextAddCurveToPoint(@ctx, cp1x, cp1y, cp2x, cp2y, x2, y2)
      end_path
    end
  
    # draw a quadratic bezier curve from x1,y1 to x2,y2, given the coordinates of one control point
    def qcurve(cpx, cpy, x1, y1, x2, y2)
      begin_path(x1, y1)
      CGContextAddQuadCurveToPoint(@ctx, cpx, cpy, x2, y2)
      end_path
    end
  
    # draw the given Path object
    def draw(object, *args)
      case object
      when Path
        draw_path(object, *args)
      when Image
        draw_image(object, *args)
      else
        raise ArgumentError, "first parameter must be a Path or Image object not a #{object.class}"
      end
    end

    # CONSTRUCTING PATHS ON CANVAS

    # automatically close the path after it is ended
    def autoclose_path!
      @autoclose_path = true
    end
    
    def autoclose_path=(bool)
      if bool == true
        autoclose_path!
      else
        @autoclose_path = false
      end
    end
    
    def new_path(x, y, &block)
      begin_path(x, y)
      block.call
      end_path
    end
    
    # begin drawing a path at x,y
    def begin_path(x, y)
      CGContextBeginPath(@ctx)
      CGContextMoveToPoint(@ctx, x, y)
    end

    # end the current path and draw it
    def end_path
      return if CGContextIsPathEmpty(@ctx)
      CGContextClosePath(@ctx) if @autoclose_path
      mode = KCGPathFillStroke
      CGContextDrawPath(@ctx, mode) # apply fill and stroke
    end
  
    # move the "pen" to x,y
    def move_to(x, y)
      CGContextMoveToPoint(@ctx, x, y)
    end

    # draw a line from the current point to x,y
    def line_to(x, y)
      CGContextAddLineToPoint(@ctx ,x, y)
    end
  
    # draw a bezier curve from the current point, given the coordinates of two handle control points and an end point
    def curve_to(cp1x, cp1y, cp2x, cp2y, x, y)
      CGContextAddCurveToPoint(@ctx, cp1x, cp1y, cp2x, cp2y, x, y)
    end

    # draw a quadratic bezier curve from the current point, given the coordinates of one control point and an end point
    def qcurve_to(cpx, cpy, x, y)
      CGContextAddQuadCurveToPoint(@ctx, cpx, cpy, x, y)
    end
  
    # draw an arc given the endpoints of two tangent lines and a radius
    def arc_to(x1, y1, x2, y2, radius)
      CGContextAddArcToPoint(@ctx, x1, y1, x2, y2, radius)
    end
    
    # draw the path in a grid with rows, columns
    def grid(path, rows=10, cols=10)
      push
      rows.times do |row|
        tx = (row+1) * (self.height / rows) - (self.height / rows) / 2
        cols.times do |col|
          ty = (col+1) * (self.width / cols) - (self.width / cols) / 2
          push
          translate(tx, ty)
          draw(path)
          pop
        end
      end
      pop
    end
  

    # TRANSFORMATIONS
  
    # set registration mode to :center or :corner
    def registration(mode=:center)
      @registration = mode
    end
  
    # rotate by the specified degrees
    def rotate(deg=0)
      CGContextRotateCTM(@ctx, MRGraphics.radians(-deg));
    end
  
    # translate drawing context by x,y
    def translate(x, y)
      CGContextTranslateCTM(@ctx, x, y);
    end
  
    # scale drawing context by x,y
    def scale(x, y=x)
      CGContextScaleCTM(@ctx, x, y)
    end
  
    def skew(x=0, y=0)
      x = Math::PI * x / 180.0
      y = Math::PI * y / 180.0
      transform = CGAffineTransformMake(1.0, Math::tan(y), Math::tan(x), 1.0, 0.0, 0.0)
      CGContextConcatCTM(@ctx, transform)
    end
  
  
    # STATE
    
    def new_state(&block)
      push
      block.call
      pop
    end
  
    # push the current drawing context onto the stack
    def push
      CGContextSaveGState(@ctx)
      @stacksize = @stacksize + 1
    end
  
    # pop the previous drawing context off the stack
    def pop
      CGContextRestoreGState(@ctx)
      @stacksize = @stacksize - 1
    end
  
    # restore the initial context
    def reset
      # retrieve graphics states until we get to the default state
      pop until (@stacksize <= 1)
      push  # push the retrieved pristine default state back onto the stack
    end
  
  
    # EFFECTS
  
    # apply a drop shadow with offset dx,dy, alpha, and blur
    def shadow(dx=0.0, dy=0.0, a=2.0/3.0, blur=5)
      color = CGColorCreate(@colorspace, [0.0, 0.0, 0.0, a])
      CGContextSetShadowWithColor(@ctx, [dx, dy], blur, color)
    end
  
    # stop using a shadow
    def no_shadow
      CGContextSetShadowWithColor(@ctx, [0,0], 1, nil)
    end
    
    # apply a glow with offset dx,dy, alpha, and blur
    def glow(dx=0.0, dy=0.0, a=2.0/3.0, blur=5)
      color = CGColorCreate(@colorspace, [1.0, 1.0, 0.0, a])
      CGContextSetShadowWithColor(@ctx, [dx, dy], blur, color)
    end
  
    # set the canvas blend mode (:normal, :darken, :multiply, :screen, etc)
    def blend(mode)
      CGContextSetBlendMode(@ctx, BlendModes[mode])
    end
  
    # CLIPPING MASKS
    
    # clip subsequent drawing operations within the given path
    def begin_clip(p, &block)
      push
      CGContextAddPath(@ctx, p.path)
      CGContextClip(@ctx)
      if block
        block.call
        end_clip
      end
    end
  
    # stop clipping drawing operations
    def end_clip
      pop
    end
  
    # DRAW TEXT TO CANVAS
    
    # write the text at x,y using the current fill
    def text(txt="", x=0, y=0)
      # not sure that's worth doing that here
      txt = txt.to_s
      if @registration == :center
        width = textwidth(txt)
        x = x - width / 2
        y = y + @fsize / 2
      end
      CGContextShowTextAtPoint(@ctx, x, y, txt, txt.length)
    end
  
    # determine the width of the given text without drawing it
    def text_width(txt, width=nil)
      push
      start = CGContextGetTextPosition(@ctx)
      CGContextSetTextDrawingMode(@ctx, KCGTextInvisible)
      CGContextShowText(@ctx, txt, txt.length)
      final = CGContextGetTextPosition(@ctx)
      pop
      final.x - start.x
    end
  
    # def text_height(txt)
    #   # need to use ATSUI
    # end
    # 
    # def text_metrics(txt)
    #   # need to use ATSUI
    # end
  
    # set font by name and optional size
    def font(name="Helvetica", size=nil)
      font_size(size) if size
      @fname = name
      font_size unless @fsize
      CGContextSelectFont(@ctx, @fname, @fsize, KCGEncodingMacRoman)
    end
  
    # set font size in points
    def font_size(points=20)
      @fsize = points
      font unless @fname
      # encoding could have also been set as KCGEncodingFontSpecific
      CGContextSelectFont(@ctx, @fname, @fsize, KCGEncodingMacRoman)
    end
  
  
    # SAVING/EXPORTING
    
    def ns_image
      image = NSImage.alloc.init
      image.addRepresentation(NSBitmapImageRep.alloc.initWithCGImage(cgimage))
      image
    end
    
    # return a CGImage of the canvas for reprocessing (only works if using a bitmap context)
    def cgimage
      CGBitmapContextCreateImage(@ctx)  # => CGImageRef (works with bitmap context only)
      #cgimageref = CGImageCreate(@width, @height, @bits_per_component, nil,nil,@colorspace, nil, @provider,nil,true,KCGRenderingIntentDefault)
    end
  
    # return a CIImage of the canvas for reprocessing (only works if using a bitmap context)
    def ciimage
      cgimageref = self.cgimage
      CIImage.imageWithCGImage(cgimageref) # CIConcreteImage (CIImage)
    end

    # begin a new PDF page
    def new_page
      if (@filetype == :pdf)
        CGContextFlush(@ctx)
        CGPDFContextEndPage(@ctx)
        CGPDFContextBeginPage(@ctx, nil)
      else
        puts "WARNING: new_page only valid when using PDF output"
      end
    end
  
    # save the image to a file
    def save
      properties = {}
  #    exif = {}
      # KCGImagePropertyExifDictionary
  #    exif[KCGImagePropertyExifUserComment] = 'Image downloaded from www.sheetmusicplus.com'
  #    exif[KCGImagePropertyExifAuxOwnerName] = 'www.sheetmusicplus.com'
      if @filetype == :pdf
        CGPDFContextEndPage(@ctx)
        CGContextFlush(@ctx)
        return
      elsif @filetype == :png
        format = NSPNGFileType
      elsif @filetype == :tif
        format = NSTIFFFileType
        properties[NSImageCompressionMethod] = NSTIFFCompressionLZW
        #properties[NSImageCompressionMethod] = NSTIFFCompressionNone
      elsif @filetype == :gif
        format = NSGIFFileType
        #properties[NSImageDitherTransparency] = 0 # 1 = dithered, 0 = not dithered
        #properties[NSImageRGBColorTable] = nil # For GIF input and output. It consists of a 768 byte NSData object that contains a packed RGB table with each component being 8 bits.
      elsif @filetype == :jpg
        format = NSJPEGFileType
        properties[NSImageCompressionFactor] = @quality # (jpeg compression, 0.0 = max, 1.0 = none)
        #properties[NSImageEXIFData] = exif
      end
      cgimageref = CGBitmapContextCreateImage(@ctx)                      # => CGImageRef
      bitmaprep = NSBitmapImageRep.alloc.initWithCGImage(cgimageref)     # => NSBitmapImageRep
      blob = bitmaprep.representationUsingType(format, properties:properties) # => NSConcreteData
      blob.writeToFile(@output, atomically:true)
      puts @output
      true
    end

    # open the output file in its associated application
    def open
      system "open #{@output}"
    end
    
    # def save(dest)
    ## http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_data_mgr/chapter_11_section_3.html
    #   properties = {
    #     
    #   }
    #   cgimageref = CGBitmapContextCreateImage(@ctx)                   # => CGImageRef
    #   destination = CGImageDestinationCreateWithURL(NSURL.fileURLWithPath(dest)) # => CGImageDestinationRef
    #   CGImageDestinationSetProperties(destination,properties)
    #   CGImageDestinationAddImage(cgimageref)
    # end
    
    private
    
      # DRAWING PATHS ON A CANVAS

      def draw_path(p, tx=0, ty=0, iterations=1)
        new_state do
          iterations.times do |i|
            if (i > 0)
              # INCREMENT TRANSFORM:
              # translate x, y
              translate(MRGraphics.choose(p.inc[:x]), MRGraphics.choose(p.inc[:y]))
              # choose a rotation factor from the range
              rotate(MRGraphics.choose(p.inc[:rotation]))
              # choose a scaling factor from the range
              sc = MRGraphics.choose(p.inc[:scale])
              sx = MRGraphics.choose(p.inc[:scale_x]) * sc
              sy = p.inc[:scale_y] ? MRGraphics.choose(p.inc[:scale_y]) * sc : sx * sc
              scale(sx, sy)
            end

            new_state do
              # PICK AND ADJUST FILL/STROKE COLORS:
              [:fill,:stroke].each do |kind|
                # PICK A COLOR
                if (p.inc[kind])
                  # increment color from array
                  colorindex = i % p.inc[kind].size
                  c = p.inc[kind][colorindex].copy
                else
                  c = p.rand[kind]
                  case c
                  when Array
                    c = MRGraphics.choose(c).copy
                  when Color
                    c = c.copy
                  else
                    next
                  end
                end

                if (p.inc[:hue] or p.inc[:saturation] or p.inc[:brightness])
                  # ITERATE COLOR
                  if (p.inc[:hue])
                    newhue = (c.hue + MRGraphics.choose(p.inc[:hue])) % 1
                    c.hue(newhue)
                  end
                  if (p.inc[:saturation])
                    newsat = (c.saturation + MRGraphics.choose(p.inc[:saturation]))
                    c.saturation(newsat)
                  end
                  if (p.inc[:brightness])
                    newbright = (c.brightness + MRGraphics.choose(p.inc[:brightness]))
                    c.brightness(newbright)
                  end
                  if (p.inc[:alpha])
                    newalpha = (c.a + MRGraphics.choose(p.inc[:alpha]))
                    c.a(newalpha)
                  end
                  p.rand[kind] = c
                else
                  # RANDOMIZE COLOR
                  c.hue(MRGraphics.choose(p.rand[:hue])) if p.rand[:hue]
                  c.saturation(MRGraphics.choose(p.rand[:saturation])) if p.rand[:saturation]
                  c.brightness(MRGraphics.choose(p.rand[:brightness])) if p.rand[:brightness]
                end

                # APPLY COLOR
                fill(c) if kind == :fill
                stroke(c) if kind == :stroke
              end
              # choose a stroke width from the range
              stroke_width(MRGraphics.choose(p.rand[:stroke_width])) if p.rand[:stroke_width]
              # choose an alpha level from the range
              alpha(MRGraphics.choose(p.rand[:alpha])) if p.rand[:alpha]

              # RANDOMIZE TRANSFORM:
              # translate x, y
              translate(MRGraphics.choose(p.rand[:x]), MRGraphics.choose(p.rand[:y]))
              # choose a rotation factor from the range
              rotate(MRGraphics.choose(p.rand[:rotation]))
              # choose a scaling factor from the range
              sc = MRGraphics.choose(p.rand[:scale])
              sx = MRGraphics.choose(p.rand[:scale_x]) * sc
              sy = p.rand[:scale_y] ? MRGraphics.choose(p.rand[:scale_y]) * sc : sx * sc
              scale(sx,sy)

              # DRAW
              if (tx > 0 || ty > 0)
                translate(tx, ty)
              end

              CGContextAddPath(@ctx, p.path) if p.class == Path
              CGContextDrawPath(@ctx, KCGPathFillStroke) # apply fill and stroke
              # if there's an image, draw it clipped by the path
              if (p.image)
                begin_clip(p)
                image(p.image)
                end_clip
              end
            end
          end
        end
      end
      
      # DRAWING IMAGES ON CANVAS

      # draw the specified image at x,y with dimensions w,h.
      # "img" may be a path to an image, or an Image instance
      def draw_image(img, x=0, y=0, w=nil, h=nil, pagenum=1)
        new_state do
          if (img.kind_of?(Pdf))
            w ||= img.width(pagenum)
            h ||= img.height(pagenum)
            if(@registration == :center)
              x = x - w / 2
              y = y - h / 2
            end
            img.draw(@ctx, x, y, w, h, pagenum)
          elsif(img.kind_of?(String) || img.kind_of?(Image))
            img = Image.new(img) if img.kind_of?(String)
            w ||= img.width
            h ||= img.height
            img.draw(@ctx, x, y, w, h)
          else
            raise ArgumentError, "canvas.image: not a recognized image type: #{img.class}"
          end
        end
      end
  
  end

end
