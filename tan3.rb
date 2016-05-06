# coding: UTF-8
require 'rmagick'
include Magick


case ARGV.count
when 4
	a1 = ARGV[0].to_f
	a2 = ARGV[1].to_f
	r = ARGV[2].to_i
	gK = ARGV[3].to_i
else
	STDERR.write("Usage: #{__FILE__} a1 a2 r gK\n")
	exit 1
end

#r = 20
#gK = 10

def g2r(n)
	n*(Math::PI/180)
end

def r2g(n)
	n*(180/Math::PI)
end

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

dA = 360/(r*2)
#dA = 10
x0 = r
y0 = r

gWidth = r*2*gK
gHeight = r*2*gK
gX0 = x0*gK
gY0 = y0*gK

img = Image.new(gWidth,gHeight){self.background_color='turquoise'}
draw = Draw.new.fill('black')

puts "r: #{r}, dA: #{dA}"

a=a1
while a <= a2 do
	begin
		k = Math.tan( g2r(a) )
		x = Math.sqrt( r**2 / (k**2 + 1) )
		y = k*x

		x,y = fix_signs(a,x,y)

		#puts "a: #{a}\t k: #{k}\t x: #{x}\t y: #{y}"
		puts "#{x}\t #{y}"

		draw.line(gX0, gY0, (x0+x)*gK, (y0+y)*gK)
	rescue
		puts "НЕТ ТАНГЕНСА ДЛЯ #{a}"
	ensure
		a += dA
	end
end

draw.draw(img)
img.display
