require_relative "../spec_helper"
require_relative "../../lib/streamy/helpers/rspec_helper"

RSpec.describe Streamy::Helpers::RspecHelper do
  describe "#expect_no_event" do
    it "fails if the key for type is not where expected" do
      allow(Streamy::TestDispatcher).to receive(:events).and_return(
        [payload: {}]
      )

      expect {
        expect_no_event(type: "type")
      }.to fail_including("to have type in payloads")
    end

    it "passes when type key is present and type value is not found" do
      allow(Streamy::TestDispatcher).to receive(:events).and_return(
        [payload: {type: ""}]
      )

      expect {
        expect_no_event(type: "type")
      }.not_to raise_error
    end

    it "fails if the expected value for type is present in any event" do
      allow(Streamy::TestDispatcher).to receive(:events).and_return(
        [payload: {type: "type"}]
      )

      expect {
        expect_no_event(type: "type")
      }.to fail_including("not to have hash {:payload=>a hash including {:type => \"type\"}}")
    end
  end
end
