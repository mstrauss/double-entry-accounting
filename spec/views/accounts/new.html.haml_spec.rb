require 'spec_helper'

describe "accounts/new.html.haml" do
  before(:each) do
    assign(:account, stub_model(Account).as_new_record)
  end

  it "renders new account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => accounts_path, :method => "post" do
    end
  end
end
