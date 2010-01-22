$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'net/ssh'
require 'highline/import'
require 'pp'

require File.join(File.dirname(__FILE__), 'webbynode', 'io')
require File.join(File.dirname(__FILE__), 'webbynode', 'git')
require File.join(File.dirname(__FILE__), 'webbynode', 'ssh')
require File.join(File.dirname(__FILE__), 'webbynode', 'server')
require File.join(File.dirname(__FILE__), 'webbynode', 'remote_executor')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'init')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'add_key')

module Webbynode
  VERSION = '0.1.2'
  
  class AppError < StandardError; end
  
  class Application
    attr_reader :command, :command_class
    
    def initialize(command)
      @command = command
    end
    
    def parse_command
      @command_class = Webbynode::Commands.const_get(command_class_name)
    rescue NameError
      puts "Command \"#{command}\" doesn't exist"
    end
    
    def command_class_name
      command.split("_").inject([]) { |arr, item| arr << item.capitalize }.join("")
    end
    
    def execute
      parse_command
      command_class.run
    end
    
    # Parses user input (commands)
    # Initial param is the command
    # Other params are named parameters (like 'command --this=param')
    # or options (like 'command param')
    def parse_options
      log_and_exit read_template('help') if @input.empty?
      @command  = @input.shift
      
      while @input.any?
        opt = @input.shift
        
        if opt =~ /^--(\w+)(=("[^"]+"|[\w]+))*/
          name  = $1
          value = $3 ? $3.gsub(/"/, "") : true
          @named_options[name] = value
        else
          @options << opt
        end
      end
    end
  end
end