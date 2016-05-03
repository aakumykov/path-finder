require 'rmagick'
include Magick

R = 10
a0=0.0001
dA = Math::PI/(2*R)
puts "R: #{R}, dA: #{dA}"

img = Image.new(2*R,2*R) { self.background_color='paleturquoise' }
#img.display
$arc = Draw.new
$arc.fill('black')

def calc_tan(a)
	k = Math::tan(a)
	x = Math::sqrt( R**2 / (k**2 + 1) )
	y = k*x
	sign = (k / k.abs)

	x_real = R + x.round*sign
	y_real = R - y.round.abs

	#$arc.point(x_real,y_real)
	$arc.line(R,R,x_real,y_real)

	#puts "x: #{x.round*sign}\t y: #{y.round}\t a: #{a.round(3)}\t k: #{k.round(3)}\t sign:#{sign}"
	puts "#{x_real}, #{y_real}, a: #{a.round(2)}"
	#puts "x: #{x.round(3)*sign},    y1: #{y1.round(3)},    y2: #{y2.round(3)},    #{y1.round(3)==y2.round(3)}"
end

a = a0
while a <= (Math::PI) do
	begin
		calc_tan(a)
	rescue
	ensure
		a += dA
	end
end

$arc.draw(img)
#img.scale!(100,100)
img.display

