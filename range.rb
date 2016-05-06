#!/usr/bin/env ruby

def fix_signs(angle,x,y)
	angle = angle.to_f % 360

	def make_positive(arg)
		arg = arg.to_f
		arg < 0 ? arg*(-1) : arg
	end
	
	def make_negative(arg)
		arg = arg.to_f
		arg < 0 ? arg : arg*(-1)
	end

	case angle
	when 0...90
		[ make_positive(x), make_positive(y) ]
	when 90...180
		[ make_negative(x), make_positive(y) ]
	when 180...270
		[ make_negative(x), make_negative(y) ]
	when 270...360
		[ make_positive(x), make_negative(y) ]
	else
		raise "out of range (#{angle})"
	end
end

# x,y = fix_signs(280,1,2)
# puts "#{x}, #{y}"

a=0
while a < 360
	x,y = fix_signs(a,2,3)
	puts "#{x}, #{y}"
	a +=11
end

# puts make_positive(1)
# puts make_positive(-1)
# puts make_negative(1)
# puts make_negative(-1)