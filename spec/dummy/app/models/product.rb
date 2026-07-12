class Product < ApplicationRecord
  validates :name, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name price active created_at updated_at]
  end
end
