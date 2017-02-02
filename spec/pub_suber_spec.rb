# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubSuber do
  it "has a version number" do
    expect(PubSuber::VERSION).not_to be nil
  end
end
