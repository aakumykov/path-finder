#!/usr/bin/env ruby
# coding: utf-8
require 'rmagick'
include Magick

class PathFinder
	def initialize(img_file)
		@img = ImageList.new(img_file).first
	end

	def find_path(start_x, start_y, opt={})
		puts "#{__method__}(#{start_x},#{start_y})"

		# предварительная настройка
		search_radius = opt.fetch(:radius,10)
		@rays_template = calc_rays_template(search_radius)

		# получение массива шагов
		x,y = start_x, start_y
		all_steps = []
		
		puts ''
		while step = get_step(x,y)
			puts "step: #{step}"
			all_steps << step
			x,y = step[0],step[1]
			puts ''
		end
		
		return all_steps
	end

	private

		def calc_rays_template(radius)
			data = [
				[ [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)] ],
				[ [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)] ],
				[ [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)], [rand(@img.columns), rand(@img.rows)] ],

				# [ [1,1], [1,2], [1,3], [1,4], [1,5], ],
				# [ [2,1], [2,2], [2,3], [2,4], [2,5], ],
				# [ [3,1], [3,2], [3,3], [3,4], [3,5], ],
			]
			#puts data.inspect
			#puts data.transpose.inspect
			data.transpose
		end

		def get_step(x,y)
			puts "#{__method__}(#{x},#{y})"

			# получаю данные всех лучей
			all_rays = get_all_rays(x,y)
			#puts "all_rays: #{all_rays}"

			# нахожу "лучший"
			best_ray = detect_best_ray(all_rays)
			#puts "best_ray: #{best_ray}"

			return best_ray
		end

		# возвращает массив хэшей
		def get_all_rays(x0,y0)
			#puts "#{__method__}(#{x0},#{y0})"
			
			rays = []
			
			for one_ray in @rays_template do
				
				for ray_dot in one_ray do
				
					x = x0+ray_dot[0]
					y = y0+ray_dot[1]
					puts "ray_dot: #{ray_dot}, #{x}, #{y}"
					
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
path = pf.find_path(0,0)
puts "path: #{path.inspect}"
