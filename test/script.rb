#!/usr/bin/env ruby

file = __FILE__
realpath = File.realpath(file)
dirname = File.dirname(realpath)

puts "file = #{file}"
puts "realpath = #{realpath}"
puts "dirname = #{dirname}"
