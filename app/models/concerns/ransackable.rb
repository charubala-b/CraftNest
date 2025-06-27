# app/models/concerns/ransackable.rb
module Ransackable
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_attributes(_auth_object = nil)
      config = RANSACKABLE_CONFIG[self.name] || {}
      config["attributes"] || []
    end

    def ransackable_associations(_auth_object = nil)
      config = RANSACKABLE_CONFIG[self.name] || {}
      config["associations"] || []
    end
  end
end
