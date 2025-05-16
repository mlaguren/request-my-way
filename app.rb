# frozen_string_literal: true
require_relative 'lib/my_bin'
require 'sinatra'

get '/' do
  erb :index
end

get '/admin' do
  bin_path = File.join('public', 'mybin')
  @bins = Dir.exist?(bin_path) ? Dir.children(bin_path).select { |f| File.directory?(File.join(bin_path, f)) } : []
  erb :admin
end

post '/admin/delete' do
  selected_bins = params['bins'] || []
  base_path = File.join('public', 'mybin')

  selected_bins.each do |bin|
    bin_path = File.join(base_path, bin)
    FileUtils.rm_rf(bin_path) if File.directory?(bin_path)
  end

  redirect '/admin'
end

post '/admin/delete_all' do
  base_path = File.join('public', 'mybin')
  Dir.children(base_path).each do |bin|
    FileUtils.rm_rf(File.join(base_path, bin))
  end

  redirect '/admin'
end

post '/mybin' do
  bin = MyBin.new
  redirect "#{bin.folder}"
end

get '/mybin/:id' do
  folder = "/mybin/#{params[:id]}"
  folder_path = File.join('public', folder)

  halt 404, "Bin not found" unless File.directory?(folder_path)

  files = Dir.glob(File.join(folder_path, '*.json')).sort.reverse
  requests = files.map do |file|
    {
      filename: File.basename(file),
      content: JSON.parse(File.read(file))
    }
  end

  erb :mybin, locals: { bin_id: folder, requests: requests }
end

post '/mybin/:id/delete' do
  folder = params[:id]
  file = params[:file]
  folder_path = File.join('public', folder)
  file_path = File.join(folder_path, file)

  if File.exist?(file_path)
    File.delete(file_path)
  end

  redirect "/mybin/#{folder}"
end

get '/mybin/:id/api' do
  folder = "/mybin/#{params[:id]}"
  folder_path = File.join('public', folder)
  halt 404, "Bin not found" unless File.directory?(folder_path)

  timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
  file_path = File.join(folder_path, "#{timestamp}.json")

  File.write(file_path, JSON.pretty_generate({
                                               method: request.request_method,
                                               request_url: request.url,
                                               headers: request.env.select { |k, _| k.start_with? 'HTTP_' },
                                               params: params,
                                             }))

  status 200
  body "Request captured."
end

post '/mybin/:id/api' do
  folder = "/mybin/#{params[:id]}"
  folder_path = File.join('public', folder)
  halt 404, "Bin not found" unless File.directory?(folder_path)

  timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
  file_path = File.join(folder_path, "#{timestamp}.json")

  File.write(file_path, JSON.pretty_generate({
                                               method: request.request_method,
                                               request_url: request.url,
                                               headers: request.env.select { |k, _| k.start_with? 'HTTP_' },
                                               params: params,
                                               body: request.body.read
                                             }))

  status 200
  body "Request captured."
end
