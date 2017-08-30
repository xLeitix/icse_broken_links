require_relative '../random_scripts/csv.rb'
require_relative '../PDFLinkExtractor/extract_links.rb'
require 'find'
require 'pry'

def check_line(line, all)
  puts "Checking line: #{line['URL'].to_s}"
  puts "Please enter new URL or type ENTER to leave as is"
  newurl = STDIN.gets.chomp
  if newurl == ""
    line["Validated"] = "true"
  elsif newurl == "DEL"
    all - line
  else
    url = URL.initialize_from_strings(
      line["Conf"], line["Ed"], line["Paper"], newurl, line["Ref"]
    )
    url.evaluate_liveness
    url.validated = true
    line.content = url.content_list
  end
end

def save(data, file)
  data.save(file)
end

def open_paper_pdf(filename)
  fullname = find_fullname(filename)
  fork { exec "open #{fullname}", out: File::NULL }
end

def find_fullname(filename)
  fullname = nil
  Find.find("pdfs") do |path|
    fullname = path if path.end_with? filename
  end
  return fullname
end


file = ARGV[0]
newfile = ARGV[1]
data = CSV.parse(File.new(file), true)
lines_to_check = data.find_all{ |line| line["Live"] == "false" && line["Validated"] == "false" }
puts "Needing to check #{lines_to_check.size} lines"
paper = nil
lines_to_check.each do |line|
  unless paper && paper == line["Paper"]
    paper = line["Paper"]
    puts "Opening file #{paper}"
    open_paper_pdf(paper)
  end
  check_line(line, data)
  save(data, newfile)
end
puts "Done"
