#!/usr/bin/env ruby
# coding: utf-8
require 'rmagick'
include Magick


class PathFinder
	def initialize(img_file)
		@img = ImageList.new(img_file).first
		@img_width = @img.columns
		@img_height = @img.rows
		
		puts "image width: #{@img_width}"
		puts "image height: #{@img_height}"
	end

	def find_path(opt={})
		
		start_x = opt.fetch(:x)
		start_y = opt.fetch(:y)
		search_radius = opt.fetch(:radius)

		puts "#{__method__}(x: #{start_x}, y: #{start_y}, radius: #{search_radius})"

		@rays_template = calc_rays_template(search_radius)
		
		puts "@rays_template.size: #{@rays_template.size}"
		#@rays_template.each_with_index { |r,index| 
			#puts "ray #{index}"
			#r.each { |dot| puts "#{dot}" }; puts ''
		#}
		#exit

		# получение массива шагов
		x,y = start_x, start_y
		all_steps = []
		
		step = get_step(x,y)
		
		#~ while step = get_step(x,y)
			#~ puts "step: #{step}"
			#~ all_steps << step
			#~ x,y = step[0],step[1]
			#~ puts ''
		#~ end
		
		return all_steps
	end

	private

		def calc_rays_template(radius,opt={})
			puts "#{__method__}(#{radius},#{opt})"
			
			# параметры
			angle_start = opt.fetch(:angle_start,0)
			angle_end = opt.fetch(:angle_end,359)

			#angle_step = 360/(radius*2)
			angle_step = 60 # градус

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
			
			while a <= angle_end do
				begin
					puts "angle: #{a}"

					r = 1
					dots = []

					while r <= radius do
						k = Math.tan( g2r(a) )
						x = Math.sqrt( r**2 / (k**2 + 1) )
						y = k*x

						x,y = fix_signs(a,x,y)

						dots << {
							x: x,
							y: y,
						}
						
						r += 1
					end
					
					all_rays << {
						angle: a,
						radius: radius,
						dots: dots,
					}

					dots = []
				rescue
					puts "НЕТ ТАНГЕНСА ДЛЯ #{a}"
				ensure
					a += angle_step
				end
			end
			
			puts "all_rays:"; puts all_rays
			
			return all_rays
		end

		def get_step(x,y)
			puts "#{__method__}(#{x},#{y})"

			# собираю лучи
			all_rays = get_all_rays(x,y)
			puts ''; puts "all_rays: #{all_rays}"
			#puts "all_rays:"; all_rays.each { |r| puts "#{r}" }

			# нахожу "лучший"
			#~ best_ray = detect_best_ray(all_rays)
			#~ puts "best_ray: #{best_ray}"
			#~ exit

			#~ return best_ray
		end

		def get_all_rays(x0,y0)
			puts "#{__method__}(#{x0},#{y0})"
			
			all_rays = []
			
			for ray in @rays_template do
				#puts ''
				puts "ray: #{ray}"

				for dot in ray[:dots] do
				 	#puts ''
				 	puts "dot: #{dot}"

				  	x = x0+dot[:x]
				  	y = y0+dot[:y]
					
				  	#puts "RAY DOT: template: #{dot[:x]},#{dot[:y]}, real: #{x}, #{y}"
					
					#puts "@img.pixel_color(#{x},#{y})"
				 	
		 			colors = @img.pixel_color(x,y)
					
					pixel_weight = (65535-colors.red) + (65535-colors.green) + (65535-colors.blue)

					one_ray = { 
						angle: ray[:angle],
						radius: ray[:radius],
						x: x, 
						y: y, 
						color: {
							red: colors.red,
							green: colors.green,
							blue: colors.blue,
						},
						weight: pixel_weight,
					}
				end

				all_rays << one_ray

				one_ray = {}
			end

			return all_rays
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
path = pf.find_path(x: 6, y: 6, radius: 5)
puts "path: #{path.inspect}"
