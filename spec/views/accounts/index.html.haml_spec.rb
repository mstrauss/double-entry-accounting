require 'spec_helper'

describe "accounts/index.html.haml" do
  before(:each) do
    assign(:accounts, [
      stub_model(Account),
      stub_model(Account)
    ])
  end

  it "renders a list of accounts" do
    render
  end
end
