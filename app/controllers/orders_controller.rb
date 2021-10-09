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
end
