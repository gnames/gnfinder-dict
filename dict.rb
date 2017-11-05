#!/usr/bin/env ruby

require "pg"

# Canonical gets canonicals from gnindex
class Canonicals
  def initialize
    host = ENV["GNINDEX_HOST"]
    port = ENV["GNINDEX_PORT"]
    user = ENV["GNINDEX_USER"]
    password = ENV["GNINDEX_PASSWORD"]
    dbname = "gnindex"
    @db = PG.connect(host: host, port: port, dbname: dbname,
                     user: user, password: password)
  end

  def canonicals
    res = @db.exec("SELECT DISTINCT canonical FROM name_strings")
    f = open(File.join(__dir__, "data", "canonicals.txt"),
             "w:utf-8")
    res.each_with_index do |row, i|
      i += 1
      puts format("Row %s", i) if (i % 100_000).zero?
      f.write(row["canonical"] + "\n") if row["canonical"]
    end
    f.close
  end
end

c = Canonicals.new

c.canonicals
