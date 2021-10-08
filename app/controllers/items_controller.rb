class ItemsController < ApiController
  def index
    items = Item.ransack(index_params).result
    render json: {
      items: each_serialize(items),
      total_count: items.count
    }
  end

  def show
    item = Item.find(params[:id])
    render json: serialize(item)
  end

  def create
    current_user = current_api_user
    existed_item = Item.exists?(name: params['item']['name'], user_id: current_user.id)
    if existed_item
      render json: { ok: false, error: "Item already exists" } and return
    end
    category = Category.find_by(title: params['categoryName'])

    create_obj = create_params
    create_obj['user_id'] = current_user.id
    create_obj['category_id'] = category.id
        
    item = Item.create!(create_obj)
    render json: serialize(item)
  end

  private

  def index_params
    params.fetch(:q, {}).permit(:s, :category_id_eq)
  end

  def create_params
    params.require(:item).permit(:name, :sale_price, :stock, :productImages => [], :infos => [:id, :key, :value])
  end
end
