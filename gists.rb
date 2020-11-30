#!/usr/bin/env ruby

require 'pathname'
require 'find'
require 'thor'



class Gist
  def initialize(path:, tags: [].to_set, language: nil, description: nil)
    @path = path
    @tags = tags.map(&:downcase).to_set
    @language = language&.downcase
    @description = description&.downcase
  end

  attr_reader :path, :tags, :language, :description
end


class GistContext
  def initialize(path)
    @path = path
    @tags = [].to_set
    yield binding
  end

  def language(language)
    @language = language
  end

  def tag(tag)
    @tags.add tag
  end

  def description(description)
    @description = description
  end

  def create_gist
    Gist.new(path: @path, tags: @tags, language: @language, description: @description)
  end
end

def load_gist(path)
  contents = path.read

  GistContext.new(path) do |bindings|
    eval contents, bindings
  end.create_gist
end


def load_gists
  gists = []

  Find.find('gists').select do |entry|
    path = Pathname.new entry
    if path.basename.to_s == '.gist.rb'
      gists << load_gist(path)
    end
  end

  gists
end


class App < Thor
  desc "find", "Find gists"
  method_option :language, :aliases => "-L", :desc => 'Find by language'
  method_option :tags, :aliases => "-t", :desc => 'Find by tags', :type => :array
  method_option :description, :aliases => "-d", :desc => 'Find in description'
  def find
    gists = load_gists

    if language = options[:language]&.downcase
      gists.select! { |gist| gist.language.downcase == language }
    end

    if tags = options[:tags]&.map(&:downcase)&.to_set
      gists.select! { |gist| gist.tags.superset? tags }
    end

    if description = options[:description]&.downcase
      gists.select! { |gist| gist.description.downcase.include? description }
    end

    gists.each do |gist|
      puts gist.path.dirname.to_s
    end
  end

  desc "tags", "List all tags"
  def tags
    gists = load_gists

    tags = gists.map(&:tags)
                .map(&:tally)
                .inject({}) { |h1, h2| h1.merge(h2) { |key, x, y| x + y } }
                .to_a
                .sort_by { |tag, frequency| [frequency, tag.downcase] }
                .each { |tag, frequency| puts "#{frequency.to_s.rjust(3)} #{tag}" }
  end
end


App.start
