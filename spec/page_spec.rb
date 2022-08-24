# frozen_string_literal: true

module Ferrum
  describe Page do
    let(:target_id) { rand.to_s }
    let(:instance)  { described_class.new target_id, browser }

    describe "#new" do
      before do
        # Ferrum::BrowserError: Not allowed
        allow(browser).to receive(:reset).and_return nil
      end

      subject { instance }

      after do
        browser force: true
      end

      context "#prepare_page" do
        let(:context1) { browser.contexts.default_context }

        it "initiates a session" do
          allow_any_instance_of(described_class).to receive(:context).and_return context1
          width, height = browser.window_size
          allow_any_instance_of(described_class).to receive(:resize).with(width: width, height: height).and_return nil
          expect(browser.client).to receive(:session!).and_call_original

          subject
        end
      end
    end
  end
end
