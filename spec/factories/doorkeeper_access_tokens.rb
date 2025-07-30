FactoryBot.define do
  factory :doorkeeper_access_token, class: 'Doorkeeper::AccessToken' do
    application { create(:oauth_application) }
    resource_owner_id { create(:user).id }
    scopes { 'read write' }    
    expires_in { 2.hours.to_i }
    revoked_at { nil }           
  end
end
