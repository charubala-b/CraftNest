FactoryBot.define do
  factory :doorkeeper_access_token, class: 'Doorkeeper::AccessToken' do
    application { create(:oauth_application) }
    resource_owner_id { create(:user).id }
    scopes { 'read write' }         # Use valid scope to pass scope validation
    expires_in { 2.hours.to_i }     # Use integer format in seconds
    revoked_at { nil }              # Ensures token is active
  end
end
