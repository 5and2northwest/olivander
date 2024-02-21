module Olivander
  class ApplicationContext
    attr_accessor :name, :logo, :login_logo, :company, :menu_items, :route_builder, :sign_out_path, :sidebar_background_class

    def initialize(**kwargs)
      self.name = kwargs[:name] || ENV['OLIVANDER_APP_NAME'] || 'Application Name'
      self.logo = kwargs[:logo] || Logo.new(url: kwargs[:logo_url], alt: kwargs[:logo_alt])
      self.login_logo = kwargs[:login_logo] || LoginLogo.new(url: kwargs[:login_logo_url], alt: kwargs[:login_logo_alt])
      self.company = kwargs[:company] || Company.new(name: kwargs[:company_name], url: kwargs[:company_url])
      self.sign_out_path = kwargs[:sign_out_path] || '/sign_out'
      self.menu_items = kwargs[:menu_items] || []
      begin
        self.route_builder = RouteBuilder.new
      rescue NameError
        self.route_builder = OpenStruct.new(resources: {})
      end
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
        self.url = kwargs[:url] || ENV['OLIVANDER_LOGO_URL'] || '/images/olivander_logo.png'
        self.alt = kwargs[:alt] || ENV['OLIVANDER_LOGO_ALT'] || 'Logo Image'
      end
    end

    class LoginLogo
      attr_accessor :url, :alt

      def initialize(**kwargs)
        self.url = kwargs[:url] || ENV['OLIVANDER_LOGIN_LOGO_URL'] || '/images/olivander_login_logo.png'
        self.alt = kwargs[:alt] || ENV['OLIVANDER_LOGIN_LOGO_ALT'] || 'Login Logo Image'
      end
    end

    class Company
      attr_accessor :name, :url

      def initialize(**kwargs)
        self.url = kwargs[:url] || ENV['OLIVANDER_COMPANY_URL'] || '/'
        self.name = kwargs[:name] || ENV['OLIVANDER_COMPANY_NAME'] || 'Company Name'
      end
    end
  end

  class CurrentContext < ActiveSupport::CurrentAttributes
    attribute :application_context
    attribute :user, :ability

    def build(&block)
      self.application_context ||= ::Olivander::ApplicationContext.new
      self.user ||= build_dummy_user
      self.ability ||= build_dummy_ability
      yield(self, application_context, user, ability) if block_given?
      self
    end

    private

    def build_dummy_user
      OpenStruct.new({ display_name: 'No User Set' })
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
