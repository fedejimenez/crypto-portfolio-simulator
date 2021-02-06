class SessionsController < ApplicationController
  include UsersHelper

	def new
  end

  def create
    user = User.find_by_email(params[:email])
    # If the user exists AND the password entered is correct.
    if user && user.authenticate(params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user 
      # logged in when they navigate around our website.
      # flash[:success] = 'Successfully Logged In!'
      session[:user_id] = user.id
      sign_in(user)
      respond_to do |format|
        format.html {redirect_to home_path(valid_pass: true)}
      end

    else
    # If user's login doesn't work, send them back to the login form.
      flash[:warning] = 'Invalid Username or Password'
      respond_to do |format|
        format.html {redirect_to root_path(valid_pass: false)}
        format.js {render 'login.js'}
      end
    end
  end

  def destroy
    session[:user_id] = nil
    reset_session
    # flash[:success] = 'Successfully Logged Out!'
    redirect_to root_path, turbolinks: false
  end

  def create_from_omniauth
    auth_hash = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"]) ||  Authentication.create_with_omniauth(auth_hash)

    # if: previously already logged in with OAuth
    if authentication.user
      user = authentication.user
      authentication.update_token(auth_hash)
      @next = home_path
      # flash[:success] = 'Successfully Logged In!'
    # else: user logs in with OAuth for the first time
    else
      user = User.create_with_auth_and_hash(authentication, auth_hash)
      # you are expected to have a path that leads to a page for editing user details
      # @next = edit_user_path(user)
      @next = home_path
      flash[:success] = 'User was successfully created, now you have U$D 10000 to start the game!'
      RegistrationJob.perform_later user.email
    end
    session[:user_id] = user.id
    sign_in(user)
    redirect_to @next , turbolinks: false
  end

end
