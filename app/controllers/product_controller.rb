class ProductController < ApplicationController
  def new
  end

  def create
    # byebug
    product=Product.create(name: params[:name], description: params[:description])
    Dir.mkdir("#{Rails.root}/public/"+product.id.to_s)
    begin
      if !params[:files_list].blank?
        files_list = ActiveSupport::JSON.decode(params[:files_list])
        files_list.each do |pic|
          File.rename( "#{Rails.root}/"+pic, "#{Rails.root}/public/"+product.id.to_s+'/'+File.basename(pic))
          product.pics.create(name: pic)
        end
      end
    rescue ActiveSupport::JSON::ParserError
      # nil
    end
    redirect_to product_new_url, notice: "Success! Question is created."
  end

  def upload
    pics = params[:file] # Take the files which are sent by HTTP POST request.
    time_footprint = Time.now.to_i.to_s(:number) # Generate a unique number to rename the files to prevent duplication

    files_list = []
    pics.values.each do |pic|
      filename = File.join('public', 'uploads', time_footprint + pic.original_filename)
      files_list.push(filename)
      File.open(Rails.root.join(filename), 'wb') do |file|
        file.write(pic.read)
      end
    end

    render json: { message: 'You have successfully uploaded your images.', files_list: files_list } #return a JSON object amd success message if uploading is successful
  end

#  private
#    def product_params
#      params.require(:product).permit(:files_list, :name, :description, :file)
#    end
end
