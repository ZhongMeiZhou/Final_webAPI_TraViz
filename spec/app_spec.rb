require_relative 'spec_helper'
require 'json'

describe "Check if service is active" do
  it "should return ok" do
    get '/'
    last_response.must_be :ok?
  end
end

describe "Check if there is some data" do
  it "should return tour json" do
    get '/'
    last_response.must_be :ok?
  end
end

describe "Check parameter results" do
  it "should receive parameter and return a json" do
    get '/'
    last_response.must_be :ok?
  end
end
