#!/usr/bin/env ruby
# coding: UTF-8
require 'rmagick'
include Magick

def calc_rays_template(radius,opt={})
	
	# параметры
	angle_start = opt.fetch(:angle_start,0)
	angle_end = opt.fetch(:angle_end,359)

	dA = 360/(radius*2)

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
	a=angle_start
	store = []
	
	while a <= angle_end do
		begin
			k = Math.tan( g2r(a) )
			x = Math.sqrt( radius**2 / (k**2 + 1) )
			y = k*x

			store << fix_signs(a,x,y)
		rescue
			puts "НЕТ ТАНГЕНСА ДЛЯ #{a}"
		ensure
			a += dA
		end
	end

	return store
end

calc_rays_template(ARGV[0].to_i).each do |xy| puts "#{xy}" end