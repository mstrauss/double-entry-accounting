require 'spec_helper'

describe "accounts/edit.html.haml" do
  before(:each) do
    @account = assign(:account, stub_model(Account))
  end

  it "renders the edit account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => accounts_path(@account), :method => "post" do
    end
  end
end
