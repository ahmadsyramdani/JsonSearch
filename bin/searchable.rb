require 'json'
require 'pp'
require 'table_print'

class Searchable
  def initialize(param)
    @params = str_to_array(param) #convert string to array
    base_path = File.join(File.dirname(File.expand_path(__FILE__)))
    file_path = File.join(base_path,'..','data.json')
    @data = JSON.parse(File.read(file_path)) #get data from JSON file
    @exact_param = scan_exact_param(param) #get string contains exact param "string"
    @negative_param = scan_negative_param(param) #get string contains negative param "--negative" > "negative"
  end

  def run
    #print output to console using table print. it makes look pretty
    tp fulltextsearch, 'Name', { 'Type' => {:width => 60} }, { 'Designed by' => {:width => 100} }
  end

  private
  
  def str_to_array(str)
    param = str.downcase.split(/\s(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/) #split by space and remove whitespaces
    rm_double_quote(param) #remove double quotes with a slash
  end

  def scan_exact_param(str)
    scanner = str.downcase.scan(/".*?"/) #get string covered quotations e.g. 'hello "world"'
    rm_double_quote(scanner) #remove double quotes with slash
  end

  def scan_negative_param(str)
    scanner = str.downcase.scan(/\--\w+/) #get string who has a special character in the beginning e.g. '--array'
    rm_double_quote(scanner) #remove double quotes with a slash
  end

  def rm_double_quote(arr)
    #remove double quotes with slash "\"here\"" to "here"
    arr.map {|s| s.gsub(/(^ +)|( +$)|(^["']+)|(["']+$)/,'')}
  end

  def fulltextsearch
    return by_name unless by_name.empty? #assuming search by name as priority
    return by_fields #then search custom if by name is empty
  end

  def by_name
    @data.select{|key| key['Name'].downcase.split(" ").sort === @params.sort }
  end

  def by_fields
    data = by_exact unless @exact_param.empty? #search if param is the exact match type
    data = by_spesific if !data || data.empty? #search by specific type of exact have no data
    data = by_global if !data || data.empty? #search by global type if by_spesific have no data
    data = by_negative(data) unless @negative_param.empty? #combine matched search with negative type
    return data
  end

  def by_spesific
    @data.select{ |key| Regexp.union(@params) =~ key['Type'].downcase &&
      Regexp.union(@params) =~ key['Designed by'].downcase }
  end

  def by_exact
    @no_exact = @params - @exact_param
    @data.select{ |key| Regexp.union(@no_exact) =~ key['Type'].downcase &&
      Regexp.union(@exact_param) =~ key['Designed by'].downcase }
  end

  def by_global
    @data.select{ |key| Regexp.union(@params) =~ key['Name'].downcase ||
      Regexp.union(@params) =~ key['Type'].downcase ||
      Regexp.union(@params) =~ key['Designed by'].downcase }
  end

  def by_negative(data)
    @negative_param = @negative_param.map{|s| s.gsub('--', '')}
    data.reject{ |key| Regexp.union(@negative_param) =~ key['Name'].downcase ||
      Regexp.union(@negative_param) =~ key['Type'].downcase ||
      Regexp.union(@negative_param) =~ key['Designed by'].downcase }
  end
end
