class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(env["omniauth.auth"], current_user)

        if @user.persisted?
          sign_in @user
          set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
          #request.format = :json
          respond_to do |format|
            format.json { render :json => @user, :status => :ok }
            format.html { sign_in_and_redirect @user, event: :authentication}
          end

        else
          session["devise.#{provider}_data"] = env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
  end

  [:twitter, :facebook, :linked_in].each do |provider|
    provides_callback_for provider
  end

  
end