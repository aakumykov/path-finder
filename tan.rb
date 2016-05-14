# coding: utf-8
require 'rmagick'
include Magick

r=20
a0=0.0000
gK = 10


dA = Math::PI/(r*2)
x0 = r
y0 = r

img = Image.new(r*2*gK, r*2*gK){self.background_color = 'turquoise'}
draw = Draw.new.fill('black')

puts "r: #{r}, dA: #{dA}"

a1 = Math::PI - dA*2
a1 = 0 + dA*4

a2 = Math::PI*2 - dA*4

a = a1
while a < a2 do
	begin
		k = Math::tan(a)

		x_sign = (k / k.abs).to_i
		y_sign = (a > Math::PI) ? -1 : 1

		x = Math::sqrt( r**2 / (k**2 + 1) ) * x_sign

		y = k * x * y_sign

		puts "#{a}\t #{k}\t #{x}\t #{y}"
	
		draw.line(
			x0*gK,
			y0*gK,
			(x0+x)*gK,
			(y0+y)*gK
		)
	rescue
		puts "НЕТ ЗНАЧЕНИЯ ДЛЯ #{a}"
		a += 0.0001
		retry
	ensure
		a += dA
	end
end

draw.draw(img)
img.display

