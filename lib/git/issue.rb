require 'thor'
require 'faraday'
require 'json'
require 'uri'

require 'git/issue/version'

module Git
  module Issue
    class CLI < Thor
      def initialize(*args)
        regexp = %r{origina\tgit@github\.com:(.*)/(.*)\.git \(fetch\)}
        command = `git remote -v`
        matched = regexp.match(command)
        exit 0 if matched.nil?
        @owner = regexp.match(command)[1]
        @repo = regexp.match(command)[2]
        super
      end

      desc 'list', 'Show issues list. You see (https://developer.github.com/v3/issues/#parameters-1) for available parameters.'
      method_options %w[assignee -a] => :string
      method_options %w[creator -c] => :string
      method_options %w[direction -d] => :string
      method_options %w[labels -l] => :string
      method_options %w[mentioned -m] => :string
      method_options %w[state -s] => :string
      method_options ['milestone'] => :string || :integer
      method_options ['sort'] => :string
      method_options ['since'] => :string
      def list
        uri = URI("https://api.github.com/repos/#{@owner}/#{@repo}/issues")
        uri.query = URI.encode_www_form(options)

        responses = Faraday.get uri.to_s
        JSON.parse(responses.body).each do |response|
          puts "#{response['number']}\t#{response['title']}\t(#{response['html_url']})"
        end
      end
    end
  end
end
