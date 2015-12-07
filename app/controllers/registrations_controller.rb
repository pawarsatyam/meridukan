class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, only: [:create]
  
  def create
    super
    resource.add_user_role(params[:role])
  end

  def update
    respond_to do |format|
      if resource.update(account_update_params)
        format.html { redirect_to after_update_path(resource), notice: 'Profile was successfully updated.' }
      else
        format.html { render :set_user_info }
      end
    end    
  end

  def set_user_info
    get_ip_info(current_user)
    render :layout=>"layouts/get_user"
  end

  protected

  def configure_permitted_parameters
    params[:user][:password]=User.generated_password
    devise_parameter_sanitizer.for(:sign_up)
  end

  def account_update_params
    params.require(:user).permit(:email,:first_name, :last_name, :email, :phone, :address, :country, :state, :city,:mobile,:pin_code,:ip_address ,stores_attributes:[:id,:name,:address,:state,:country,:city,:pin_code,:landmark,:lat,:lng])
  end

  def sign_up(resource_name, resource)
    true
  end

  def after_sign_up_path_for(resource)  	
    User.send_otp(params[:user][:password], params[:user][:mobile])
    session[:mobile]=params[:user][:mobile]
  	flash[:success] = "We have send your OTP / password at "+params[:user][:mobile]
    verify_otp_path
  end

  def after_update_path(user)
    if user.check_user_access?
      new_product_path
    else
      root_path
    end
  end
end