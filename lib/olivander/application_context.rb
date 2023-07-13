module Olivander
  class ApplicationContext
    attr_accessor :name, :logo, :company, :menu_items, :route_builder, :sign_out_path

    def self.default
      ctx = ApplicationContext.new
      ctx.company.name = 'Company Name'
      ctx
    end

    def initialize(name: 'Application Name', logo: Logo.new, company: Company.new, sign_out_path: '/sign_out', menu_items: [])
      self.name = name
      self.logo = logo
      self.company = company
      self.sign_out_path = sign_out_path
      self.menu_items = menu_items
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

      def initialize(url: nil, alt: 'Logo')
        self.url = url
        self.alt = alt
      end
    end

    class Company
      attr_accessor :name, :url

      def initialize(name: nil, url: nil)
        self.url = url
        self.name = name
      end
    end
  end
end
