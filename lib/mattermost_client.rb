# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'net/http'

class MattermostClient

  def self.notify(text)
    url = Rails.application.config.faucet.mattermost_hook
    username = Rails.application.config.faucet.mattermost_username
    channel  = Rails.application.config.faucet.mattermost_channel
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)

    req.body = 'payload=' + { text: text, username: username, channel: channel }.to_json
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    res.body
  end
end
