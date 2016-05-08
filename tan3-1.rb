#!/usr/bin/env ruby
# coding: UTF-8
require 'rmagick'
include Magick

def calc_rays_template(radius,opt={})
	
	# параметры
	angle_start = opt.fetch(:angle_start,0)
	angle_end = opt.fetch(:angle_end,359)

	dA = 360/(radius*2)
	#dA = 360/(radius)

	# служебные функции
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

	# вычисления
	all_rays = []

	a = angle_start
	r = 1
	
	while r <= radius
		ray = []

		while a <= angle_end do
			begin
				k = Math.tan( g2r(a) )
				x = Math.sqrt( r**2 / (k**2 + 1) )
				y = k*x

				ray << fix_signs(a,x,y)
			rescue
				puts "НЕТ ТАНГЕНСА ДЛЯ #{a}"
			ensure
				a += dA
			end
		end

		all_rays << ray

		a = angle_start
		r += 1
	end

	all_rays.transpose
end


case ARGV.count
when 1
	radius = ARGV[0].to_i
else
	STDERR.write("Usage: #{__FILE__} <radius>\n")
	exit 1
end

rays_template = calc_rays_template(radius)

img = Image.new(radius*2, radius*2) { self.background_color='turquoise' }
draw = Draw.new.fill('black')

rays_template.each do |ray|
	#puts "ray: #{ray}"
	puts ''
	puts 'RAY:'
	ray.each do |dot|
		puts "VDOT: #{dot}"
		puts "RDOT: #{radius+dot[0]},#{radius+dot[1]}"
		#puts "line: #{radius},#{radius},#{radius+dot[0]},#{radius+dot[1]}"
		draw.line(radius,radius,radius+dot[0],radius+dot[1])
	end
end

draw.draw(img)
img.display
