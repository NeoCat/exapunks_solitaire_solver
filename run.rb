#!/usr/bin/env ruby
require './capture.rb'
require './solver.rb'
require './card_mover.rb'

cap = Capture.from_screen
result = cap.match.map { |_, _, t| t.to_s }
result.each_slice(9) { |row| puts row.join(" ") }
# cap.show

puts "\nSolving ..."
moves = Solver.new(result).scan

mover = CardMover.new([189, 281, 728, 328])
lengths = [4] * 10
moves.each do |m|
  _, i, j, s = m.match(/^(\d) -> (\d)  ::  (.*?) -> /).to_a
  i = i.to_i
  j = j.to_i
  l = s.split(/-/).length
  mover.move(i, j, lengths[i] - l, lengths[j])
  lengths[i] -= l if i < 9
  lengths[j] += l if j < 9
end
