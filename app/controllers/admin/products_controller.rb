class Admin::ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_namespace


  def index
    @products = Product.all
  end

  def new
    @product = Product.new
    @submit_message = "Create product";
  end

  def edit
    @submit_message = "Edit product";
  end

  def show
    if(@product.nil?)
      flash[:error] = "ERROR: product with id #{params[:id]} could not be found"
      redirect_to admin_products_path
    end
  end

  def create
    @product = Product.new(product_params)
    if @product.save
        flash[:success] = "SUCCESS: Product successfully created!"
        redirect_to admin_products_path
    else
      flash[:error] = "ERROR: product could not be created!"
      render 'new'
    end
  end

  def update
    if @product.update(product_params)
      flash[:success] = "Product successfully updated!"
      redirect_to admin_products_path
    else
      render 'edit'
    end
  end

  def destroy
    if(!@product.nil?)
      @product.destroy
      flash[:success] = "Product destroyed successfully!"
    else
      flash[:error] = "User was nil"
    end
    redirect_to admin_products_path
  end

  private

    def set_product
      begin
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @product = nil
      end
    end

    def product_params
      params.require(:product).permit(:name, :stock, :unit, :price);
    end

    def set_namespace
      product_exists = @product && !@product.new_record?
      @namespace = product_exists ? admin_product_path(@product) : admin_products_path
    end

end
