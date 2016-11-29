require "bundler/setup"
Bundler.require(:default)
Dotenv.load

if ARGV.length != 2
  puts "Cleans outdated comments from a pull request"
  puts "Usage: clean_pull organization/project 1234"
  exit
end

repository = ARGV[0]
pull_request = ARGV[1]

def outdated_cop_comment?(comment)
  comment.user.login =~ /codepolice/i &&
    comment.position.nil? &&
    comment.original_position
end

client = Octokit::Client.new :access_token => ENV['GITHUB_PERSONAL_TOKEN']
comments = client.pull_request_comments repository, pull_request

comments.each do |comment|
  next unless outdated_cop_comment?(comment)
  puts "Removing comment #{comment.id}: #{comment.body}"
  client.delete_pull_request_comment(repository, comment.id)
end
