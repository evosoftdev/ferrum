# frozen_string_literal: true

module Ferrum
  class Target
    NEW_WINDOW_WAIT = ENV.fetch("FERRUM_NEW_WINDOW_WAIT", 0.3).to_f

    # You can create page yourself and assign it to target, used in cuprite
    # where we enhance page class and build page ourselves.
    attr_writer :page

    # TODO: test
    def initialize(browser, params = nil)
      @page = nil
      @browser = browser
      @params = params
      @sessions = Concurrent::Array.new
    end

    def update(params)
      @params = params
    end

    def attached?
      !!@page
    end

    def page
      @page ||= begin
        maybe_sleep_if_new_window
        Page.new(id, @browser)
      end
    end

    def id
      @params["targetId"]
    end

    def type
      @params["type"]
    end

    def title
      @params["title"]
    end

    def url
      @params["url"]
    end

    def opener_id
      @params["openerId"]
    end

    def context_id
      @params["browserContextId"]
    end

    def window?
      !!opener_id
    end

    def maybe_sleep_if_new_window
      # Dirty hack because new window doesn't have events at all
      sleep(NEW_WINDOW_WAIT) if window?
    end

    # TODO: test
    # @return [String]
    def session
      @sessions.first || add_session
    end

    # TODO: test
    # @return [String]
    def add_session
      session = @browser.command("Target.attachToTarget", targetId: id, flatten: true)
      session_id = session["sessionId"]
      @sessions.push session_id
      session_id
    end
  end
end
