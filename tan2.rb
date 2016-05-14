# coding: utf-8
require 'rmagick'
include Magick

class Circle
	def initialize(r,gK=10)
		@r = r
		@gK = gK

		@dA = Math::PI/(@r*2)
		@x0 = @r
		@y0 = @r

		@a_corr = 0.0001
	end

	def work
		a1 = 0
		a2 = Math::PI/2
		get_xy(a1,a2)
		puts ''

		#a1 = Math::PI/2
		#a2 = Math::PI
		#get_xy(a1,a2)
		#puts ''

		#a1 = Math::PI
		#a2 = (3/4)*Math::PI
		#get_xy(a1,a2)
		#puts ''

		#a1 = (3/4)*Math::PI
		#a2 = Math::PI*2
		#get_xy(a1,a2)
		#puts ''
	end

	def get_xy(a1,a2)
		a = a1
		while a < a2 do
			begin
				k = Math::tan(a)

				#x_sign = (k / k.abs).to_i
				#y_sign = (a > Math::PI) ? -1 : 1

				x = Math::sqrt( @r**2 / (k**2 + 1) )
				y = k * x

				puts "a: #{a}\t k: #{k}\t x: #{x}\t y: #{y}"
			
				#draw.line(x0*gK,y0*gK,(x0+x)*gK,(y0+y)*gK)
			rescue
				#puts "НЕТ ЗНАЧЕНИЯ ДЛЯ #{a}"
				#a += @a_corr
				#retry
			ensure
				a += @dA
			end
		end
	end

end

#img = Image.new(r*2*gK, r*2*gK){self.background_color = 'turquoise'}
#draw = Draw.new.fill('black')

#puts "r: #{r}, dA: #{dA}"
#draw.draw(img)
#img.display

c = Circle.new(10)
c.work
