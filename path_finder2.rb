#!/usr/bin/env ruby
# coding: utf-8
require 'rmagick'
require 'mathn'
include Magick

class PathFinder
	def initialize(img_file)
		@img = ImageList.new(img_file).first
	end

	def find_path(start_x, start_y, opt={})
		# настройка пераметров
		@search_radius = opt.fetch(:radius,10)
		
		# рассчёт шаблона лучей
		@rays_template = calc_rays_template()

		# получение массива шагов
		all_steps = []
		
		step = get_step(start_x,start_y)
		all_steps << [step[:x],step[:y]]
		
		while step = get_step(step[:x],step[:y])
			all_steps << [step[:x],step[:y]]
			break if (step[:x]==0 || step[:y]==0)
		end
		
		return all_steps
	end

	private

		def calc_rays_template()
			
		end

		def get_step(x,y)
			{ x: rand(5), y: rand(5) }
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
path = pf.find_path(10,10)
puts path.inspect
