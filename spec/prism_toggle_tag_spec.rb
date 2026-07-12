require "rails_helper"

RSpec.describe ActiveAdminPrism::ToggleTagHelper do
  let(:helper_object) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include ActiveAdminPrism::ToggleTagHelper
    end.new
  end

  it "renders an 'on' state for a truthy value, with default labels" do
    html = helper_object.prism_toggle_tag(true)

    expect(html).to include('class="prism-toggle-tag on"')
    expect(html).to include('aria-label="Yes"')
    expect(html).to include('title="Yes"')
    expect(html).to include('class="prism-toggle-track"')
  end

  it "renders an 'off' state for a falsy value, with default labels" do
    html = helper_object.prism_toggle_tag(false)

    expect(html).to include('class="prism-toggle-tag off"')
    expect(html).to include('aria-label="No"')
  end

  it "renders nil as an 'off' state too" do
    expect(helper_object.prism_toggle_tag(nil)).to include('class="prism-toggle-tag off"')
  end

  it "accepts custom on_label/off_label" do
    html = helper_object.prism_toggle_tag(true, on_label: "Active", off_label: "Inactive")

    expect(html).to include('aria-label="Active"')
    expect(html).to include('title="Active"')
  end

  it "returns html_safe output" do
    expect(helper_object.prism_toggle_tag(true)).to be_html_safe
  end
end
