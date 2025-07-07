require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  subject(:admin_user) { build(:admin_user) }

  it 'is valid with valid attributes' do
    expect(admin_user).to be_valid
  end

  it 'is invalid without an email' do
    admin_user.email = nil
    expect(admin_user).not_to be_valid
  end

  it 'is invalid without a password' do
    admin_user.password = nil
    expect(admin_user).not_to be_valid
  end

  it 'has a valid Devise setup' do
    expect(AdminUser.devise_modules).to include(:database_authenticatable, :recoverable, :rememberable, :validatable)
  end
end
