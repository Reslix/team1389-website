require 'coffee-script'
require 'sass'
require './src/stylesheets/bourbon/lib/bourbon'
require 'erb'

class Conversion
  @process_exts={}
  @src_dir="./src"
  @sass_options={:syntax=>:scss,:load_paths=>[File.join(@src_dir,'stylesheets'),File.join(@src_dir,'stylesheets','bourbon')]}
  
  def self.src_dir
    @src_dir
  end
  def self.src_dir=(x)
    @src_dir=x
  end
  
  def self.format(ext,extA)
    @process_exts[ext]={
      :ext=>".#{extA}",
      :blocks=>[]
    }
  end
  def self.process(*exts,&block)
    exts.each {|ext| @process_exts[ext][:blocks]<<block }
  end
  
  def self.type(path)
    ext=ext(path)
    if @process_exts.has_key?(ext) and File.exists?(File.join(@src_dir,path+@process_exts[ext][:ext]))
      return :convert
    elsif File.exists?(File.join(@src_dir,path))
      return :stream
    else
      return :not_found
    end
  end
  def self.ext(path)
    path.split('.').last.to_sym
  end
  def self.convert(path)
    ext=ext(path)
    out=File.read(File.join(@src_dir,path+@process_exts[ext][:ext]))
    @process_exts[ext][:blocks].each {|blck| out=blck.call(out) }
    return out
  end
  
  format :js,'coffee'
  format :css,'scss'
  format :html,'erb'
  
  process :js do |js|
    CoffeeScript.compile(js)
  end
  process :css do |css|
    Sass::Engine.new(css,@sass_options).render
  end
  
  class Erbifier
    attr_accessor :subcontents,:src_dir
    
    def initialize
      @stylesheets=[]
      @javascripts=[]
    end
    def title_string
      str=@title.nil? ? '' : " - #{@title}"
      "FRC Team 1389#{str}"
    end
    def title(x)
      @title=x
    end
    def stylesheet(*x)
      @stylesheets+=x.map {|x| "#{x}.css"}
    end
    def javascript(*args)
      @javascripts+=args.map {|x| x.index('//') ? x : "/javascripts/#{x}.js"}
    end
    def get_binding
      binding
    end
  end
  
  process :html do |html|
    erb=Erbifier.new
    layout=ERB.new(File.read(File.join(src_dir,'layout.html.erb')))
    page=ERB.new(html)
    erb.src_dir=src_dir
    erb.subcontents=page.result(erb.get_binding)
    layout.result(erb.get_binding)
  end
  
  def self.minify
    require 'uglifier'
    
    process :js do |js|
      Uglifier.compile(js)
    end
    @sass_options[:style]=:compressed
    process :html do |html|
      html=html.gsub("\t","").gsub(/\n+/,"\n")
      idx=html.index("\n")
      html[0..idx]+html[idx..html.length].gsub("\n","")
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'fileutils'
  require 'cocaine'
  require 'find'
  out_dir="./out"
  
  @cmds={}
  def process(*arr)
    cmd=arr.pop
    arr.each {|ext| @cmds[ext]=cmd}
  end
  
  jpeg_compression=
  process 'jpg','jpeg',Cocaine::CommandLine.new("convert",":in -define jpeg:extent=100kb :out")
  process 'png',Cocaine::CommandLine.new('pngcrush',"-rem alla -rem text :in :out",:swallow_stderr=>true)
  
  Conversion::minify
  FileUtils.mkdir_p(out_dir)
  
  Find.find(Conversion::src_dir) do |path|
    parts=path.gsub(Conversion::src_dir,'').split('/')
    parts.delete('')
    next if parts.last.nil? or parts.last[0]=='.' or parts.include?('bourbon') or parts.include?('layout.html.erb')
    parts.last.gsub!('.scss','')
    parts.last.gsub!('.coffee','')
    parts.last.gsub!('.erb','')
    out_path=File.join(*([out_dir]+parts))
    ext=parts.last.split('.').last
    if File.directory?(path)
      FileUtils.mkdir_p(out_path)
      next
    elsif @cmds[ext]
      unless File.exists?(out_path) and File.mtime(out_path)>File.mtime(path)
        @cmds[ext].run :in=>path,:out=>out_path
      end
    else
      type=Conversion::type(parts.join('/'))
      case type
      when :stream
        FileUtils.cp(path,out_path)
      when :convert
        File.open(out_path,'w') do |f|
          f.write(Conversion::convert(parts.join('/')))
        end
      else
        raise "Houston, we have a problem! #{type.inspect} #{parts.join('/').inspect}"
      end
    end
  end
end