#!/usr/bin/env ruby

require "csv"
require "fileutils"

# Filter distributes words to white and grey lists
class Filter
  def initialize
    @sp_black = sp_black
    @uninom_black = uninom_black
    @common_words = common_words
    @canonical = canonical
  end

  def prepare_species
    grey = CSV.open(File.join(__dir__, "dict", "grey",
                              "species.csv"), "w:utf-8")
    white = CSV.open(File.join(__dir__, "dict", "white",
                               "species.csv"), "w:utf-8")
    sp = CSV.open(File.join(__dir__, "data", "species.csv"))
    sp.each_with_index do |row, i|
      i += 1
      puts(format("Species dictionaries %s", i)) if (i % 100_000).zero?
      next if species_problems?(row[0])
      grey?(row[0]) ? grey << row : white << row
    end
    grey.close
    white.close
  end

  def prepare_genera
    puts "Making genera dictionaries"
    grey_species = CSV.open(File.join(__dir__, "dict", "grey",
                            "genera_species.csv"), "w:utf-8")
    grey = CSV.open(File.join(__dir__, "dict", "grey",
                              "genera.csv"), "w:utf-8")
    white = CSV.open(File.join(__dir__, "dict", "white",
                               "genera.csv"), "w:utf-8")
    gen = CSV.open(File.join(__dir__, "data", "genera.csv"))
    gen.each_with_index do |row, i|
      i += 1
      puts(format("Genera dictionaries %s", i)) if (i % 100_000).zero?
      next if genera_problems?(row[0])
      grey?(row[0].downcase) ? grey_genera(grey_species, grey, row) : white << row
    end
    grey.close
    white.close
  end

  def prepare_uninomials
    puts "Making uninomials dictionaries"
    grey = CSV.open(File.join(__dir__, "dict", "grey",
                              "uninomials.csv"), "w:utf-8")
    white = CSV.open(File.join(__dir__, "dict", "white",
                               "uninomials.csv"), "w:utf-8")
    un = CSV.open(File.join(__dir__, "data", "uninomials.csv"))
    un.each_with_index do |row, i|
      i += 1
      puts(format("Uninomial dictionaries %s", i)) if (i % 100_000).zero?
      next if genera_problems?(row[0])
      grey?(row[0].downcase) ? grey << row : white << row
    end
    grey.close
    white.close
  end

  def copy_files
    FileUtils.cp(File.join(__dir__, "data", "species-black.txt"),
                 File.join(__dir__, "dict", "black", "species.csv"))
    FileUtils.cp(File.join(__dir__, "data", "uninomials-black.txt"),
                 File.join(__dir__, "dict", "black", "uninomials.csv"))
    FileUtils.cp(File.join(__dir__, "data", "common-eu-words.txt"),
                 File.join(__dir__, "dict", "common", "eu.csv"))
  end

  private

  def genera_problems?(gen)
    return true if gen[-1] == "."
    return true if @uninom_black.key?(gen.downcase)
    false
  end

  def grey_genera(grey_species, grey, row)
    grey << row
    return unless @canonical.key?(row[0])

    res = {}
    @canonical[row[0]].each do |can|
      words = can.split(" ")
      bad_species = false
      words[1..-1].each do |w|
        if species_problems?(w)
          bad_species = true
          break
        end
      end
      res[can] = 1 unless res.key?(can) || bad_species
      next if words.size < 3 || (words[1] && species_problems?(words[1]))
      words[1..-1].each do |w|
        next if w.size < 3 || species_problems?(w)
        name = [words[0], w].join(" ")
        res[name] = 1 unless res.key?(name)
      end
    end

    res.each_key do |k|
      grey_species << [k]
    end
  end

  def species_problems?(sp)
    # return true if sp.match("\.") || sp.size == 1 || sp.match(/^[\d]/)
    return true if sp.size == 1 || sp.match(/[\d]/)
    return true if @sp_black.key?(sp)
    return true unless sp.match(/\./).nil?
    false
  end

  def grey?(word)
    return true if word.size < 4
    @common_words.key?(word)
  end

  def sp_black
    res = {}
    open(File.join(__dir__, "data", "species-black.txt")).each do |w|
      w = w.strip
      res.key?(w) ? res[w] += 1 : res[w] = 1
    end
    res
  end

  def canonical
    res = {}
    open(File.join(__dir__, "data", "canonicals.txt")).each_with_index do |c, i|
      i += 1
      puts(format("Making canonical dictionary %s", i)) if (i % 1_000_000).zero?
      next if c.match("×")
      c = c.strip
      words = c.split(" ")
      next if words.size < 2
      res.key?(words[0]) ? res[words[0]] << c : res[words[0]] = [c]
    end
    res
  end

  def uninom_black
    res = {}
    open(File.join(__dir__, "data", "uninomials-black.txt")).each do |w|
      w = w.strip
      res.key?(w) ? res[w] += 1 : res[w] = 1
    end
    res
  end

  def common_words
    res = {}
    words = open(File.join(__dir__, "data", "common-eu-words.txt"))
    words.each do |w|
      w = w.strip
      res.key?(w) ? res[w] += 1 : res[w] = 1
    end
    res
  end
end

f = Filter.new
f.copy_files
f.prepare_uninomials
f.prepare_genera
f.prepare_species
