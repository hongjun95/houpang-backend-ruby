class ReviewsController < ApiController
    def create
        item_id = params[:item_id]
        rating = params[:review][:rating]
        commenter = current_api_user

        begin
            begin
                item = Item.find_by_id(item_id)
            rescue => exception
                puts "Error #{exception.class}!"
                puts "Error : #{exception.message}"
                
                render json: {
                    ok: false,
                    error: "Can't find the item" 
                } and return
            end
            
            order_item = OrderItem.find_by(user_id: commenter.id, item_id: item.id)
            
            if commenter.id != order_item.user_id
                render json: {
                    ok: false,
                    error: "You don't have auth to write a comment" 
                } and return
            end

            create_obj = create_params
            create_obj['user_id'] = commenter.id
            create_obj['item_id'] = item.id

            review = Review.create!(create_obj)
        
            total_rating = 0;
            reviews_average = 0;

            if item.reviews.count > 0
                reviews_count = item.reviews.count;
                total_rating = item.reviews_average * reviews_count + rating
                reviews_average = total_rating / reviews_count;
            end

            item.reviews_average = reviews_average;
            
            render json:{
                ok: true,
                review: review
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't write a comment" 
            } and return
        end
    end

    private

    def create_params
        params.require(:review).permit(:content, :rating)
    end
end
