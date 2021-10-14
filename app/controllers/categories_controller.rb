class CategoriesController < ApiController
  def index
    begin
      categories = Category.all
      render json: {
        ok: true,
        categories: each_serialize(categories, serializer_name: :CategorySerializer)
      }
    rescue => exception
      puts "Error #{exception.class}!"
      puts "Error : #{exception.message}"
      
      render json: {
          ok: false,
          error: "Can't get categories" 
      } and return
    end
  end

  def show
    category = Category.find(params[:id])
    render json: serialize(category)
  end

  def create
    category = Category.create(create_params)
    render json: serialize(category)
  end

  private
  
  def create_params
    params.require(:category).permit(:title, :coverImg)
  end
end
