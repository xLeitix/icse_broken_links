require "pdf/reader"

class MultiColumnPDF

  attr_accessor :pages

  def self.parse(file, columns, column_sep = "\t")
    _self = MultiColumnPDF.new
    _self.pages = []
    reader = PDF::Reader.new(file)
    reader.pages.each do |page|
        _self.pages << PDFPage.parse(page.text, columns, column_sep)
    end
    _self
  end

end

class PDFPage

  attr_accessor :columns

  def self.parse(pagetext, columns, column_sep = "\t")
    _self = PDFPage.new
    content_buffers = []
    columns.times { content_buffers << "" }
    pagetext.each_line do |line|
      line = line.strip.gsub(/\s\s\s\s+/, '    ')
      this_columns = line.split('    ')
      if this_columns.size > 2
        puts line
      end
      content_buffers.each_with_index do |buffer, idx|
        if this_columns[idx]
          buffer += this_columns[idx].strip
        end
        buffer += "\n"
      end
    end
    _self.columns = []
    content_buffers.each do |buffer|
      _self.columns << PDFColumn.parse(buffer)
    end
    _self
  end

end

class PDFColumn

  attr_accessor :raw

  def self.parse(columntext)
    _self = PDFColumn.new
    _self.raw = columntext
    _self
  end

end
