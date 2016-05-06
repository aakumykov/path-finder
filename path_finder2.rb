#!/usr/bin/env ruby
# coding: utf-8
require 'rmagick'
include Magick

class PathFinder
	def initialize(img_file)
		@img = ImageList.new(img_file).first
	end

	def find_path(start_x, start_y, opt={})
		# предварительная настройка
		search_radius = opt.fetch(:radius,10)
		@rays_template = calc_rays_template(search_radius)

		# получение массива шагов
		all_steps = []
		
		step = get_step(start_x,start_y)
		all_steps << step
		
		while step = get_step(step[0],step[1])
			all_steps << step
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
			detect_best_ray(all_rays)
		end

		def get_all_rays(x0,y0)
			puts "#{__method__}(#{x0},#{y0})"
			
			rays = []
			
			one_ray = []
			for ray in @rays_template do
				for ray_dot in ray do
					x = x0+ray_dot[0]
					y = y0+ray_dot[1]
					#puts "ray_dot: #{ray_dot}, #{x}, #{y}"
					
					pix = @img.get_pixels(x,y,1,1).first
					ray_data = pix.red + pix.green + pix.blue
					one_ray << ray_data
				end
				rays << one_ray
				one_ray = []
			end

			return rays
		end

		def detect_best_ray(rays_bunch)
			puts "#{__method__}(#{rays_bunch})"

			all_rays = []

			rays_bunch.each { |ray|
				all_rays << ray.inject(0){|sum,x| sum + x }
			}

			puts all_rays.inspect

			[ all_rays.max, all_rays.min ]
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
puts path.inspect
