#!/usr/bin/env ruby
# coding: utf-8
require 'rmagick'
include Magick


class PathFinder
	def initialize(img_file)
		@img = ImageList.new(img_file).first
		puts "image width: #{@img.columns}"
		puts "image height: #{@img.rows}"
	end

	def find_path(start_x, start_y, opt={})
		puts "#{__method__}(#{start_x},#{start_y})"

		# предварительная настройка
		search_radius = opt.fetch(:radius,10)
		@rays_template = calc_rays_template(search_radius)
		#puts @rays_template.inspect; exit

		# получение массива шагов
		x,y = start_x, start_y
		all_steps = []
		
		while step = get_step(x,y)
			puts "step: #{step}"
			all_steps << step
			x,y = step[0],step[1]
			puts ''
		end
		
		return all_steps
	end

	private

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

		def get_step(x,y)
			puts "#{__method__}(#{x},#{y})"

			# получаю данные всех лучей
			all_rays = get_all_rays(x,y)
			puts "all_rays:"; all_rays.each { |r| puts "#{r}" }

			# нахожу "лучший"
			best_ray = detect_best_ray(all_rays)
			puts "best_ray: #{best_ray}"
			exit

			return best_ray
		end

		# возвращает массив хэшей
		def get_all_rays(x0,y0)
			puts "#{__method__}(#{x0},#{y0})"
			
			rays = []
			
			for one_ray in @rays_template do
				#puts "one_ray: #{one_ray}"
				
				for ray_dot in one_ray do

					x = x0+ray_dot[0]
					y = y0+ray_dot[1]
					
					# puts "RAY DOT: template: #{ray_dot}, real: #{x}, #{y}"
					
					pix = @img.get_pixels(x,y,1,1).first
					
					rays << { 
						x: x, 
						y: y, 
						weight: pix.red + pix.green + pix.blue
					}
				end
			end

			return rays
		end

		def detect_best_ray(rays_bunch)
			#puts "#{__method__}(#{rays_bunch})"

			ray = rays_bunch.first

			[ray[:x], ray[:y]]
		end
end

case ARGV.count
when 1
	img_file = ARGV[0]
else
	STDERR.write("Usage: #{__FILE__} <img_file>\n")
	exit 1
end

pf = PathFinder.new(img_file)
path = pf.find_path(9,9)
puts "path: #{path.inspect}"
