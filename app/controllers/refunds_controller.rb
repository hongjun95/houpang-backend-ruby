class RefundsController < ApiController
    def create
        order_item_id = params[:order_item_id]
        status = params[:status]
        user = current_api_user
        begin
            if (status == "Exchanged" and
                (create_params[:refund_pay] or
                create_params[:send_day].nil? or
                create_params[:send_place].nil?))
                render json: {
                    ok: false,
                    error: "You requested exchange"
                } and return
            elsif (status == "Refunded" &&
                    (create_params[:send_day] ||
                    create_params[:send_place] ||
                    create_params[:refund_pay].nil?))
                render json: {
                    ok: false,
                    error: "You requested the refund"
                } and return
            end
            
            begin
                order_item = OrderItem.find_by('order_items.id = ?', order_item_id)
            rescue => exception
                puts "Error #{exception.class}!"
                puts "Error : #{exception.message}"

                render json: {
                    ok: false,
                    error: "Can't find the order item"
                } and return
            end

            if order_item.nil?
                render json: {
                    ok: false,
                    error: "There is no order item about the item."
                } and return
            end

            if (order_item.status == "Exchanged" ||
                order_item.status == "Refunded")
                render json: {
                    ok: false,
                    error: "Order item is already exchanged or refunded."
                } and return
            end

            create_obj = create_params
            create_obj['user_id'] = user.id
            create_obj['order_item_id'] = order_item.id
            create_obj['refunded_at'] = "#{DateTime.current.year}. #{DateTime.current.month}. #{DateTime.current.day}"

            begin
                @refund = Refund.create(create_obj)
            rescue => exception
                puts "Error #{exception.class}!"
                puts "Error : #{exception.message}"

                render json: {
                    ok: false,
                    error: "Can't create the refund"
                } and return
            end
        
            if status == 'Exchanged'
                order_item.status == OrderItem.statuses['Exchanged']
            elsif status == 'Refunded'
                order_item.status == OrderItem.statuses['Refunded']
            end

            render json: {
                ok: true,
                refund: @refund
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't refund or exchange" 
            } and return
        end
    end

    def get_refunds_from_consumer
        consumer_id = params[:consumer_id]
        page = params[:page].to_i || 1
        begin
            @consumer = User.find(consumer_id)
            
            if @consumer.nil?
                render json: {
                    ok: false,
                    error: "Consumer doesn't exist"
                } and return
            end

            take_pages = 10;
            current_counts = take_pages * page

            begin
                refunds = Refund.ransack(user_id_eq: @consumer.id)
                        .result
                        .includes(:order_item => :item)
                        .page(page)
                total_data = refunds.count

                render json: { 
                    ok: true,
                    refunds: each_serialize(refunds),
                    total_results: total_data,
                    next_page: refunds.next_page,
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
                error: "Can't get refunds from consumer" 
            } and return
        end
    end

    def get_refunds_from_provider
        provider_id = params[:provider_id]
        page = params[:page].to_i || 1
        begin
            @provider = User.find(provider_id)
            
            if @provider.nil?
                render json: {
                    ok: false,
                    error: "Provider doesn't exist"
                } and return
            end

            take_pages = 10;
            current_counts = take_pages * page

            begin
                refunds = Refund
                        .joins( :order_item => { :item => :provider})
                        .where( :users => { :id => @provider.id })
                        .page(page)
                total_data = refunds.count

                render json: { 
                    ok: true,
                    refunds: each_serialize(refunds),
                    total_results: total_data,
                    next_page: refunds.next_page,
                    has_next_page: current_counts < total_data ? true : false,
                    prev_page: page <= 1 ? nil : page - 1,
                    has_prev_page: page <= 1 ? false : true,
                }
            rescue => exception
                puts "Error #{exception.class}!"
                puts "Error #{exception.message}"
                
                render json: {
                    ok: false,
                    error: "Can't find the orders from provider" 
                } and return
            end
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't get refunds from provider" 
            } and return
        end
    end

    private

    def create_params
        params.require(:refund).permit(
            :count,
            :status,
            :refunded_at,
            :problem_title,
            :problem_description,
            :recall_place,
            :recall_day,
            :recall_title,
            :recall_description,
            :send_place,
            :send_day,
            :refund_pay,
        )
    end
end
