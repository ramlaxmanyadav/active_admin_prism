require "rails_helper"
require "rails/generators"
require "generators/active_admin_prism/install/install_generator"
require "tmpdir"
require "fileutils"

RSpec.describe ActiveAdminPrism::Generators::InstallGenerator do
  around do |example|
    Dir.mktmpdir do |dir|
      @destination_root = dir
      example.run
    end
  end

  # Thor's say_status writes generator progress ("append", "skip", ...) to
  # $stdout unconditionally — silenced here so a passing suite run stays
  # clean; none of the assertions below depend on that output.
  def run_generator
    original_stdout = $stdout
    $stdout = StringIO.new
    described_class.new([], {}, destination_root: @destination_root).invoke_all
  ensure
    $stdout = original_stdout
  end

  def write(relative_path, content)
    full_path = File.join(@destination_root, relative_path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.write(full_path, content)
  end

  def read(relative_path)
    File.read(File.join(@destination_root, relative_path))
  end

  context "with a stock config/initializers/active_admin.rb" do
    before { write("config/initializers/active_admin.rb", "ActiveAdmin.setup do |config|\nend\n") }

    it "appends ActiveAdminPrism.enable! to the initializer" do
      run_generator

      expect(read("config/initializers/active_admin.rb")).to include("ActiveAdminPrism.enable!")
    end

    it "is idempotent — running it again doesn't duplicate the line" do
      run_generator
      run_generator

      contents = read("config/initializers/active_admin.rb")
      expect(contents.scan("ActiveAdminPrism.enable!").size).to eq(1)
    end
  end

  context "when config/initializers/active_admin.rb is missing" do
    it "does not raise, and leaves nothing behind" do
      expect { run_generator }.not_to raise_error
      expect(File.exist?(File.join(@destination_root, "config/initializers/active_admin.rb"))).to be false
    end
  end

  context "with an active_admin.scss containing the mixins import" do
    before do
      write("config/initializers/active_admin.rb", "ActiveAdmin.setup do |config|\nend\n")
      write("app/assets/stylesheets/active_admin.scss", "@import \"active_admin/mixins\";\n@import \"active_admin/base\";\n")
    end

    it "injects the variable_overrides import immediately before the mixins import" do
      run_generator

      contents = read("app/assets/stylesheets/active_admin.scss")
      expect(contents).to match(
        /@import "active_admin_prism\/variable_overrides";\s*\n@import "active_admin\/mixins";/
      )
    end

    it "is idempotent — running it again doesn't duplicate the import" do
      run_generator
      run_generator

      contents = read("app/assets/stylesheets/active_admin.scss")
      expect(contents.scan("active_admin_prism/variable_overrides").size).to eq(1)
    end
  end

  context "when active_admin.scss has no mixins import to anchor on" do
    before do
      write("config/initializers/active_admin.rb", "ActiveAdmin.setup do |config|\nend\n")
      write("app/assets/stylesheets/active_admin.scss", "// nothing relevant here\n")
    end

    it "does not raise, and leaves the file untouched" do
      original = read("app/assets/stylesheets/active_admin.scss")

      expect { run_generator }.not_to raise_error
      expect(read("app/assets/stylesheets/active_admin.scss")).to eq(original)
    end
  end

  context "when there is no active_admin.scss at all (e.g. importmap/webpacker apps)" do
    before { write("config/initializers/active_admin.rb", "ActiveAdmin.setup do |config|\nend\n") }

    it "does not raise" do
      expect { run_generator }.not_to raise_error
    end
  end
end
