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

  def getItemsByCategoryId
    page = params[:page].to_i || 1
    sort = params[:sort]
    categoryId = params[:id]

    takePages = 10;
    currentCounts = takePages * page.to_i;
    category = Category.find(categoryId)
    existed_category = Category.exists?(id: category.id)

    if !existed_category
      render json: { ok: false, error: "Category doesn't exist" } and return
    end

    items = Item.ransack(category_id_eq: category.id, s: sort).result.page(page)
    totalData = items.count

    render json: { 
      ok: true,
      items: each_serialize(items, serializer_name: :ItemSerializer),
      categoryName: category.title,
      totalResults: totalData,
      nextPage: items.next_page,
      hasNextPage: currentCounts < totalData ? true : false,
      prevPage: page <= 1 ? nil : page - 1,
      hasPrevPage: page <= 1 ? false : true,
    }
  end
  
  def getItemsFromProvider
    current_user = current_api_user
    page = params[:page].to_i || 1
    sort = params[:sort]
    takePages = 10;
    currentCounts = takePages * page.to_i;

    items = Item.ransack(user_id_eq:current_user.id, s: sort).result.page(page)
    totalData = items.count

    render json: { 
      ok: true,
      items: each_serialize(items, serializer_name: :ItemSerializer),
      totalResults: totalData,
      nextPage: items.next_page,
      hasNextPage: currentCounts < totalData ? true : false,
      prevPage: page <= 1 ? nil : page - 1,
      hasPrevPage: page <= 1 ? false : true,
    }
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

  def permitted_query
    params[:q].permit(:s)
  end
end
