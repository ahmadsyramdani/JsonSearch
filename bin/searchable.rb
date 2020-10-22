require 'json'
require 'pp'
require 'table_print'

class Searchable
  def initialize(param)
    @params = str_to_array(param)
    base_path = File.join(File.dirname(File.expand_path(__FILE__)))
    file_path = File.join(base_path,'..','data.json')
    @data = JSON.parse(File.read(file_path))
    @exact_param = scan_exact_param(param)
    @negative_param = scan_negative_param(param)
  end

  def run
    tp fulltextsearch, 'Name', { 'Type' => {:width => 60} }, { 'Designed by' => {:width => 100} }
  end

  def str_to_array(str)
    param = str.downcase.split(/\s(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/)
    param = rm_double_quote(param)
    return param
  end

  def scan_exact_param(str)
    scanner = str.downcase.scan(/".*?"/)
    scanner = rm_double_quote(scanner)
    return scanner
  end

  def scan_negative_param(str)
    scanner = str.downcase.scan(/\--\w+/)
    scanner = rm_double_quote(scanner)
    return scanner
  end

  def rm_double_quote(arr)
    return arr.map {|s| s.gsub(/(^ +)|( +$)|(^["']+)|(["']+$)/,'')}
  end

  def fulltextsearch
    return by_name unless by_name.empty? #priority search
    return by_fields #secondary search
  end

  def by_name
    return @data.select{|key| key['Name'].downcase.split(" ").sort === @params.sort }
  end

  def by_fields
    data = by_exact unless @exact_param.empty?
    data = by_spesifict if !data || data.empty?
    data = by_global if !data || data.empty?
    data = by_negative(data) unless @negative_param.empty?
    return data
  end

  def by_spesifict
    return @data.select{ |key| Regexp.union(@params) =~ key['Type'].downcase &&
      Regexp.union(@params) =~ key['Designed by'].downcase }
  end

  def by_exact
    @no_exact = @params - @exact_param
    return @data.select{ |key| Regexp.union(@no_exact) =~ key['Type'].downcase &&
      Regexp.union(@exact_param) =~ key['Designed by'].downcase }
  end

  def by_global
    return @data.select{ |key| Regexp.union(@params) =~ key['Name'].downcase ||
      Regexp.union(@params) =~ key['Type'].downcase ||
      Regexp.union(@params) =~ key['Designed by'].downcase }
  end

  def by_negative(data)
    @negative_param = @negative_param.map{|s| s.gsub('--', '')}
    @params = @params - @negative_param
    return data.reject{ |key| Regexp.union(@negative_param) =~ key['Name'].downcase ||
      Regexp.union(@negative_param) =~ key['Type'].downcase ||
      Regexp.union(@negative_param) =~ key['Designed by'].downcase }
  end
end
