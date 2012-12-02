require './conversion'
require 'sinatra'
require 'mimemagic'

get '/' do
  redirect to('/index.html')
end

get '/*' do
  path=params[:splat].first
  type=Conversion::type(path)
  if type==:stream
    cache_control :no_cache
    return send_file(File.join(Conversion::src_dir,path),:disposition=>'inline')
  elsif type==:not_found
    not_found
    content_type 'text/html'
    return Conversion::convert("404.html")
  elsif type==:convert
    content_type(MimeMagic.by_extension(path.split('.').last).to_s)
    return Conversion::convert(path)
  end
end