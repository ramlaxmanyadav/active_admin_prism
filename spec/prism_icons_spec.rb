require "rails_helper"

RSpec.describe ActiveAdminPrism::Icons do
  describe ".svg" do
    it "returns an inline svg for a known icon" do
      svg = described_class.svg(:cart)

      expect(svg).to start_with("<svg")
      expect(svg).to include('class="prism-icon"')
      expect(svg).to include('width="18"')
      expect(svg).to include('height="18"')
    end

    it "returns nil for an unknown icon name" do
      expect(described_class.svg(:not_a_real_icon)).to be_nil
    end

    it "respects a custom css_class and size" do
      svg = described_class.svg(:eye, css_class: "custom-class", size: 30)

      expect(svg).to include('class="custom-class"')
      expect(svg).to include('width="30"')
      expect(svg).to include('height="30"')
    end

    it "accepts a string name as well as a symbol" do
      expect(described_class.svg("trash")).to eq(described_class.svg(:trash))
    end
  end

  describe ".login_mark" do
    it "returns a distinct, animatable mark svg" do
      svg = described_class.login_mark

      expect(svg).to include("prism-login-mark")
      expect(svg).to include("prism-login-tri")
      expect(svg).to include("prism-login-beam")
    end

    it "respects a custom size" do
      expect(described_class.login_mark(size: 80)).to include('width="80"')
    end
  end
end

RSpec.describe ActiveAdminPrism::IconHelper do
  let(:helper_object) { Class.new { include ActiveAdminPrism::IconHelper }.new }

  it "returns an html_safe inline svg for a known icon" do
    result = helper_object.prism_icon(:box)

    expect(result).to be_html_safe
    expect(result).to include("<svg")
  end

  it "returns nil for an unknown icon" do
    expect(helper_object.prism_icon(:not_a_real_icon)).to be_nil
  end
end
