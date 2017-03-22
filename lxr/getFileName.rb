#!/usr/bin/ruby -w

require 'find'

require 'pathname'
p = Pathname.new(File.dirname(__FILE__)).realpath

#Find.find('/home/jdi/ysx/plugin') do |path|
path = ARGV[0]

if path.index(".graph")
	dotPath = path.gsub(".graph",".dot")
	tempSvgPath = path.gsub(".graph","_temp.svg")
	svgPath = path.gsub(".graph",".svg")
		
	system "ruby #{p}/dot.rb #{path} #{dotPath}"
	system "dot -Tsvg #{dotPath} -o #{tempSvgPath}"
	system "ruby #{p}/th_pic.rb #{tempSvgPath} #{svgPath} aaa bbb ccc"
	
	#system "cp #{svgPath} #{ARGV[1]}"
end

