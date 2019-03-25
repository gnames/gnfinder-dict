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
    # res = @db.exec("SELECT DISTINCT canonical FROM name_strings")
    res = @db.exec("SELECT name
                      FROM name_strings ns
                        JOIN name_string_indices nsi
                          ON nsi.name_string_id = ns.id
                      WHERE canonical is not NULL and data_source_id IN
                        (SELECT id FROM data_sources WHERE is_curated = TRUE)")
    f = open(File.join(__dir__, "data", "names.txt"),
             "w:utf-8")
    res.each_with_index do |row, i|
      i += 1
      puts format("Canonicals row %s", i) if (i % 100_000).zero?
      f.write(row["name"] + "\n") if row["name"]
    end
    f.close
  end

  def genera
    gs = []
    res = @db.exec("SELECT DISTINCT name
                     FROM name_strings ns
                       JOIN name_string_indices nsi
                         ON nsi.name_string_id = ns.id
                     WHERE rank='Genus' AND data_source_id = 181
                       ORDER BY name")
    f = open(File.join(__dir__, "data", "genera.txt"), "w:utf-8")
    res.each_with_index do |row, i|
      i += 1
      puts format("Genera row %s", i) if (i % 100_000).zero?
      genus = row["name"].delete("×")
      gs << genus.split(/\s+/)[0]
    end
    gs.uniq.each { |g| f.write(g + "\n") }
    f.close
  end
end

c = Canonicals.new

c.genera
c.canonicals
