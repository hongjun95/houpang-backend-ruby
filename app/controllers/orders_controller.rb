class OrdersController < ApiController
    def create
        create_order_items = params[:create_order_items]
        destination = params[:destination]
        deliver_request = params[:deliver_request]
        consumer = current_api_user
        
        begin
            order_final_price = 0;
            order_items = []

            order = Order.create!(
                user_id: consumer.id,
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

    def get_orders_from_consumer
        consumer_id = params[:consumer_id]
        page = params[:page].to_i || 1
        sort = params[:sort]
        begin
            consumer = User.find(consumer_id)

            takePages = 10;
            current_counts = takePages * page

            begin
                orders = Order.left_joins(:order_items)
                        .ransack(user_id_eq: consumer.id, s: sort)
                        .result
                        .page(page)
                totalData = orders.count
                # byebug order를 5개 아닌 2개만 보이게 하기
                puts orders

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

            # const [orders, totalOrders] = await this.orders.findAndCount({
            #     where: {
            #         consumer,
            #     },
            #     skip: (page - 1) * takePages,
            #     take: takePages,
            #     relations: [
            #         'orderItems',
            #         'orderItems.product',
            #         'orderItems.product.category',
            #         'orderItems.product.provider',
            #     ],
            #     order: {
            #         createdAt: 'DESC',
            #     },
            # });
    
            # const paginationObj = createPaginationObj({
            #     takePages,
            #     page,
            #     totalData: totalOrders,
            # });
    
            # return {
            #     ok: true,
            #     orders,
            #     ...paginationObj,
            # };
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't find the consumer" 
            } and return
        end
    end
end
