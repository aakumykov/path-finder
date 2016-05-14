#!/usr/bin/env ruby
# coding: UTF-8
require 'colorize'

data = []

# заполнение тестового массива
5.times {
	(rand(3)+3).times {
		data << rand(10)+5
	}

	(rand(3)+3).times {
		data << rand(3)
	}
}

# отладка
puts '-'*data.size*3; puts data.inspect; puts '-'*data.size*3

# среднее значение
mean = data.reduce(:+)/data.size.to_f

# сохранение значений больше среднего
data.map! { |e|
	(e > mean) ? e : 0
}

# сжатие "нулевых участков" до одного элемента
e_prev = nil
data.map! {|e|
	current = (0==e && [0,nil].include?(e_prev)) ? nil : e
	e_prev = current
}
data.compact!

# удаление возможного концевого нуля
data.pop if 0==data.last

# отладка
puts '-'*data.size*3; puts data.inspect; puts '-'*data.size*3

# распечатка столбцов
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

	if a.to_f > mean 
		puts bar.blue
	else
		puts bar
	end
}

# нарезка массива по нулям
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

# отладка
puts data_chunks.inspect

# вывод среднего значения кусков
data_chunks.each {|chunk|
	mean = chunk.reduce(:+)/chunk.size.to_f
	print "#{chunk}: ".blue
	puts mean
}
