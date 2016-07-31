require "spec_helper"

describe Mascot::Extensions::PartialsRemover do
  context ".partial?" do
    it "is true if begins with _" do
      expect(Mascot::Extensions::PartialsRemover.partial?("/foo.bar/_buzz.haml")).to be true
    end
    it "is false if does not being with _" do
      expect(Mascot::Extensions::PartialsRemover.partial?("/foo.bar/buzz.haml")).to be false
    end
  end
end
