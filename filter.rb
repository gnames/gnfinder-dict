#!/usr/bin/env ruby

require "csv"

# Filter distributes words to white and grey lists
class Filter
  def initialize
    host = ENV["GNINDEX_HOST"]
    port = ENV["GNINDEX_PORT"]
    user = ENV["GNINDEX_USER"]
    password = ENV["GNINDEX_PASSWORD"]
    dbname = "gnindex"
    @db = PG.connect(host: host, port: port, dbname: dbname,
                     user: user, password: password)
    @sp_black = sp_black
  end

  def prepare_species
    sp = CSV.open(File.join(__dir__, "data", "species.csv"))
    sp.each do |row|
      puts sp if species_problems?(row[0])
    end
  end

  def species_problems?(sp)
    return true if sp.match("\.") || sp.size == 1 || sp.match(/^[\d]/)
    return true if @sp_black.key?(sp)
    false
  end

  private

  def sp_black
    res = {}
    open(File.join(__dir__, "data", "species-black.txt")).each do |w|
      res.key?(w) ? res[w] += 1 : res[w] = 1
    end
    res
  end
end
