# gnfinder-dict

This project contains words that created problems for name-recognition with
gnfinder

## Files

make .env file according to .env.dev

. .env && canonical.rb -- goes to Global Names Index and fetches all data

It should generate data/names.txt and data/genera.txt

You will need to create list of canonicals as well at `data/canonicals.txt`.
Note that the canonicals are only from 'curated' data.

gnparser data/names.txt j 200 -f simple |awk -F '|' '{print $4}' > t
sort t |uniq > data/canonicals.tmp

You might encounter names with `|` in them, or with empty canonicals. They
should be clearly visible in canonicals.txt. Delete these.


dict.rb -- creates csv files for dictionaries

filter.rb -- creates dictionaries from canonicals, csv files, and black/grey
lists

After data are created run rsync similar to

```
/usr/bin/rsync -Pav /home/dimus/code/ruby/gnfinder-dict/dict/ /home/dimus/go/src/github.com/gnames/gnfinder/data/files/
```
