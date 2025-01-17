class OrdersController < ApiController
    def get_orders_from_consumer
        consumer_id = params[:consumer_id]
        page = params[:page].to_i || 1
        sort = params[:sort]
        begin
            consumer = User.find(consumer_id)

            take_pages = 10;
            current_counts = take_pages * page

            begin
                orders = Order.ransack(user_id_eq: consumer.id, s: sort)
                        .result
                        .page(page)
                total_data = orders.count

                render json: {
                    ok: true,
                    orders: each_serialize(orders),
                    total_results: total_data,
                    next_page: orders.next_page,
                    has_next_page: current_counts < total_data ? true : false,
                    prev_page: page <= 1 ? nil : page - 1,
                    has_prev_page: page <= 1 ? false : true,
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

            take_pages = 10;
            current_counts = take_pages * page

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

    def find_order_item_by_id
        order_item_id = params[:order_item_id]
        begin
            order_item = OrderItem.find(order_item_id)

            render json: { 
                ok: true,
                order_item: serialize(order_item),
                
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't find the order item by Id" 
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
                        OrderItem.destory(order_item.id)
                    end
                    
                    render json: {
                        ok: false,
                        error: "Can't find the item" 
                    } and return
                end

                if item.stock - create_order_item[:count] < 0
                    for order_item in order_items do
                        OrderItem.destory(order_item.id)
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

    def cancel_oder_item
        order_item_id = params[:order_item_id]
        begin
            @return_obj={}

            # Find the order item

            @sql_find_order_item = "SELECT order_items.* 
                                    FROM order_items
                                    WHERE order_items.id = #{order_item_id}
                                    LIMIT 1;"
            @order_items = ActiveRecord::Base.connection.execute(@sql_find_order_item)

            if @order_items.count == 0
                render json: {
                    ok: false,
                    error: "Can't find the order item" 
                } and return
            end

            
            @order_item = @order_items[0]
            @return_obj = @order_item.dup

            # Find the item

            @sql_find_item = "SELECT items.* 
                                FROM items
                                WHERE items.id = #{@order_item['item_id']}
                                ;"

            @items = ActiveRecord::Base.connection.execute(@sql_find_item)

            if @items.count == 0
                render json: {
                    ok: false,
                    error: "Can't find the item" 
                } and return
            end

            @item = @items[0]
            
            # Find the order
            
            @sql_find_order = "SELECT orders.* 
                                FROM orders
                                WHERE orders.id = #{@order_item['order_id']}
                                LIMIT 1;"
            @orders = ActiveRecord::Base.connection.execute(@sql_find_order)

            if @orders.count == 0
                render json: {
                    ok: false,
                    error: "Can't find the order" 
                } and return
            end

            @order = @orders[0]

            # Find the consumer
            
            @sql_find_consumer = "SELECT users.* 
                                FROM users
                                WHERE users.id = #{@order['user_id']}
                                LIMIT 1;"

            @consumers = ActiveRecord::Base.connection.execute(@sql_find_consumer)

            if @consumers.count == 0
                render json: {
                    ok: false,
                    error: "Can't find the consumer" 
                } and return
            end

            # Change order status Canceld

            @sql_update_order_item_status = "UPDATE order_items
                                            SET status = #{OrderItem.statuses[:Canceled]}
                                            WHERE id = #{@order_item['id']}
                                            RETURNING order_items.*
                                            ;"
            
            @new_order_item = ActiveRecord::Base.connection.execute(@sql_update_order_item_status)
            @return_obj = @new_order_item[0].dup
            @return_obj['order'] = @order.dup
            @return_obj['consumer'] = @consumers[0].dup

            sum = @order_item['count'] + @item['stock']
            @sql_update_order_item_status = "UPDATE items
                                            SET stock = #{sum}
                                            WHERE id = #{@item['id']}
                                            RETURNING items.*
                                            ;"
            @new_item = ActiveRecord::Base.connection.execute(@sql_update_order_item_status)
            @return_obj['item'] = @new_item[0]

            render json: { 
                ok: true,
                order_item: @return_obj,
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't cancel the order item" 
            } and return
        end
    end

    def update_order_status
        order_item_id = params[:order_item_id]
        order_status = params[:order_status]
        user = current_api_user
        begin
            if user.role == User.Consumer
                render json: {
                    ok: false,
                    error: "You cannot change the order status" 
                } and return
            end

            # Find the order item

            @sql_find_order_item = "SELECT order_items.* 
                                    FROM order_items
                                    WHERE order_items.id = #{order_item_id}
                                    LIMIT 1;"
            @order_items = ActiveRecord::Base.connection.execute(@sql_find_order_item)

            if @order_items.count == 0
                render json: {
                    ok: false,
                    error: "Can't change the order status, because order status is canceld" 
                } and return
            end
            
            @order_item = @order_items[0]

            if @order_item['status'] == OrderItem.Canceled
                render json: {
                    ok: false,
                    error: "Can't find the order item" 
                } and return
            end

            can_edit = true;
            if user.role == User.Provider
                if order_status != OrderItem.Received
                    can_edit = false
                end
            elsif user.role == User.Admin
                if order_status != OrderItem.Delivering && order_status != OrderItem.statuses['Delivered']
                    can_edit = false
                end
            end

            if !can_edit
                render json: {
                    ok: false,
                    error: "Can't change the order status" 
                } and return
            end

            # Change order status Canceld

            @sql_update_order_item_status = "UPDATE order_items
                                            SET status = #{OrderItem.statuses["#{order_status}"]}
                                            WHERE id = #{order_item_id}
                                            RETURNING order_items.*
                                            ;"
            @new_order_item = ActiveRecord::Base.connection.execute(@sql_update_order_item_status)


            render json: { 
                ok: true,
                order_item: @new_order_item[0],
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't cancel the order item" 
            } and return
        end
    end
end
