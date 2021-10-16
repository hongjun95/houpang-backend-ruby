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
            puts review
        
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

    def index
        current_user = current_api_user
        page = params[:page].to_i || 1
        sort = params[:sort] || 'crated_at desc'
        item_id = params[:item_id]
        take_pages = 8;
        current_counts = take_pages * page.to_i;
    
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

            reviews = Review.ransack(item_id_eq:item.id, s: sort).result.page(page)
            total_data = reviews.count

            render json: { 
                ok: true,
                reviews: each_serialize(reviews),
                avg_rating: item.reviews_average,
                total_results: total_data,
                next_page: reviews.next_page,
                has_next_page: current_counts < total_data ? true : false,
                prev_page: page <= 1 ? nil : page - 1,
                has_prev_page: page <= 1 ? false : true,
            }
        rescue => exception
            puts "Error #{exception.class}!"
            puts "Error : #{exception.message}"
            
            render json: {
                ok: false,
                error: "Can't find the reviews" 
            } and return
        end
    end

    private

    def create_params
        params.require(:review).permit(:content, :rating)
    end
end
