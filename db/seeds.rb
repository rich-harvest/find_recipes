require 'json'

# Clear existing recipes
puts "Clearing existing recipes..."
Recipe.destroy_all

# Read and parse the JSON file
puts "Reading recipes from JSON file..."
recipes_json = File.read(Rails.root.join('recipes-en.json'))
recipes_data = JSON.parse(recipes_json)

# Create recipes
puts "Creating recipes..."
recipes_data.each do |recipe_data|
  Recipe.create!(
    title: recipe_data['title'],
    cook_time: recipe_data['cook_time'],
    prep_time: recipe_data['prep_time'],
    ingredients: recipe_data['ingredients'],
    ratings: recipe_data['ratings'],
    cuisine: recipe_data['cuisine'],
    category: recipe_data['category'],
    author: recipe_data['author'],
    image: recipe_data['image']
  )
end

puts "Created #{Recipe.count} recipes!"
