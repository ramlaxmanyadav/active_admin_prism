require "rails_helper"
require "rails/generators"
require "generators/active_admin_prism/error_pages/error_pages_generator"
require "tmpdir"

RSpec.describe ActiveAdminPrism::Generators::ErrorPagesGenerator do
  around do |example|
    Dir.mktmpdir do |dir|
      @destination_root = dir
      example.run
    end
  end

  def run_generator
    original_stdout = $stdout
    $stdout = StringIO.new
    described_class.new([], {}, destination_root: @destination_root).invoke_all
  ensure
    $stdout = original_stdout
  end

  it "copies 404.html and 500.html into public/" do
    run_generator

    expect(File.exist?(File.join(@destination_root, "public/404.html"))).to be true
    expect(File.exist?(File.join(@destination_root, "public/500.html"))).to be true
  end

  it "copies the gem's actual template content byte-for-byte" do
    run_generator

    template_dir = File.expand_path(
      "../../lib/generators/active_admin_prism/error_pages/templates", __dir__
    )
    expect(File.read(File.join(@destination_root, "public/404.html")))
      .to eq(File.read(File.join(template_dir, "404.html")))
    expect(File.read(File.join(@destination_root, "public/500.html")))
      .to eq(File.read(File.join(template_dir, "500.html")))
  end

  it "carries the Prism brand mark and title in both pages" do
    run_generator

    expect(File.read(File.join(@destination_root, "public/404.html"))).to include("prism-mark")
    expect(File.read(File.join(@destination_root, "public/500.html"))).to include("prism-mark")
  end
end
