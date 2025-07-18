module EmailDowncaseable
  extend ActiveSupport::Concern

  included do
    before_save :downcase_email
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
