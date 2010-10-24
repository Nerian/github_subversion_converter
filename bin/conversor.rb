#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__) 
require 'optparse'
require 'conversor'
require 'ostruct'



options = {}  
optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: conversor.rb --origin path_origin --destiny path_destiny ..."

  # Define the options, and what they do
  opts.on( '-o', '--origin ORIGIN', 'The repository from which you wan to to pull the commits' ) do |origin|
    options[:origin] = origin
  end

  opts.on( '-d', '--destiny DESTINY', 'The repository to which you want to copy the commits' ) do |destiny|
    options[:destiny] = destiny
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end    

begin                                                                                                                                                                                                             
  optparse.parse!                                                                                                                                                                                                 
  mandatory = [:origin, :destiny]                                  # Enforce the presence of                                                                                                                                                
  missing = mandatory.select{ |param| options[param].nil? }        # the -o and -d switches                                                                                                                        
  if not missing.empty?                                            #                                                                                                                                             
    puts "Missing options: #{missing.join(', ')}"                  #                                                                                                                                             
    puts optparse                                                  #                                                                                                                                             
    exit
  else 
    conversor = Conversor::Conversor.new(options[:origin], options[:destiny])
    conversor.perform_conversion                                                                 #                                                                                                                                             
  end                                                              #                                                                                                                                            
rescue OptionParser::InvalidOption, OptionParser::MissingArgument      #                                                                                                                                                
  puts $!.to_s                                                           # Friendly output when parsing fails
  puts optparse                                                          # 
  exit                                                                   # 
end



