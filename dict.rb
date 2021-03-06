#!/usr/bin/env ruby

require "csv"

class Dict
  def initialize
    @canonical = open(File.join(__dir__, "data", "canonicals.txt"))
  end

  def dict
    gen_dict = genera_dict
    uninomials = {}
    genera = {}
    species = {}
    total = { uninomials: 0, genera: 0, species: 0 }
    @canonical.each_with_index do |c, i|
      i += 1
      puts(format("Process %s canonicals", i)) if (i % 1_000_000).zero?
      next if c.match("×")
      words = c.split(" ")
      words.each_with_index do |w, j|
        if words.size == 1 && !gen_dict.key?(w)
          uninomials.key?(w) ? uninomials[w] += 1 : uninomials[w] = 1
          total[:uninomials] += 1
        elsif words.size == 1 || j.zero?
          if gen_dict.key?(w)
            genera.key?(w) ? genera[w] += 1 : genera[w] = 1
            total[:genera] += 1
          else
            uninomials.key?(w) ? uninomials[w] += 1 : uninomials[w] = 1
            total[:uninomials] += 1
            next
          end
        else
          species.key?(w) ? species[w] += 1 : species[w] = 1
          total[:species] += 1
        end
      end
    end
    fix_uninomials(uninomials, genera, total)
    save(uninomials, genera, species, total)
  end

  private

  def fix_uninomials(uninomials, genera, total)
    uninomials.each do |k, v|
      next unless genera.key?(k)
      uninomials.delete(k)
      genera[k] += v
      total[:uninomials] -= v
      total[:genera] += v
    end
  end

  def save(uninomials, genera, species, total)
    u = CSV.open(File.join(__dir__, "data", "uninomials.csv"), "w:utf-8")
    g = CSV.open(File.join(__dir__, "data", "genera.csv"), "w:utf-8")
    s = CSV.open(File.join(__dir__, "data", "species.csv"), "w:utf-8")
    t = CSV.open(File.join(__dir__, "data", "total.csv"), "w:utf-8")
    [[uninomials, u], [genera, g], [species, s], [total, t]].each do |src, csv|
      src.each do |k, v|
        csv << [k, v]
      end
      csv.close
    end
  end

  def genera_dict
    res = {}
    open(File.join(__dir__, "data", "genera.txt")).each_with_index do |g, i|
      i += 1
      puts(format("Making genera dictionary %s", i)) if (i % 1_000_000).zero?
      g = g.strip
      words = g.split(" ")
      puts "Bad genera #{words.join(' ')}" if words.size > 1
      res[g] = 1 unless res.key?(g)
    end
    res
  end
end

d = Dict.new
d.dict
