FactoryBot.define do
  factory :access_token, class: 'Doorkeeper::AccessToken' do
    application { create(:oauth_application) }
    resource_owner_id { create(:user).id }
    scopes { '' }
    expires_in { 2.hours }
    created_at { Time.current }
  end

  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { "Test App" }
    redirect_uri { "urn:ietf:wg:oauth:2.0:oob" }
    scopes { '' }
  end
end
