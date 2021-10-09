class LikesController < ApiController
    def show
        begin
            current_user = current_api_user
            like = Like.find_by(user_id: current_user.id)
            render json: {
                ok:true,
                like: serialize(like)
            }
        rescue => exception
            render json: {
                ok: false,
                error: "Can't find like list"
            } and return
        end
    end

    def like_item
        begin
            item_id = params[:item_id]
            current_user = current_api_user

            item = Item.find(item_id)
        rescue => exception
            puts "Error #{exception.class}!"
            render json: {
                ok: false,
                error: "Item doesn't exist" 
            } and return
        else
            begin
                like = Like.find_by(user_id: current_user.id)

                like.items.push(item)

                render json: {
                    ok: true
                }
            rescue => exception
                puts "Error #{exception.class}!"
                render json: {
                    ok: false,
                    error: "Can't find the like list" 
                } and return
            end
        end
    end

    def unlike_item
        begin
            item_id = params[:item_id]
            current_user = current_api_user

            item = Item.find(item_id)
        rescue => exception
            puts "Error #{exception.class}!"
            render json: {
                ok: false,
                error: "Item doesn't exist" 
            } and return
        else
            begin
                like = Like.find_by(user_id: current_user.id)

                like.items = like.items.select {|item| item.id != item_id.to_i}

                render json: {
                    ok: true
                }
            rescue => exception
                puts "Error #{exception.class}!"
                render json: {
                    ok: false,
                    error: "Can't find the like list" 
                } and return
            end
        end
    end
end
