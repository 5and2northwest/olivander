module Olivander
  class ApplicationContext
    attr_accessor :name, :logo, :login_logo, :company, :menu_items,
                  :route_builder, :sign_out_path, :sidebar_background_class,
                  :nav_container, :nav_class, :layout_container, :layout_class,
                  :sidebar

    DEFAULT_APPLICATION_NAME  = 'Application Name'.freeze
    DEFAULT_SIGN_OUT_PATH     = '/users/sign_out'.freeze
    DEFAULT_HEADER_CLASSES    = ''.freeze
    DEFAULT_LOGO_URL          = '/images/olivander_logo.png'.freeze
    DEFAULT_LOGO_ALT          = 'Logo Image'.freeze
    DEFAULT_LOGIN_LOGO_URL    = '/images/olivander_login_logo.png'.freeze
    DEFAULT_LOGIN_LOGO_ALT    = 'Login Logo Image'.freeze
    DEFAULT_COMPANY_URL       = '/'.freeze
    DEFAULT_COMPANY_ALT       = 'Company Name'.freeze
    DEFAULT_LAYOUT_CLASS      = 'hold-transition sidebar-mini layout-fixed'.freeze
    DEFAULT_NAV_CLASS         = 'navbar-expand navbar-white navbar-light'.freeze

    def initialize(**kwargs)
      self.name = kwargs[:name] || ENV['OLIVANDER_APP_NAME'] || DEFAULT_APPLICATION_NAME
      self.logo = kwargs[:logo] || Logo.new(url: kwargs[:logo_url], alt: kwargs[:logo_alt])
      self.login_logo = kwargs[:login_logo] || LoginLogo.new(url: kwargs[:login_logo_url], alt: kwargs[:login_logo_alt])
      self.company = kwargs[:company] || Company.new(name: kwargs[:company_name], url: kwargs[:company_url])
      self.sign_out_path = kwargs[:sign_out_path] || DEFAULT_SIGN_OUT_PATH
      self.menu_items = kwargs[:menu_items] || []
      self.nav_container = kwargs[:nav_container] || 'false'.freeze == 'true'.freeze
      self.nav_class = kwargs[:nav_class] || DEFAULT_NAV_CLASS
      self.layout_container = kwargs[:layout_container] || 'false'.freeze == 'true'.freeze
      self.layout_class = kwargs[:layout_class] || DEFAULT_LAYOUT_CLASS
      self.sidebar = kwargs[:sidebar] || 'true' == 'true'.freeze
      begin
        self.route_builder = RouteBuilder.new
      rescue NameError
        self.route_builder = OpenStruct.new(resources: {})
      end
    end

    def nav_container?
      nav_container == true
    end

    def layout_container?
      layout_container == true
    end

    def sidebar?
      sidebar == true
    end

    def visible_modules
      [].tap do |arr|
        menu_items.each do |menu_item|
          arr << visible_modules_for(menu_item)
        end
      end.flatten
    end

    def visible_modules_for(menu_item)
      [].tap do |arr|
        arr << menu_item if menu_item.module? && menu_item.visible
        menu_item.submenu_items.each do |sub|
          arr << visible_modules_for(sub)
        end
      end
    end

    class Logo
      attr_accessor :url, :alt

      def initialize(**kwargs)
        self.url = kwargs[:url] || ENV['OLIVANDER_LOGO_URL'] || DEFAULT_LOGO_URL
        self.alt = kwargs[:alt] || ENV['OLIVANDER_LOGO_ALT'] || DEFAULT_LOGO_ALT
      end
    end

    class LoginLogo
      attr_accessor :url, :alt

      def initialize(**kwargs)
        self.url = kwargs[:url] || ENV['OLIVANDER_LOGIN_LOGO_URL'] || DEFAULT_LOGIN_LOGO_URL
        self.alt = kwargs[:alt] || ENV['OLIVANDER_LOGIN_LOGO_ALT'] || DEFAULT_LOGIN_LOGO_ALT
      end
    end

    class Company
      attr_accessor :name, :url

      def initialize(**kwargs)
        self.url = kwargs[:url] || ENV['OLIVANDER_COMPANY_URL'] || DEFAULT_COMPANY_URL
        self.name = kwargs[:name] || ENV['OLIVANDER_COMPANY_NAME'] || DEFAULT_COMPANY_ALT
      end
    end
  end

  class CurrentContext < ActiveSupport::CurrentAttributes
    attribute :application_context
    attribute :user, :ability
    DEFAULT_USER_DISPLAY      = 'No User Set'.freeze

    def build(&block)
      self.application_context ||= ::Olivander::ApplicationContext.new
      self.user ||= build_dummy_user
      self.ability ||= build_dummy_ability
      yield(self, application_context, user, ability) if block_given?
      self
    end

    private

    def build_dummy_user
      OpenStruct.new({ display_name: DEFAULT_USER_DISPLAY })
    end

    def build_dummy_ability
      Class.new do
        def can?(_action, _resource)
          true
        end

        def authorize!(_action, _resource)
          true
        end
      end.new
    end
  end
end
