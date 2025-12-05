# Middleware to resolve tenant from subdomain
# Extracts subdomain from request host and sets the current tenant
class TenantResolver
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    subdomain = extract_subdomain(request.host)
    
    # Fallback to X-Subdomain header if no subdomain in host (useful for frontend)
    subdomain ||= request.headers["X-Subdomain"].presence

    if subdomain.present?
      brand = Brand.find_by(subdomain: subdomain)
      ActsAsTenant.current_tenant = brand if brand
    end

    @app.call(env)
  ensure
    # Clear tenant context after request
    ActsAsTenant.current_tenant = nil
  end

  private

  def extract_subdomain(host)
    # Handle formats like:
    # - mechanic123.appdomain.io -> mechanic123
    # - mechanic123.localhost:3000 -> mechanic123
    # - localhost:3000 -> nil
    # Remove port if present
    host_without_port = host.split(":").first

    # If it's localhost, extract subdomain from the part before .localhost
    if host_without_port.include?("localhost")
      return nil if host_without_port == "localhost"
      # Extract subdomain from "subdomain.localhost"
      parts = host_without_port.split(".")
      return nil if parts.length < 2 || parts.last != "localhost"
      return parts.first.presence
    end

    # For standard domains, subdomain is the first part
    parts = host_without_port.split(".")
    return nil if parts.length < 2
    subdomain = parts.first
    subdomain.presence
  end
end
