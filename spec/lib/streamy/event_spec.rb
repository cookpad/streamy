require "spec_helper"

describe Streamy::Event do
  describe "#publish" do

    it "returns a helpful error message when subclass does not define body" do
      allow_any_instance_of(Streamy::Event).to receive(:topic).and_return(nil)
      allow_any_instance_of(Streamy::Event).to receive(:event_time).and_return(nil)

      expect{ Streamy::Event.publish }.to raise_error "body must be implemented on Streamy::Event"
    end

    it "returns a helpful error message when subclass does not define topic" do
      allow_any_instance_of(Streamy::Event).to receive(:body).and_return(nil)
      allow_any_instance_of(Streamy::Event).to receive(:event_time).and_return(nil)

      expect{ Streamy::Event.publish }.to raise_error "topic must be implemented on Streamy::Event"
    end

    it "returns a helpful error message when subclass does not define body" do
      allow_any_instance_of(Streamy::Event).to receive(:topic).and_return(nil)
      allow_any_instance_of(Streamy::Event).to receive(:body).and_return(nil)

      expect{ Streamy::Event.publish }.to raise_error "event_time must be implemented on Streamy::Event"
    end
  end
end
