# Test controller for tenant resolution testing
# This controller is only used in test environment
class TestTenantController < ApplicationController
  def show
    brand = current_brand
    render json: {
      brand_id: brand&.id,
      brand_name: brand&.name,
      brand_subdomain: brand&.subdomain
    }
  end
end

