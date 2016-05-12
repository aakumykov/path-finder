#!/usr/bin/env ruby
# coding: utf-8
require 'rmagick'
include Magick


class PathFinder
	def initialize(img_file)
		@img = ImageList.new(img_file).first
		@img_width = @img.columns
		@img_height = @img.rows
		
		puts "image: #{@img_width}x#{@img_height}"
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
			angle_step = 10 # градус
			
			raise "angle_step must be > 0" if angle_step <= 0

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
					#puts "angle: #{a}"

					r = 1
					dots = []

					while r <= radius do
						#puts "radius: #{r}"

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
			
			#puts "rays template:"; puts all_rays
			
			return all_rays
		end

		def get_step(x,y)
			puts "#{__method__}(#{x},#{y})"

			# собираю лучи
			all_rays = get_all_rays(x,y)
			
			@img2 = Image.new(@img_width,@img_height) { self.background_color = 'white' }
			
			all_rays.each_with_index { |ray,index|
				#puts "ray #{index}: #{ray.weight}"
				#puts ''; 
				puts "ray #{index}\t a:#{ray.angle}\t #{ray.weight}"
				
				ray.dots.each_with_index { |dot,index|
					#puts dot.inspect
					@img2.pixel_color(dot.x, dot.y, dot.color)
				}
			}
			#@img.display
			@img2.display
			
			exit

			# нахожу "лучший"
			#~ best_ray = detect_best_ray(all_rays)
			#~ puts "best_ray: #{best_ray}"
			#~ exit

			#~ return best_ray
		end

		def get_all_rays(x0,y0)
			puts "#{__method__}(#{x0},#{y0})"
			
			all_rays = []
			
			for one_ray_template in @rays_template do
				#puts ''; puts "checked ray: #{ray}"
				
				one_ray = Ray.new(
					angle: one_ray_template[:angle],
					radius: one_ray_template[:radius],
				)
				
				dots = []
				for dot in one_ray_template[:dots] do
				 	#puts "dot: #{dot.class}, #{dot[:x].class}, #{dot[:y].class}, #{x0.class}, #{y0.class}"
				 	#next
					
					x = x0 + dot[:x]
					y = y0 + dot[:y]
					color = @img.pixel_color(x,y)
					
					dots << Dot.new(
						x: x,
						y: y,
						color: color,
					)
				end
				
				one_ray.dots = dots

				all_rays << one_ray
			end

			return all_rays
		end

		def detect_best_ray(rays_bunch)
			#puts "#{__method__}(#{rays_bunch})"

			ray = rays_bunch.first

			[ray[:x], ray[:y]]
		end
end

class Ray
	attr_reader :angle, :radius, :weight, :dots
	
	def initialize(opt={})
		#puts ''; puts "#{self.class}.#{__method__}(#{opt})"
		@angle = opt.fetch(:angle)
		@radius = opt.fetch(:radius)
		@dots = nil
		@weight = 0
	end
	
	def dots=(dots_array)
		#puts "#{self.class}.#{__method__}(dots_array.size: #{dots_array.size})"
		@dots = dots_array
		calc_weight
		#puts "ray weight: #{self.weight}"
	end
	
	private
		def calc_weight
			#puts "#{self.class}.#{__method__}()"
			@dots.each { |one_dot|
				@weight += one_dot.weight
			}
		end
end

class Dot
	attr_reader :x, :y, :color, :weight
	
	def initialize(opt={})
		#puts "#{self.class}.#{__method__}(#{opt})"
		@x = opt.fetch(:x)
		@y = opt.fetch(:y)
		@color = opt.fetch(:color)
		@weight = (65535-@color.red) + (65535-@color.green) + (65535-@color.blue)
		#puts "dot weight: #{@weight}"
	end
end


case ARGV.count
when 4
	img_file = ARGV[0]
	start_x = ARGV[1].to_i
	start_y = ARGV[2].to_i
	search_radius = ARGV[3].to_i
else
	STDERR.write("Usage: #{__FILE__} <img_file> <start_x> <start_y> <search_radius>\n")
	exit 1
end

pf = PathFinder.new(img_file)
path = pf.find_path(x: start_x, y: start_y, radius: search_radius)
puts "path: #{path.inspect}"
