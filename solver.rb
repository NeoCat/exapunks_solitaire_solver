class Solver
  def initialize(list)
    @depth_limit = []
    @deck = read_deck(list)
  end

  def self.from_file(file = 'data.txt')
    new(File.read(file).strip.split)
  end

  def deep_dup(deck, i)
    deck[i].map { |s| s.map { |c| c.dup } }
  end

  def repl(s)
    return "[]" unless s
    s.map { |c| c[0] == :p ? c[1] : "#{c[0]}#{c[1]}" }.join("-")
  end

  def completed(d)
    d.length == 1 && (d[0].length == 5 || d[0].length == 4 && d[0][0][0] == :p)
  end

  def dummy_move(deck, i, j)
    i != 9 && deck[i].length == 1 && deck[j].length == 0
  end

  def foldable(src, dst)
    return true if src[0][0] == :p && dst[-1][0] == :p && src[0][1] == dst[-1][1]
    return true if src[0][0] == :r && dst[-1][0] == :b && src[0][1] + 1 == dst[-1][1]
    return true if src[0][0] == :b && dst[-1][0] == :r && src[0][1] + 1 == dst[-1][1]
    false
  end

  def movable(src, dst, spare)
    return false unless src
    if spare
      return !dst && src.length == 1
    end
    return true unless dst
    return foldable(src, dst)
  end

  def move(deck, i, j)
    target = deck[i].pop
    if deck[j][-1]
      deck[j][-1] += target
    else
      deck[j].push target
    end
  end

  def scan(deck = @deck, steps = [])
    (0...(steps.length-1)).each do |depth|
      return nil if (@depth_limit[depth] += 1) > 30 * 9 ** (steps.length - depth + 1)
    end

    rem = 0
    (0..9).each do |i|
      unless deck[i].length == 0 || completed(deck[i])
        @depth_limit[steps.length] = 0
        rem += 1
        ret = scan_i(deck, i, steps)
        return ret if ret
      end
    end
    if rem == 0
      puts "done!"
      puts steps
      return steps
    end

    nil
  end

  def scan_i(deck, i, steps)
    s = deck[i][-1]
    (0..9).each do |j|
      next if j == i
      next if completed(deck[j])
      next if dummy_move(deck, i, j)
      if movable(s, deck[j][-1], j == 9)
        steps.push "#{i} -> #{j}  ::  #{repl(s)} -> #{repl(deck[j][-1])}"
        prev = [deep_dup(deck, i), deep_dup(deck, j)]
        move(deck, i, j)
        ret = scan(deck, steps)
        return ret if ret
        # revert
        steps.pop
        deck[i] = prev[0]
        deck[j] = prev[1]
      end
    end
    nil
  end

  def read_deck(list)
    cards = list.map do |x|
      raise "Unknown symbol: #{x}" unless x.match(/^(?:[rb](?:[6-9]|10)|s|c|h|d)$/)
      x[0] == 'r' || x[0] == 'b' ? [x[0].to_sym, x[1..-1].to_i] : [:p, x]
    end
    raise "Invalid length: #{cards.length}" unless cards.length == 9*4
    cards.group_by { |x| x }.each do |k, ary|
      raise "Invalid num: #{k} -> #{ary.length}" unless k[0] == :p && ary.length == 4 || k[0] != :p && ary.length == 2
    end

    deck = (0..8).map do |x|
      d = [[cards[x]], [cards[x+9]], [cards[x+18]], [cards[x+27]]]
      d.length.times do |i|
        while d[i+1] && foldable(d[i+1], d[i])
          d[i] += d[i+1]
          d.delete_at(i+1)
        end
      end
      d
    end
    deck += [[]]
  end
end
