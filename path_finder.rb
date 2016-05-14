# coding: utf-8
require 'rmagick'

class PathFinder
	@image
	@search_radius
	@radius_step

	private
		@angle_step

	def initialize(image_file,opt={})
		@image = Magick::Image.read(image_file).first
		@search_radius = opt[:search_radius] || 10
		@radius_step = opt[:radius_step] || 1
		
		perimeter = @search_radius*2*Math::PI
		puts "периметр: #{perimeter}"
		
		@angle_step = Math::PI / perimeter/2
		puts "угловой шаг: #{@angle_step} (#{@angle_step*Math::PI/180})"
	end

	def find_path(x0,y0)
		puts "#{__method__}(#{x0},#{y0})"
	
		path = []

		#loop do
			x,y = find_step(x0.to_f,y0.to_f)
		#	break if (0==x || 0==y)
		#	path << [x,y]
		#end
	end

	def find_step(x0,y0)
		puts "#{__method__}(#{x0},#{y0})"
	
		rays = []
		angle = 0
		
		while angle <= Math::PI
			#puts "ANGLE: #{angle}"
			
			ray_data = []
			radius = @radius_step

			while radius <= @search_radius
				#puts "RAIUS: #{radius}"

				x = Math.sqrt( 1 / (Math.tan(angle)**2 + radius**2) )
				y = Math.tan(angle)*x
				#puts "x,y: #{x},#{y}"
				
				x = x0 + x
				y = y0 + y
				#puts "x,y: #{x},#{y}"

				#print "ANGLE: #{angle}, RAIUS: #{radius}, "
				
				pixel_params = get_pixel_params(x,y)
				
				puts "pixel_params: #{pixel_params}"
				#puts ''

				ray_data << pixel_params

				radius += @radius_step
				#sleep 0.01
			end

			#puts "ray_data: #{ray_data}"
			rays << ray_data

			angle += @angle_step
			
			puts ''
		end

		#puts "RAYS:"; rays.each { |one_ray| puts "#{one_ray}" }
	end

	def get_pixel_params(x,y)
		x = x.round
		y = y.round
	
		#puts "#{__method__}(#{x},#{y})"
		
		pixel = @image.get_pixels(x,y,1,1).first
		params = pixel.red + pixel.green + pixel.blue
		return params
	end
end

case ARGV.count
when 3
	input_file = ARGV[0]
	x = ARGV[1]
	y = ARGV[2]
else
	STDERR.write "Usage: #{__FILE__} <image_file> <x> <y>"
	STDERR.write "\n"
	exit 1
end
	

pf = PathFinder.new(
	input_file, 
	angle_step: 0.1, 
	radius_step: 1, 
	search_radius: 10
	
)

pf.find_path x,y
