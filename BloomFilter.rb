require 'digest/sha1'

class BloomFilter
  attr_accessor :data_size, :hash_size, :data

  def initialize(data_size: 100, hash_size: 7)
    @data_size = data_size
    @hash_size = hash_size
    @data = Array.new(@data_size, 0)
  end

  def add(item)
    @hash_size.times do |n|
      @data[hash_code_index(item, n)] += 1
    end
  end

  def hash_code_index(item, n)
    value = [item, n].hash
    value % @data_size
  end

  def has?(item)
    @hash_size.times do |n|
      return false if @data[hash_code_index(item, n)] == 0
    end
    true
  end
end



require 'benchmark'

data_size = 958506
hash_size = 66
N = 10000

filter = BloomFilter.new(data_size: data_size, hash_size: hash_size)

contains = []
result = Benchmark.realtime do
  N.times do
    item = rand N
    contains << item
    filter.add item
  end
end
puts "#{result} taken to store #{N} items to BloomFilter"

true_count = 0
result = Benchmark.realtime do
  (0..N).each do |n|
    if contains.include?(n)
      true_count += 1
    end
  end
end
puts "#{result} taken to check #{N} items"

estimate_count = 0
result = Benchmark.realtime do
  (0..N).each do |n|
    if filter.has?(n)
      estimate_count += 1
    end
  end
end
puts "#{result} taken to check #{N} items by BloomFilter"

puts "Estimate count / True Count = #{estimate_count} / #{true_count}"
