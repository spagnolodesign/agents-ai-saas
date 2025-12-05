class ApplicationController < ActionController::API
  # Returns the current brand (tenant) from the global tenant context
  def current_brand
    ActsAsTenant.current_tenant
  end
end
