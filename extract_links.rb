require_relative 'column_pdf'
require "pdf/reader"
require 'uri'
require 'open-uri'
require 'open_uri_redirections'
require 'pry'

module CSVAble

  @@separator = ";"

  def to_csv_line(props)
    s = props.inject("")  { |acc, v| acc += v.to_s + @@separator }
    s.chomp(@@separator) + "\n"
  end

  def to_csv_list(attr)
    attr.inject("") { |acc, entry| acc += entry.to_csv }
  end

  def to_csv
    to_s
  end

end

class ConferenceList
  include CSVAble

  attr_accessor :conferences

  def to_csv
    props = ["Conf", "Ed", "Paper", "URL", "Code", "Suspicious", "Live", "Ref", "DOI", "Type"]
    to_csv_line(props) + to_csv_list(@conferences)
  end

end


class Conference
  include CSVAble

  attr_accessor :title
  attr_accessor :editions

  def to_csv
    to_csv_list @editions
  end

  def to_s
    @title
  end

end

class Edition
  include CSVAble

  attr_accessor :year
  attr_accessor :papers

  def to_csv
    to_csv_list @papers
  end

  def to_s
    @year
  end

end

class Paper
  include CSVAble

  attr_reader :urls

  def initialize(conference, edition, filename)
    @conference = conference
    @edition = edition
    @file = filename
    @paper = @file.split("/").last
    @urls = []
  end

  def parse_urls
    reader = PDF::Reader.new(@file)
    in_references = false
    reader.pages.each do |page|
      text = page.text
      puts text
      if text.include? "References" # this is a super-rough heuristic for whether a link appears in the refs
        in_references = true
      end
      urls = URI.extract(text, ['http', 'https']).map do |url|
        URL.new(@conference, @edition, self, url, in_references).sanitize.evaluate_liveness
      end
      @urls += urls unless urls.size == 0
    end
  end

  def to_csv
    to_csv_list @urls
  end

  def to_s
    @paper
  end

end

class URL
  include CSVAble

  attr_reader :url

  def initialize(conference, edition, paper, urlstring, in_references)
      @conference = conference
      @edition = edition
      @paper = paper
      @url = urlstring
      @response_code = -1
      @ref = in_references
  end

  def evaluate_liveness
    begin
      response = open(URI.parse(@url), :allow_redirections => :all)
      @response_code = response.status[0].to_i
    rescue OpenURI::HTTPError => e
      @response_code = e.io.status[0]
    rescue Errno::ETIMEDOUT
      @response_code = 443
    rescue Errno::ECONNREFUSED
      @response_code = 404
    rescue SocketError
      @response_code = 404    # that _should_ be the case of a hostname that does not exist
    rescue
      @response_code = 666    # there's no error code for that, but let's define something :)
    end
    STDERR.puts "Evaluated #{@url} to #{@response_code}"
    self
  end

  def sanitize
    # add here all kinds of line ending sanitizations that turn out to be necessary
    @url = "http://garbo" unless @url.start_with?("http://") || @url.start_with?("https://")
    @url.chomp!(",")
    @url.chomp!(".")
    @url.chomp!(")")
    self
  end

  def suspicious?
    @url == "http://garbo" || @url == "http://" || @url == "http://www" || @url.end_with?("-")
  end

  def live?
    @response_code == 200
  end

  def in_refs?
    @ref
  end

  def is_doi?
    @url.include?("doi")
  end

  def hosting_type
    if @url.include?("github")
      "github"
    elsif @url.include?(".ac.") || @url.include?(".edu.") || @url.include?("uni")
      "academic"
    elsif @url.include?("goo.gl") || @url.include?("tinyurl")
      "shortener"
    else
      "other"
    end
  end

  def to_csv
    props = [@conference, @edition, @paper, @url, @response_code,
      suspicious?, live?, in_refs?, is_doi?, hosting_type]
    to_csv_line props
  end

end

directory = ARGV[0]
# we assume a dir structure of "conf/edition/papers.pdf"
conferences = ConferenceList.new
conferences.conferences = []
Dir[directory+"/*"].each do |conference|
  theConf = Conference.new
  theConf.title = conference.split("/").last
  theConf.editions = []
  conferences.conferences << theConf
  Dir[conference+"/*"].each do |edition|
    theEdition = Edition.new
    theEdition.year = edition.split("/").last
    theEdition.papers = []
    theConf.editions << theEdition
    Dir[edition+"/*pdf"].each do |paper|
      paper = Paper.new(theConf, theEdition, paper)
      paper.parse_urls
      theEdition.papers << paper
    end
  end
end

puts conferences.to_csv
