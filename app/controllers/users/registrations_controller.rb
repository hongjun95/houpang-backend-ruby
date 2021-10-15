module Users
  class RegistrationsController < Devise::RegistrationsController
    protect_from_forgery with: :exception
    skip_before_action :authenticate_scope!, only: [:update]
    skip_before_action :verify_authenticity_token

    def create
      super do |user|
        if user.persisted?
          if resource.active_for_authentication?
            like = Like.create!(user_id: user.id)
            user.user_img = "http://localhost:3000#{params[:user][:user_img]}"
            user.save!

            payload = { user_id: user.id, user: PayloadSerializer.new.serialize(user) }
            session = JWTSessions::Session.new(payload: payload, refresh_by_access_allowed: true)
            tokens = session.login
            
            response.set_cookie(
              JWTSessions.access_cookie,
              value: tokens[:access],
              httponly: true,
              secure: Rails.env.production?
            )

            render json: { csrf: tokens[:csrf], token: tokens[:access] } and return
          else
            render json: { error: I18n.t("devise.registrations.signed_up_but_inactive") }, status: :locked and return
          end
        else
          render json: { error: user.errors.full_messages.join(" ") }, status: :unprocessable_entity and return
        end
      end
    end
  end
end
