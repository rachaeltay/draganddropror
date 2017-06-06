class ProductController < ApplicationController
  def new
  end

  def create
    byebug
    files_list = ActiveSupport::JSON.decode(params[:files_list])
    product=Product.create(name: params[:name], description: params[:description])
    Dir.mkdir("#{Rails.root}/public/"+product.id.to_s)
    files_list.each do |pic|
      File.rename( "#{Rails.root}/"+pic, "#{Rails.root}/public/"+product.id.to_s+'/'+File.basename(pic))
      product.pics.create(name: pic)
    end
    redirect_to product_new_url, notice: "Success! Question is created."
  end

  def upload
    # byebug
    pic = params[:file] # Take the files which are sent by HTTP POST request.
    time_footprint = Time.now.to_i.to_s(:number) # Generate a unique number to rename the files to prevent duplication


    File.open(Rails.root.join('public', 'uploads', pic.original_filename), 'wb') do |file|
      file.write(pic.read)
      File.rename(file, 'public/uploads/' + time_footprint + pic.original_filename)
    end

    files_list = Dir['public/uploads/*'].to_json #get a list of all files in the {public/uploads} directory and make a JSON to pass to the server
    render json: { message: 'You have successfully uploaded your images.', files_list: files_list } #return a JSON object amd success message if uploading is successful
  end

#  private
#    def product_params
#      params.require(:product).permit(:files_list, :name, :description, :file)
#    end
end
