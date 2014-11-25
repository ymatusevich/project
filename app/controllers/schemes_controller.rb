class SchemesController < InheritedResources::Base

	before_filter :set_params_scheme, only: [:edit, :show, :destroy]

	def index
		authorize! :read, @scheme 
		@schemes = Scheme.search params[:search]
	end

	def edit
		authorize! :edit, @scheme
	end

	def new
		@scheme = Scheme.new
		@elements = Element.all		
		authorize! :create, @scheme
	end

	def create
		@scheme = Scheme.new(scheme_params)
		@scheme.user_id = current_user.id
		@scheme.save!
		if @scheme.errors.empty?
			redirect_to user_root_path
			flash[:notice] = "Схема #{@scheme.title} успешно создана"
		else 
			flash[:alert] = "@scheme.error"
			render "new"
		end
		authorize! :create, @scheme
	end

	def show
		if current_user.nil?
			@schemes = Scheme.all
		else
			@schemes = Scheme.where(:user_id => current_user.id)
		end	
	end

	def destroy
		authorize! :destroy, @scheme
		if current_user.role == "admin"
			@scheme.destroy
      flash[:notice] = "Successfully deleted Scheme."
			render "users/administrator_menu"
		end
	end

	private

		def set_params_scheme
			@scheme = Scheme.find(params[:id])
		end

		def scheme_params
			params.require(:scheme).permit(:title, :description, :short_description, :rating)
		end

end
