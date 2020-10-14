#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'open3'

class Cleaner
  def initialize(opts = {})
    @verbose = opts[:verbose]
    @noop = opts[:noop]

    @docker_images = list_docker_images
    @up_containers = `docker ps -q --no-trunc`.split("\n")
    @down_containers = `docker ps -q --no-trunc --filter 'status=created' --filter 'status=exited'`.split("\n")
    @images_dangling = `docker images -q --no-trunc --filter 'dangling=true'`.split("\n")
  end

  def list_docker_images
    cmd_res = `docker images`.split("\n")
    cmd_res.delete_at(0)
    all_images = cmd_res.map do |line|
      split_line = line.split
      "#{split_line[0]}:#{split_line[1]}"
    end
    all_images.uniq
  end

  def clean_images(whitelist = nil)
    whitelist = Regexp.new(whitelist) unless whitelist.nil?

    images_in_use = Set.new []
    @up_containers.each do |c|
      image_name = `docker inspect --format={{.Config.Image}} #{c}`.strip # workaround of not adding tag to image name if tag =latest
      image_name = image_name << ':latest' unless image_name.match(/\:[-\.\w]+$/)
      images_in_use.add(image_name)
    end

    @images_dangling.each do |i|
      puts "Removing dangling #{i}" if @verbose
      `docker rmi #{i}` unless @noop
    end

    @docker_images.each do |image|
      if images_in_use.include?(image)
        puts "Image in use: #{image}"
      elsif !whitelist.nil? && !whitelist.match(image).nil?
        puts "Image in whitelist: #{image}"
      else
        puts "Removing image: #{image}"
        `docker rmi #{image}` unless @noop
      end
    end
  end

  def clean_containers
    @down_containers.each do |container|
      puts "Removing container: #{container}"
      `docker rm #{container}` unless @noop
    end
  end

  def clean_volumes
    stdin, stdout = Open3.popen3("docker volume ls --filter 'dangling=true'")
    volumes = stdout.read.split("\n")
    volumes.delete_at(0)
    volumes.each do |entry|
      volume = entry.split(' ')[1]
      puts "Removing volume: #{volume}"
      `docker volume rm #{volume}` unless @noop
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'optparse'

  options = {
    whitelist: nil,
    verbose: false,
    noop: false
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options]"

    opts.on('-wWHITELIST', '--whitelist=WHITELIST', 'Whitelist regex for images') do |w|
      options[:whitelist] = w
    end

    opts.on('-v', '--verbose', 'Add more info to output') do |_v|
      options[:verbose] = true
    end

    opts.on('-n', '--noop', 'Does not perform real actions') do |_v|
      options[:noop] = true
    end

    opts.on('-h', '--help', 'Prints this help') do
      puts opts
      exit
    end
  end.parse!

  puts 'No real actions will be performed' if options[:noop]

  c = Cleaner.new(options)
  c.clean_containers
  c.clean_images(options[:whitelist])
  c.clean_volumes
end
