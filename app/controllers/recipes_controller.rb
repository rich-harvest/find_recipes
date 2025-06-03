class RecipesController < ApplicationController
  # Skip CSRF token verification for API requests
  skip_before_action :verify_authenticity_token, only: [ :search ]

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
    @sort_by = params[:sort_by] || "relevance" # Default sort by relevance

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
      end

      # Calculate matching ingredients and total time for each recipe
      @recipes = @recipes.map do |recipe|
        matching_count = @ingredients.count do |search_ingredient|
          recipe.ingredients.any? { |recipe_ingredient| recipe_ingredient.downcase.include?(search_ingredient) }
        end
        total_time = (recipe.prep_time || 0) + (recipe.cook_time || 0)
        [ recipe, matching_count, total_time ]
      end

      # Sort based on user preference
      @recipes = case @sort_by
      when "time_asc"
        @recipes.sort_by { |r, count, time| [ time, -count, -r.ratings ] }
      when "time_desc"
        @recipes.sort_by { |r, count, time| [ -time, -count, -r.ratings ] }
      else # 'relevance' - default
        @recipes.sort_by { |r, count, time| [ -count, time, -r.ratings ] }
      end

      # Extract just the recipes from the sorted data
      @recipes = @recipes.map { |r, _, _| r }
    end

    respond_to do |format|
      format.html { render :index }
      format.json {
        render json: {
          total_recipes: @recipes.size,
          ingredients_searched: @ingredients,
          sort_by: @sort_by,
          recipes: @recipes.map { |r|
            total_time = (r.prep_time || 0) + (r.cook_time || 0)
            r.as_json.merge(
              matching_ingredients_count: @ingredients.count { |i|
                r.ingredients.any? { |ri| ri.downcase.include?(i) }
              },
              total_time: total_time
            )
          }
        }
      }
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :cook_time, :prep_time, :ratings, :cuisine, :category, :author, :image, ingredients: [])
  end
end
