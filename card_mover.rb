class CardMover
  def initialize(args)
    if args.length == 4
      # 189 281 728 328 on 1920x1080 with MBP Retina Max Resolution
      @x0, @y0, @x1, @y1 = args.map(&:to_i)
    else
      puts "Point top left corner of the top left card and hit enter"
      STDIN.gets
      c0 = `cliclick p:.`
      puts c0

      puts "Point top left corner of the bottom right card and hit enter"
      STDIN.gets
      c1 = `cliclick p:.`
      puts c1

      @x0, @y0 = c0.chomp.split(/,/).map(&:to_i)
      @x1, @y1 = c1.chomp.split(/,/).map(&:to_i)
    end
    @w = (@x1 - @x0) / 8
    @h = (@y1 - @y0) / 3

    `cliclick c:#{@x0},#{@y0 - @h} w:10`  # activate
  end

  def move(i, j, a = 3, b = 3)
    if i == 9
      i = 7.5
      a = -6
    end
    if j == 9
      j = 7.5
      b = -6
    end
    cmd = "dd:#{(@x0 + @w * i).to_i},#{(@y0 + @h * a).to_i} "
    motion = 0
    motion.times do |t|
      cmd += "dd:#{(@x0 + @w * (i * (motion-t) + j * t) / motion).to_i},#{(@y0 + @h * (a * (motion-t) + b * t) / motion).to_i} "
    end
    cmd += "w:1 du:#{(@x0 + @w * j).to_i},#{(@y0 + @h * b).to_i} w:1"
    `cliclick -w 1 #{cmd}`
  end
end
