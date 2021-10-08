class LikesController < ApiController
    def show
        current_user = current_api_user
        puts current_user.email
        like = Like.find_by(user_id: current_user.id)

        if !like
            render json: { ok: false, error: "Can't find like list" } and return
        end

        render json: {
            ok:true,
            like: serialize(like)
        }
    end

    def update
        
    end
end
