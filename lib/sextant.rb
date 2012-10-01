require 'rails/application/route_inspector'
require 'sextant/engine'
require 'rails/routes'

module Sextant
  def self.filter(filter, parsed_routes = parsed_routes)
    filter = Regexp.new(filter)
    parsed_routes.select do |route|
      # check name, url and controller#action
      filter.match(route[0]) || filter.match(route[2]) || filter.match(route[3])
    end
  end

  def self.parsed_routes(routes = all_routes)
    inspector = Rails::Application::RouteInspector.new
    routes = inspector.format(routes, ENV['CONTROLLER'])

    # find the first fully populated row and calculate the split ranges
    regexp = /\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/
    route = routes.first { |route| regexp.match(route) }
    match = regexp.match(route)
    ranges = [
      0..route.index(match[2]) - 2,
      route.index(match[2])..route.index(match[3]) - 2,
      route.index(match[3])..route.index(match[4]) - 2,
      route.index(match[4])..-1
    ]

    # split all routes according to the ranges
    routes.map do |route|
      ranges.map do |range|
        route.slice(range).strip
      end
    end
  end

  def self.filter_format_routes(filter, routes = all_routes)
    regexp = Regexp.new(filter)
    inspector = Rails::Application::RouteInspector.new
    routes = inspector.format(routes, ENV['CONTROLLER'])
    routes.select! { |route| regexp.match(route) }
    routes.join "\n"
  end

  def self.format_routes(routes = all_routes)
    inspector = Rails::Application::RouteInspector.new
    inspector.format(routes, ENV['CONTROLLER']).join "\n"
  end

  def self.all_routes
    Rails.application.reload_routes!
    Rails.application.routes.routes
  end
end

