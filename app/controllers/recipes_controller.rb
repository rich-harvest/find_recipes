class RecipesController < ApplicationController
  def index
    @recipes = Recipe.all.order(ratings: :desc)
  end

  def show
    @recipe = Recipe.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to recipes_path, alert: "Recipe not found"
  end

  def search
    @ingredients = params[:ingredients].to_s.downcase.split(",").map(&:strip).reject(&:empty?)

    if @ingredients.empty?
      @recipes = Recipe.all.order(ratings: :desc)
    else
      @recipes = Recipe.all.select do |recipe|
        # Extract basic ingredients from recipe ingredients by removing measurements
        recipe_ingredients = recipe.ingredients.map do |ingredient|
          # Remove measurements and common words
          ingredient.downcase
                   .gsub(/^\d+\/?\d*\s*(cup|teaspoon|tablespoon|ounce|pound|oz|lb|g|ml|tsp|tbsp|cups|teaspoons|tablespoons|ounces|pounds|package|packages|to taste|fluid|large|medium|small|fresh|dried|\(.*?\))s?/, "")
                   .gsub(/^\d+\s+/, "") # Remove leading numbers
                   .strip
        end

        # Check if any of the searched ingredients appear in the recipe ingredients
        @ingredients.any? do |search_ingredient|
          recipe_ingredients.any? do |recipe_ingredient|
            recipe_ingredient.include?(search_ingredient)
          end
        end
      end.sort_by do |recipe|
        # Sort by number of matching ingredients (descending) and then by rating (descending)
        matching_count = @ingredients.count do |search_ingredient|
          recipe.ingredients.any? do |recipe_ingredient|
            recipe_ingredient.downcase.include?(search_ingredient)
          end
        end
        [ -matching_count, -recipe.ratings ]
      end
    end

    render :index
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :cook_time, :prep_time, :ratings, :cuisine, :category, :author, :image, ingredients: [])
  end
end
