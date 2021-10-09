class ItemsController < ApiController
  def index
    current_user = current_api_user
    page = params[:page].to_i || 1
    sort = params[:sort]
    query = params[:query]
    takePages = 10;
    currentCounts = takePages * page.to_i;

    items = Item.ransack(name_cont:query, s: sort).result.page(page)
    totalData = items.count

    render json: { 
      ok: true,
      items: each_serialize(items),
      totalResults: totalData,
      nextPage: items.next_page,
      hasNextPage: currentCounts < totalData ? true : false,
      prevPage: page <= 1 ? nil : page - 1,
      hasPrevPage: page <= 1 ? false : true,
    }
  end

  def show
    item = Item.find(params[:id])
    render json: {
      ok: true,
      item: serialize(item)
    }
  end

  def get_items_by_category_id
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
  
  def get_items_from_provider
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
    render json: {
      ok:true,
      item: serialize(item)
    }
  end

  def update
    provider = current_api_user
    itemId = params[:id]
    categoryName = params[:categoryName];

    item = Item.find_by(id: itemId, user_id: provider.id)
    existed_item = Item.exists?(id: itemId, user_id: provider.id)

    if !existed_item
      render json: { ok: false, error: "Item doesn't exist" } and return
    end

    category = Category.find(item.category_id)

    if categoryName
      category = Category.find_by(title: categoryName)
    end

    item.update(create_params)
    item.category_id = category.id
    item.save

    render json: {
      ok: true,
      item: serialize(item)
    }
  end

  def destroy
    provider = current_api_user
    itemId = params[:id]
    item = Item.find_by(id: itemId, user_id: provider.id)
    existed_item = Item.exists?(id: itemId, user_id: provider.id)

    if !existed_item
      render json: { ok: false, error: "Item doesn't exist" } and return
    end

    Item.delete(itemId)

    render json: {
      ok: true,
    }
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
