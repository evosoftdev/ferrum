# frozen_string_literal: true

module Sequences
  def ws_url
    "ws://127.0.0.1"
  end

  # @return [Ferrum::Browser]
  def browser(force: false)
    @browser = nil if force
    @browser ||= new_browser
  end

  def new_browser
    options = { base_url: Ferrum::Server.server.base_url }
    options.merge!(headless: false) if ENV["HEADLESS"] == "false"
    options.merge!(slowmo: ENV["SLOWMO"].to_f) if ENV["SLOWMO"].to_f > 0

    if ENV["CI"]
      ferrum_logger = StringIO.new
      options.merge!(logger: ferrum_logger)
    end

    Ferrum::Browser.new(**options)
  end
end
