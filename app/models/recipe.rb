class Recipe < ApplicationRecord
  serialize :ingredients, coder: JSON
end
