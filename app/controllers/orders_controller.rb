class OrdersController < ApiController
    def get_orders_from_consumer
        consumer_id = params[:consumer_id]
        page = params[:page].to_i || 1
        sort = params[:sort]
        begin
            consumer = User.find(consumer_id)

            takePages = 10;
            current_counts = takePages * page

            begin
                orders = Order.ransack(user_id_eq: consumer.id, s: sort)
                        .result
                        .page(page)
                totalData = orders.count
                # byebug order를 5개 아닌 2개만 보이게 하기

                render json: { 
                    ok: true,
                    orders: each_serialize(orders),
                    totalResults: totalData,
                    nextPage: orders.next_page,
                    hasNextPage: current_counts < totalData ? true : false,
                    prevPage: page <= 1 ? nil : page - 1,
                    hasPrevPage: page <= 1 ? false : true,
                }
            rescue => exception
                puts "Error #{exception.class}!"
                puts "Error #{exception.message}"
                
                render json: {
                    ok: false,
                    error: "Can't find the orders from consumer" 
                } and return
            end
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't find the consumer" 
            } and return
        end
    end

    def get_orders_from_provider
        provider_id = params[:provider_id]
        page = params[:page].to_i || 1
        sort = params[:sort]
        begin
            provider = User.find(provider_id)

            takePages = 10;
            current_counts = takePages * page

            begin
                order_items = OrderItem.ransack(user_id_eq: provider.id, s: sort)
                        .result
                        .page(page)
                totalData = order_items.count
                # byebug order를 5개 아닌 2개만 보이게 하기

                render json: { 
                    ok: true,
                    order_items: each_serialize(order_items),
                    totalResults: totalData,
                    nextPage: order_items.next_page,
                    hasNextPage: current_counts < totalData ? true : false,
                    prevPage: page <= 1 ? nil : page - 1,
                    hasPrevPage: page <= 1 ? false : true,
                }
            rescue => exception
                puts "Error #{exception.class}!"
                puts "Error #{exception.message}"
                
                render json: {
                    ok: false,
                    error: "Can't find the order items from provider" 
                } and return
            end
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't find the provider" 
            } and return
        end
    end

    def find_order_by_id
        order_id = params[:order_id]
        begin
            order = Order.find(order_id)

            render json: { 
                ok: true,
                order: serialize(order),
                
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't find the order by Id" 
            } and return
        end
    end

    def create
        create_order_items = params[:create_order_items]
        destination = params[:destination]
        deliver_request = params[:deliver_request]
        consumer = current_api_user
        
        begin
            order_final_price = 0;
            order_items = []

            order = Order.create!(
                consumer_id: consumer.id,
                total: 0,
                destination: destination,
                deliver_request: deliver_request,
                ordered_at: '',
            )

            for create_order_item in create_order_items do
                begin
                    item = Item.find(create_order_item[:item_id])
                rescue => exception
                    puts "Error #{exception.class}!"
                    puts "Error : #{exception.message}"
                    
                    for order_item in order_items do
                        OrderItem.delete(order_item.id)
                    end
                    
                    render json: {
                        ok: false,
                        error: "Can't find the item" 
                    } and return
                end

                if item.stock - create_order_item[:count] < 0
                    for order_item in order_items do
                        OrderItem.delete(order_item.id)
                    end
                    
                    render json: {
                        ok: false,
                        error: "You orderd the items more than stocks of item" 
                    } and return
                end

                item_price = item.sale_price * create_order_item[:count];
                order_final_price += item_price;
        
                item.stock -= create_order_item[:count];
                order_item = OrderItem.create!(
                    count: create_order_item[:count],
                    item_id: item.id,
                    user_id: consumer.id,
                    order_id: order.id
                )

                order_items.push(order_item);
            end

            order.total = order_final_price
            order.order_items = order_items

            ordered_at = "#{DateTime.current.year}. #{DateTime.current.month}. #{DateTime.current.day}"
            order.ordered_at = ordered_at;
            order.save

            render json: {
                ok: true,
                orderId: order.id,
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't order the item" 
            } and return
        end
    end
end
