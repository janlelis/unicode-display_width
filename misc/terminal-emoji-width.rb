#!/usr/bin/env ruby

RULER = "123456789\n"
ABC   = "abcdefg\n\n"

puts "1) TEXT-DEFAULT EMOJI"
puts
puts RULER + "⛹" + ABC

puts "1B) TEXT-DEFAULT EMOJI + VS16"
puts
puts RULER + "⛹️" + ABC

puts "2) RGI EMOJI SEQ"
puts
puts RULER + "🏃🏼‍♀‍➡" + ABC

puts "2B) RGI EMOJI SEQ (TEXT-DEFAULT FIRST)"
puts
puts RULER + "⛹️‍♂️" + ABC

puts "2C) RGI EMOJI SEQ (TEXT-DEFAULT FIRST + UQE)"
puts
puts RULER + "⛹‍♂️" + ABC

puts "3) NON-RGI VALID EMOJI"
puts
puts RULER + "🤠‍🤢" + ABC

puts "4) NOT WELL-FORMED EMOJI SEQ"
puts
puts RULER + "🚄🏾‍🔆" + ABC
