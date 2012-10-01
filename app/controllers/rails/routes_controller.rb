class Rails::RoutesController < ActionController::Base
  layout 'rails/routes'

  before_filter :require_local!

  def index
    if params.include? :q
      @routes = Sextant.filter(params[:q])
      @filter = params[:q]
    else
      @routes = Sextant.parsed_routes
    end
  end

  private
  def require_local!
    unless local_request?
      render :text => '<p>For security purposes, this information is only available to local requests.</p>', :status => :forbidden
    end
  end

  def local_request?
    Rails.application.config.consider_all_requests_local || request.local?
  end

end