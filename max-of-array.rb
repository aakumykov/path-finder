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

#e_prev = nil
#data = data.map {|e|
#	if (0==e && 0==e_prev.nil?)
#		nil
#	else
#		e
#	end
#	e_prev = e
#}
#data.compact!

data.map! {|e|
	0==e ? nil : e
}

data.each { |a|
	#bar = 0==a ? '0' : '#'*a

	case a
	when nil
		bar = 'nil'
	when 0
		bar = '0'
	else
		bar = '#'*a
	end

	if a.to_f > limit 
		puts bar.blue
	else
		puts bar
	end
}

