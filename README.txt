To run this script, you need to have Ruby '2.1.6' installed, bundler gem, Ruby DevKit. Then you do: 

$ bundle install
$ ruby events_finder.rb <number of pages> <JSON output file> <show output flag (1 or 0)>

If any of the parameters are not provided, then they are defaulted as such:
$ ruby events_finder.rb 10 output.json 1

Notes: I had to use Ruby '2.1.6' as 2.2 does not yet support nokogiri

Things to do:
1) Better command line parameters management
2) Add error handling. At the moment the script assumes a lot of things, like correct parameters, existence of web pages, etc
3) Currency conversion fix. At the moment the currency does not display correctly, could just be an encoding issue