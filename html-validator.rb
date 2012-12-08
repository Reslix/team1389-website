#!/usr/bin/env ruby
require 'colorize'
require 'net/http'
require 'find'

def valid?(html)
  req=Net::HTTP::Post.new('/')
  req.body=html
  req["Content-Type"]="text/html; charset=utf-8"
  resp=Net::HTTP.new('html5.validator.nu',80).start do |http|
    http.request req
  end
  return ((resp.body=~/[eE]rror/).nil?)
end

@exit_code=0

OUT_DIR="./out"

Find.find(OUT_DIR) do |path|
  if path.end_with?('.html')
    print "#{path.gsub(OUT_DIR,'')}:\t"
    if valid?(File.read(path))
      puts "VALID".green
    else
      puts "INVALID".red
      @exit_code=1
    end
  end
end

Kernel.exit(@exit_code)