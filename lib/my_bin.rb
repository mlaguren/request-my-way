# frozen_string_literal: true
require 'hashids'
require 'fileutils'

class MyBin
  attr_reader :folder

  def initialize
    hashids = Hashids.new("request-my-way", 8)
    timestamp = Time.now.to_i
    @folder = "/mybin/#{hashids.encode(timestamp)}"

    folder_path = File.join("public", @folder)
    FileUtils.mkdir_p(folder_path) unless File.exist?(folder_path)
  end
end