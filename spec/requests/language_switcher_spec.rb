require "rails_helper"

RSpec.describe "Sidebar language switcher", type: :request do
  let!(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }

  before { sign_in admin_user }

  it "renders the 3 default language options by default" do
    get "/admin"

    expect(response.body).to include('class="prism-sidebar-lang"')
    expect(response.body).to include('class="prism-lang-current">English<')
    expect(response.body).to include(">English</a>")
    expect(response.body).to include(">Español</a>")
    expect(response.body).to include(">Français</a>")
    expect(response.body.scan('class="prism-lang-option').size).to eq(3)
  end

  it "links each option to the current page with a locale query param" do
    get "/admin"

    expect(response.body).to include('href="/admin?locale=en"')
    expect(response.body).to include('href="/admin?locale=es"')
    expect(response.body).to include('href="/admin?locale=fr"')
  end

  it "marks the option matching I18n.locale as active" do
    I18n.with_locale(:es) do
      get "/admin"
    end

    expect(response.body).to include('class="prism-lang-current">Español<')
    expect(response.body).to match(/class="prism-lang-option active" href="\/admin\?locale=es">Español</)
  end

  it "does not render the dropdown when language_switcher is false" do
    ActiveAdminPrism.configure { |c| c.language_switcher = false }

    get "/admin"

    expect(response.body).not_to include("prism-sidebar-lang")
  end

  it "does not render the dropdown when languages is empty" do
    ActiveAdminPrism.configure { |c| c.languages = [] }

    get "/admin"

    expect(response.body).not_to include("prism-sidebar-lang")
  end

  it "renders a custom languages list instead of the default" do
    ActiveAdminPrism.configure do |c|
      c.languages = [
        { label: "Deutsch", locale: :de },
        { label: "日本語", locale: :ja }
      ]
    end

    get "/admin"

    expect(response.body).to include(">Deutsch</a>")
    expect(response.body).to include(">日本語</a>")
    expect(response.body).not_to include(">English</a>")
  end

  describe "a per-language :url override" do
    it "uses a Proc's return value instead of url_for(locale: ...)" do
      ActiveAdminPrism.configure do |c|
        c.languages = [
          { label: "English", locale: :en },
          { label: "日本語", locale: :ja, url: -> { "https://example.com/set_locale?locale=ja" } }
        ]
      end

      get "/admin"

      expect(response.body).to include('href="https://example.com/set_locale?locale=ja"')
      expect(response.body).not_to include('href="/admin?locale=ja"')
    end

    it "instance_execs the Proc with normal Arbre/view helpers available (request, url_for, ...)" do
      ActiveAdminPrism.configure do |c|
        c.languages = [
          { label: "English", locale: :en, url: -> { url_for(locale: :en, foo: "bar") } }
        ]
      end

      get "/admin"

      expect(response.body).to include('href="/admin?foo=bar&amp;locale=en"')
    end

    it "accepts a plain String too" do
      ActiveAdminPrism.configure do |c|
        c.languages = [
          { label: "English", locale: :en, url: "/switch-language/en" }
        ]
      end

      get "/admin"

      expect(response.body).to include('href="/switch-language/en"')
    end
  end
end
