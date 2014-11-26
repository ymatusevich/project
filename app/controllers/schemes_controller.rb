class SchemesController < InheritedResources::Base

	before_filter :set_params_scheme, only: [:edit, :show, :destroy]
	before_action :count_average_rating, only: [:show]

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
			@schemes = Scheme.includes(:ratings, :user)
	end

	def destroy
		authorize! :destroy, @scheme
		if current_user.role == "admin"
			@scheme.destroy
      flash[:notice] = "Successfully deleted Scheme."
			render "users/administrator_menu"
		end
	end

	def search
			@schemes = Scheme.search(params[:search], :sql => {:include => [:user, :ratings]},
                             										:ranker => :bm25,
                             										:match_mode => :any,
                             										:page => params[:page],
																								:per_page => 10)
	end

	private

		def count_average_rating
			@scheme.average_rating
		end

		def set_params_scheme
			@scheme = Scheme.find(params[:id])
		end

		def scheme_params
			params.require(:scheme).permit(:title, :description, :short_description, :rating)
		end

end
