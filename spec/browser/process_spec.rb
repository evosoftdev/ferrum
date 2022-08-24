# frozen_string_literal: true

module Ferrum
  class Browser
    describe Process do
      let(:options)   { {} }
      let(:instance)  { described_class.new options }

      describe "#new" do
        before do
          allow_any_instance_of(described_class).to receive(:request_json_version).and_return nil
        end

        subject { instance }

        context "when ws_url" do
          let(:options) { { ws_url: ws_url } }

          it "creates an instance" do
            is_expected.to be_a described_class
            expect(subject.ws_url).to be_a Addressable::URI
          end
        end
      end

      describe "#parse_browser_versions" do
        subject { instance.send :parse_browser_versions }

        it "returns from a method" do
          allow_any_instance_of(described_class).to receive(:request_json_version).and_return({})

          is_expected.to be_nil
        end

        context "when with ws_url" do
          let(:options)           { { ws_url: ws_url } }
          let(:protocol_version)  { rand.to_s }

          it "creates an instance" do
            allow_any_instance_of(described_class).to receive(:request_json_version).and_return(
              "Protocol-Version" => protocol_version
            )

            is_expected.to eql protocol_version
          end
        end
      end

      describe "#request_json_version" do
        let(:response_headers)  { nil }
        let(:response_body)     { nil }
        let(:logger)            { double :logger, puts: nil }
        let(:options) do
          {
            logger: logger,
            ws_url: ws_url
          }
        end

        before do
          WebMock.disable_net_connect!
          stub_request(:get, /__identify__/).to_return(status: 200, body: response_body, headers: response_headers)
          stub_request(:get, %r{json/version}).to_return(status: 200, body: response_body, headers: response_headers)
        end

        subject { instance.send :request_json_version }

        after do
          WebMock.allow_net_connect!
        end

        it "returns nil" do
          expect(logger).to receive(:puts).and_return nil

          is_expected.to be_nil
        end

        context "when response is a json" do
          let(:response_headers)  { { "Content-Type" => "application/json" } }
          let(:response_content)  { { rand.to_s => rand.to_s } }
          let(:response_body)     { response_content.to_json }

          it "makes a http request" do
            is_expected.to eql response_content
          end
        end
      end
    end
  end
end
