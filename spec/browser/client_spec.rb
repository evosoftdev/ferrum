# frozen_string_literal: true

module Ferrum
  class Browser
    describe Client do
      let(:result)    { rand }
      let(:browser)   { Ferrum::Browser.new base_url: Ferrum::Server.server.base_url }
      let(:ws_url)    { "ws://127.0.0.1" }
      let(:instance)  { described_class.new browser, ws_url }

      let(:ws_messages) { double("ws_messages", pop: nil, closed?: false) }
      let(:ws)          { double("ws", messages: ws_messages, send_message: nil) }

      before do
        allow_any_instance_of(Contexts).to receive(:discover).and_return nil
        allow(Thread).to receive(:new).and_return nil
        allow(Browser).to receive(:start).and_return nil
        allow(WebSocket).to receive(:new).and_return ws
      end

      describe "#session!" do
        let(:session_id) { rand.to_s }

        subject { instance.session! session_id }

        it "assigns @session_id and calls message_base!" do
          expect(instance).to receive(:message_base!).and_return result

          is_expected.to eql result
          expect(instance.instance_variable_get(:@session_id)).to eql session_id
        end
      end

      describe "#increase_command_id!" do
        let(:value) { rand 0..9_999_999 } # just an integer

        subject { instance.increase_command_id! value }

        it "increases @command_id" do
          is_expected.to eql instance
          expect(instance.instance_variable_get(:@command_id)).to eql value
        end
      end

      describe "#build_message" do
        let(:next_command_id) { rand 0..9_999_999 }
        let(:method)          { rand.to_s }
        let(:params)          { {} }

        subject { instance.send :build_message, method, params }

        it "creates a hash for a message" do
          expect(instance).to receive(:next_command_id).and_return next_command_id

          is_expected.to include method: method,
                                 params: params,
                                 id: next_command_id
        end
      end

      describe "#message_base!" do
        let(:message_base) { {} }

        subject { instance.send :message_base! }

        it "creates a hash for a message" do
          subject
          expect(instance.instance_variable_get(:@message_base)).to eql message_base
        end

        context "when @session_id exists" do
          let(:session_id) { rand.to_s }

          before { instance.session! session_id }

          it "creates a hash with session" do
            subject
            expect(instance.instance_variable_get(:@message_base)).to eql({ sessionId: session_id })
          end
        end
      end
    end
  end
end
