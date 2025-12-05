require 'rails_helper'

RSpec.describe 'Tenant Resolution', type: :request do
  describe 'subdomain-based tenant resolution' do
    let!(:test_brand) { create(:brand, name: 'Test Brand', subdomain: 'testbrand') }
    let!(:other_brand) { create(:brand, name: 'Other Brand', subdomain: 'otherbrand') }

    context 'when subdomain matches an existing brand' do
      it 'correctly detects and loads the corresponding Brand as the active tenant' do
        get '/test_tenant', headers: { 'HTTP_HOST' => 'testbrand.appdomain.io' }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)

        expect(json_response['brand_id']).to eq(test_brand.id)
        expect(json_response['brand_name']).to eq('Test Brand')
        expect(json_response['brand_subdomain']).to eq('testbrand')
      end
    end

    context 'when subdomain does not match any brand' do
      it 'does not set a tenant' do
        get '/test_tenant', headers: { 'HTTP_HOST' => 'nonexistent.appdomain.io' }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)

        expect(json_response['brand_id']).to be_nil
        expect(json_response['brand_name']).to be_nil
      end
    end

    context 'tenant isolation' do
      it 'ensures different subdomains load different brands' do
        # Request with first brand's subdomain
        get '/test_tenant', headers: { 'HTTP_HOST' => 'testbrand.appdomain.io' }
        json_response = JSON.parse(response.body)
        expect(json_response['brand_id']).to eq(test_brand.id)
        expect(json_response['brand_name']).to eq('Test Brand')

        # Request with second brand's subdomain
        get '/test_tenant', headers: { 'HTTP_HOST' => 'otherbrand.appdomain.io' }
        json_response = JSON.parse(response.body)
        expect(json_response['brand_id']).to eq(other_brand.id)
        expect(json_response['brand_name']).to eq('Other Brand')
      end
    end

    context 'with localhost subdomain format' do
      it 'correctly extracts subdomain from localhost:port format' do
        get '/test_tenant', headers: { 'HTTP_HOST' => 'testbrand.localhost:3000' }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['brand_id']).to eq(test_brand.id)
        expect(json_response['brand_subdomain']).to eq('testbrand')
      end

      it 'correctly resolves tenant from testbrand.localhost' do
        # Simulate request to http://testbrand.localhost
        get '/test_tenant', headers: { 'HTTP_HOST' => 'testbrand.localhost' }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)

        expect(json_response['brand_id']).to eq(test_brand.id)
        expect(json_response['brand_name']).to eq('Test Brand')
        expect(json_response['brand_subdomain']).to eq('testbrand')
      end
    end
  end
end
