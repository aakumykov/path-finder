#!/usr/bin/env ruby
# coding: UTF-8
require 'colorize'

data = []

5.times {
	(rand(3)+3).times {
		data << rand(10)+5
	}

	(rand(3)+3).times {
		data << rand(3)
	}
}

limit = data.reduce(:+)/data.size.to_f

data.map! { |e|
	(e > limit) ? e : 0
}

e_prev = nil
data.map! {|e|
	current = (0==e && [0,nil].include?(e_prev)) ? nil : e
	e_prev = current
}
data.compact!

data.pop if 0==data.last

data.each { |a|
	#bar = 0==a ? '0' : '#'*a

	case a
	when nil
		bar = 'nil'
	when 0
		bar = '0'
	else
		bar = '#'*a+"(#{a})"
	end

	if a.to_f > limit 
		puts bar.blue
	else
		puts bar
	end
}

data_chunks = []
seq = []
data.each {|e|
	if 0==e
		data_chunks << seq
		seq = []
	else
		seq << e
	end
}
data_chunks << seq
seq = []

puts data_chunks.inspect
