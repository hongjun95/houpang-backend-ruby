class ItemsController < ApiController
  def index
    current_user = current_api_user
    page = params[:page].to_i || 1
    sort = params[:sort]
    query = params[:query]
    takePages = 10;
    currentCounts = takePages * page.to_i;

    begin
      items = Item.ransack(name_cont:query, s: sort).result.page(page)
      totalData = items.count

      render json: { 
        ok: true,
        items: each_serialize(items),
        total_results: totalData,
        next_page: items.next_page,
        has_next_page: currentCounts < totalData ? true : false,
        prev_page: page <= 1 ? nil : page - 1,
        has_prev_page: page <= 1 ? false : true,
      }
    rescue => exception
      puts "Error #{exception.class}!"
      puts "Error : #{exception.message}"
      
      render json: {
          ok: false,
          error: "Can't find the items" 
      } and return
    end
  end

  def show
    begin
      item = Item.find(params[:id])
      return_obj = item.attributes
      begin
        provider = User.find_by_id(item.user_id)
        return_obj['provider'] = provider.attributes
        
        render json: {
          ok: true,
          item: serialize(item, serializer_name: :ItemSerializer)
        }
      rescue => exception
        puts "Error #{exception.class}!"
        puts "Error : #{exception.message}"
        
        render json: {
            ok: false,
            error: "Can't find the user by item.user_id" 
        } and return
      end
    rescue => exception
      puts "Error #{exception.class}!"
      puts "Error : #{exception.message}"
      
      render json: {
          ok: false,
          error: "Can't find the item by item id" 
      } and return
    end
  end

  def get_items_by_category_id
    page = params[:page].to_i || 1
    sort = params[:sort]
    category_id = params[:id]
    takePages = 10;
    current_counts = takePages * page
    begin
      category = Category.find(category_id)

      items = Item.ransack(category_id_eq: category.id, s: sort).result.page(page)
      totalData = items.count

      render json: { 
        ok: true,
        items: each_serialize(items, serializer_name: :ItemEachSerializer),
        category_name: category.title,
        total_results: totalData,
        next_page: items.next_page,
        has_next_page: current_counts < totalData ? true : false,
        prev_page: page <= 1 ? nil : page - 1,
        has_prev_page: page <= 1 ? false : true,
      }
    rescue => exception
      puts "Error #{exception.class}!"
      puts "Error : #{exception.message}"
      
      render json: {
          ok: false,
          error: "Can't find the category" 
      } and return
    end
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
      total_results: totalData,
      next_page: items.next_page,
      has_next_page: currentCounts < totalData ? true : false,
      prev_page: page <= 1 ? nil : page - 1,
      has_prev_page: page <= 1 ? false : true,
    }
  end

  def create
    current_user = current_api_user
    begin
      existed_item = Item.exists?(name: params['item']['name'], user_id: current_user.id)
      if existed_item
        render json: {
            ok: false,
            error: "Item already exists" 
        } and return
      end
      begin
        category = Category.find_by(title: params['category_name'])
      rescue => exception
        puts "Error #{exception.class}!"
        puts "Error : #{exception.message}"
        
        render json: {
            ok: false,
            error: "Can't find the category" 
        } and return
      end

      create_obj = create_params
      puts category
      create_obj['user_id'] = current_user.id
      create_obj['category_id'] = category.id
          
      item = Item.create!(create_obj)
      render json: {
        ok:true,
        item: serialize(item)
      }
    rescue => exception
      puts "Error #{exception.class}!"
      puts "Error : #{exception.message}"
      
      render json: {
          ok: false,
          error: "Can't create the item" 
      } and return
    end
  end

  def update
    provider = current_api_user
    itemId = params[:id]
    category_name = params[:category_name];

    item = Item.find_by(id: itemId, user_id: provider.id)
    existed_item = Item.exists?(id: itemId, user_id: provider.id)

    if !existed_item
      render json: { ok: false, error: "Item doesn't exist" } and return
    end

    category = Category.find(item.category_id)

    if category_name
      category = Category.find_by(title: category_name)
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
    params.require(:item).permit(:name, :sale_price, :stock, :product_images => [], :infos => [:id, :key, :value])
  end

  def permitted_query
    params[:q].permit(:s)
  end
end
