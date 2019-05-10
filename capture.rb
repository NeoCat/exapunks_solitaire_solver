require 'opencv'

class Capture
  TEMPLATES = [:b6, :b7, :b8, :b9, :b10, :r6, :r7, :r8, :r9, :r10, :s, :h, :d, :c]
  PICS = [:s, :h, :d, :c]

  def initialize(file)
    @src = OpenCV::CvMat.load(file)
    src_h = @src.resize(OpenCV::CvSize.new(@src.width/2, @src.height/2))
    bl = OpenCV::CvMat.load("images/bl.png")
    bl = bl.resize(OpenCV::CvSize.new(bl.width/2, bl.height/2))
    bl_match = src_h.match_template(bl)
    bl_p = bl_match.min_max_loc[2]
    @src = @src.sub_rect(bl_p.x * 2, bl_p.y * 2 - 280, 1280, 160)

    @images = TEMPLATES.map do |name|
      t = OpenCV::CvMat.load("images/#{name}.png")
      [name, t]
    end.to_h

    @match = []
  end

  def self.from_screen
    `screencapture -m capture.png`
    new("capture.png")
  end

  def match
    results = []
    TEMPLATES.each do |t|
      result = @src.match_template(@images[t])
      (PICS.include?(t) ? 4 : 2).times do
        pt1 = result.min_max_loc[2]
        results << [pt1.x, pt1.y, t]
        result[pt1.y, pt1.x] = result[result.min_max_loc[3].y, result.min_max_loc[3].x]
      end
    end
    y0 = results.min_by { |y, _, _| y }[0]
    @match = results.sort_by! { |x, y, t| (y - (y - y0) % 10) * @src.width + x }
  end

  def show
    src = @src.copy
    font = OpenCV::CvFont.new(:plain)
    @match.each do |x, y, t|
      src.rectangle!(OpenCV::CvPoint.new(x, y),
                     OpenCV::CvPoint.new(x + @images[t].width, y + @images[t].height),
                     color: OpenCV::CvColor::Blue)
      src.put_text!(t.to_s, OpenCV::CvPoint.new(x, y), font, OpenCV::CvColor::Blue)
    end
    OpenCV::GUI::Window.new('img').show(src)
    OpenCV::GUI::wait_key
  end
end
