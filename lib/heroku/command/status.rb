require "heroku/command/base"

# check status of Heroku platform
#
class Heroku::Command::Status < Heroku::Command::Base

  # status
  #
  # display current status of Heroku platform
  #
  #Example:
  #
  # $ heroku status
  # === Heroku Status
  # Development: green
  # Production:  green
  #
  def index
    validate_arguments!

    heroku_status_host = ENV['HEROKU_STATUS_HOST'] || "status-beta.heroku.com"
    status = json_decode(Excon.get("https://#{heroku_status_host}/api/v3/current-status.json").body)

    styled_header("Heroku Status")

    status['status'].each do |key, value|
      if value == 'green'
        status['status'][key] = 'No known issues at this time.'
      end
    end
    styled_hash(status['status'])

    unless status['issues'].empty?
      display
      status['issues'].each do |issue|
        duration = time_ago(Time.now - Time.parse(issue['updated_at'])).gsub(" ago", "")
        styled_header("#{issue['title']} (#{duration})")
        changes = issue['updates'].map do |change|
          change['contents']
        end
        styled_array(changes)
      end
    end
  end

end
