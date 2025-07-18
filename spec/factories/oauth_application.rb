FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { "Test App" }
    redirect_uri { "urn:ietf:wg:oauth:2.0:oob" }
    scopes { "" }
  end
end
