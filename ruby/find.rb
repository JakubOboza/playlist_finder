#!/usr/bin/env ruby

require 'nokogiri'

class Queue

  attr_accessor :bag 

  def initialize
    @bag = []
  end

  def push (node)
    @bag << node
  end

  def pop
    @bag.pop
  end

  def length
    @bag.length
  end

end

class Stack < Queue

  def pop
    el = @bag.first
    @bag = @bag.drop(1)
    el
  end

end

class Node

  attr_accessor :name, :duration, :visited, :start, :end

  def initialize(name, duration)
    @name = name.strip#.gsub(/\(.+\)/,"").strip
    @start = @name[0]
    @end = @name[-1]
    @duration = duration
    @visited = false
  end

  def visited!
    @visited = true
  end

end

class BstSolution

  attr_accessor :domain, :queue, :playlist

  def initialize(filename)
    @playlist = []
    @domain = []
    raw_data = File.read(filename)
    data = Nokogiri::XML(raw_data)
    @domain = data.xpath("/Library/Artist/Song").map do |el| 
      Node.new(el.attribute("name").text, el.attribute("duration").text)
    end.uniq{|node| node.name}.compact
    @queue = Queue.new
  end

  def all_starting_at(letter)
    @domain.find_all{|x| x.start.upcase.strip == letter.upcase.strip && !x.visited }
  end

  def find_root(start_title)
    @domain.find{|x| x.start.upcase.strip == start_title[0].upcase.strip}
  end

  def solve(start_title, end_title)
    @queue.push(self.find_root(start_title))
    # loop start ->
    while(@queue.length > 0)
      element = @queue.pop
      element.visited!
      @playlist << element
      if element.name == end_title
        puts "We found it! #{element.inspect}"
        break
      else
        childs = self.all_starting_at(element.end)
        childs.each{|child| self.queue.push(child)}
      end
    end
  end

end

puts "-----> BST <-----"

SONGS_FILE_PATH = "../songs/SongLibrary.xml"

b = BstSolution.new(SONGS_FILE_PATH)
b.solve("Die Eier Von Satan", "Newborn Friend")
puts "Play list size: #{b.playlist.size}"

puts "------> BST <-----"

b = BstSolution.new(SONGS_FILE_PATH)
b.solve("Fantasy Girl", "Leave It")
puts "Play list size: #{b.playlist.size}"

puts "-----> BST <------"

b = BstSolution.new(SONGS_FILE_PATH)
b.solve("Falling For You", "Everything")
puts "Play list size: #{b.playlist.size}"

b.playlist.each do |song|
  puts "#{song.start} #{song.name} #{song.end}"
end
