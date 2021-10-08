class CategoriesController < ApiController
  def index
    categories = Category.all
    render json: each_serialize(categories, serializer_name: :CategorySerializer)
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
