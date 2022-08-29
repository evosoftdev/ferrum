# frozen_string_literal: true

module Ferrum
  describe Target do
    let(:params)    { nil }
    let(:instance)  { described_class.new browser, params }

    describe "#session_id" do
      let(:session_id) { rand.to_s }

      subject { instance.session_id }

      it "calls add_session" do
        expect(instance).to receive(:add_session).and_return session_id

        is_expected.to eql session_id
      end

      context "when @sessions_ids is not empty" do
        before do
          instance.instance_variable_set :@sessions_ids, Concurrent::Array[session_id]
        end

        it "returns a session_id" do
          expect(instance).not_to receive :add_session

          is_expected.to eql session_id
        end
      end
    end

    describe "#add_session" do
      let(:instance_id) { rand.to_s }
      let(:session_id)  { rand.to_s }

      subject { instance.add_session }

      it "calls add_session" do
        expect(instance).to receive(:id).and_return instance_id
        expect(browser).to receive(:command).with(
          "Target.attachToTarget",
          targetId: instance_id,
          flatten: true
        ).and_return("sessionId" => session_id)

        is_expected.to eql session_id
        expect(instance.instance_variable_get(:@sessions_ids)).to eql [session_id]
      end
    end
  end
end
