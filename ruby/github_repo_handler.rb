require 'net/https'
require 'json'
require 'git'
require 'net/ping'
require_relative 'error'
require_relative 'github_api.rb'
  # github_calulate_number_of_requests_to_send, github_user_info_request, github_repo_request, github_url
  # connection?, user_exists?, repositories_exist?
require_relative 'local_system.rb'
  # clone_repository

class GithubRepoHandler
  attr_reader :account_name
  include Github
  include LocalSystem

  # **********         Object creation logic.             **********
  def initialize
    @account_name = get_account_name
  end

  def get_account_name
    puts 'Please enter your Github account name'
    STDOUT.flush
    STDIN.gets.chomp
  end

  # **********         Main clone repository logic.       **********
  def clone_repositories
    return unless connection? && user_exists?

    github_calulate_number_of_requests_to_send().times do |index|
      response_page_logic(index+1)  # starting at one because page=0 and page=1 are identical.
    end
  end

  def response_page_logic(page_number)
    return unless repositories_exist?(page_number)

    puts "api request ##{page_number}" # leave this in here for visibility. If user exceeds api limit. need to know where they left off.
    github_repo_request(page_number).each { |repo| clone_repository(repo) }
  end

end
