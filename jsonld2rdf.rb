#!/usr/bin/env ruby

require 'rubygems'
require 'json/ld'
require 'optparse'
require 'logger'
require 'fileutils'
require 'rdf/turtle'
require 'rdf/ntriples'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

options = {
  export_path: '/data/rdf',
  file: nil,
  ofile: "output",
  oformat: nil
}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: #{__FILE__} [OPTIONS]"
  opt.separator ''
  opt.separator 'Options'

  opt.on('-v', '--verbose', 'enable verbose logging') do
    options[:verbose] = true
  end
  opt.on('-f', '--file INPUTFILE', 'json-ld input file') do |id|
    options[:file] = id
  end
  opt.on('-F', '--outputfilename OUTPUTFILE', 'json-ld output filename') do |ofile|
    options[:ofile] = ofile
  end
  opt.on('-o', '--output_path PATH', 'path to store rdf') do |path|
    options[:export_path] = path
  end 
  opt.on('-O', '--output_format RDFFORMAT', 'the rdf serializing format to be exported in (ttl,nt) ') do |of|
    options[:oformat] = of
  end 
end
  
begin
  opt_parser.parse!
  mandatory = [:export_path, :file]
  missing = mandatory.select{ |param| options[param].nil? } 
  unless missing.empty?                                           
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end                                                          
rescue OptionParser::InvalidOption, OptionParser::MissingArgument 
  puts $!.to_s
  puts opt_parser
  exit                                                            
end

if options[:verbose]
  logger.level = Logger::DEBUG
end

#logger.debug "refresh token #{token.refresh_token}"
#logger.debug "authorize url #{client.authorize_url}"

begin
logger.debug "parse the json-ld file #{options[:file]}"
inputfile=File.read(options[:file])
inputstring=JSON.parse(inputfile)
rescue StandardError => e
  logger.error e
  logger.info e
  exit
end

logger.debug "convert json-ld to RDF"
graph = RDF::Graph.new << JSON::LD::API.toRdf(inputstring)

logger.debug "output in format #{options[:oformat]}"

case options[:oformat]

when 'ttl'
	output_file = File.join(options[:export_path],"#{options[:ofile]}.ttl")
	logger.debug "export to RDF in #{output_file}"
	File.open(output_file, "w") do |file|
	  RDF::Turtle::Writer.new(file) do |writer|
	  writer << graph
	  end
	end

when 'nt'
	output_file = File.join(options[:export_path],"#{options[:ofile]}.nt")
	logger.debug "export to RDF in #{output_file}"
	File.open(output_file, "w") do |file|
	  RDF::NTriples::Writer.new(file) do |writer|
	  writer << graph
	  end
	end
else
    # if nothing specified export as turtle
        logger.debug "export to RDF to STDOUT as turtle"
        STDOUT << graph.dump(:turtle)
end


#RDF::Writer.open("hello.nt") { |writer| writer << graph }


#  output_file = File.join(options[:export_path],"#{work_id}.nt")
#  begin
#    FileUtils.touch(output_file)  
#    logger.info "creating a batch job to request companies affected by roadwork with id #{work_id}"
#    post_payload= {body: { gipodId: work_id , filter: 0 }}
#    BatchJob.new(token, post_payload) do |response|
#      crab_ids = response["resultaat"]["Ondernemingen"]["features"]
#      logger.info "#{crab_ids.size} companies are affected"
#      crab_ids.each do |bussines|
#        File.open(output_file, "a") do |file|
#          RDF::NTriples::Writer.new(file) do |writer|
#            writer << rdf_generator.generate_rdf(bussines, work_id)
#          end
#        end
#      end
#      logger.info "wrote rdf to #{output_file}"
#    end    
#  rescue StandardError => e
#    logger.error e
#  end

#input = JSON.parse %({
#      "@context": {
#        "":       "http://manu.sporny.org/",
#        "foaf":   "http://xmlns.com/foaf/0.1/"
#      },
#      "@id":       "http://example.org/people#joebob",
#      "@type":          "foaf:Person",
#      "foaf:name":      "Joe Bob",
#      "foaf:nick":      { "@list": [ "joe", "bob", "jaybe" ] }
#    })
#    
#    graph = RDF::Graph.new << JSON::LD::API.toRdf(input)
#
#    require 'rdf/turtle'
#    graph.dump(:ttl, prefixes: {foaf: "http://xmlns.com/foaf/0.1/"})
#    @prefix foaf: <http://xmlns.com/foaf/0.1/> .
#
#    <http://example.org/people#joebob> a foaf:Person;
#       foaf:name "Joe Bob";
#       foaf:nick ("joe" "bob" "jaybe") .
