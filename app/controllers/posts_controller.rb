class PostsController < ApplicationController
  


  require 'RMagick'
  include Magick
  
  # GET /posts
  # GET /posts.xml
  before_filter :authenticate, :except => [:index, :front_page]
#layout :determine_layout
 layout "main"
 
#def determine_layout
#  %w(new).include?(action_name) ? "photos" : "main"
#end
 
  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
     # @post=Post.new
     # @post=Post.create()
       @post=current_user.posts.create()
   
    
    respond_to do |format|
      format.html  # new.html.erb
      format.xml  
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    tmpfile=Tempfile.new('my_pic')
    cat1= "#{RAILS_ROOT}/public/images/gloria1.jpg"
    cat2= "#{RAILS_ROOT}/public/images/gloria2.jpg"
    images=ImageList.new(cat1, cat2)
    images[1].page=Rectangle.new(images[1].columns, images[1].rows, 20, 200)
    com_img=images.flatten_images
    com_img.write(tmpfile.path)
    @post = Post.create(:avatar => tmpfile)
    # @post.save
    # @post.avatar="/images/cute-kitten.jpg"

    respond_to do |format|
      if @post.save
        format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
   # @post = Post.find(params[:id])
   
   #  @post=Post.last
   @post=current_user.posts.last
   com_img=Post.updatepost(@post)
   tmpfile=Tempfile.new('my_pic')
   com_img.write(tmpfile.path)
   
    respond_to do |format|
      #if @post.update_attributes(params[:post])require File.dirname(__FILE__) + '/posts_controller'
      
      if @post.update_attributes(:avatar => tmpfile)
       if current_user 
     
       #  puts current_user.token 
       # FbGraph::User.me(current_user.token).feed!(
       # :picture =>@post.avatar.url
       #   ) 
 
             FbGraph::User.me(current_user.token).photo!(
          
             :url => @post.avatar.url,
             :message => 'Made using Cats in Your Hats - http://www.catsinyourhats.com'
             )
             
      end  
      
      
        format.html { redirect_to(@post, :notice => 'Post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def sayhello
 
  # @post=Post.last
  @post=current_user.posts.last
  Post.setCoordinates(@post, params)
   
     
   respond_to do |format|
     format.js
  
   end
  end
  
  def authenticate
    deny_access unless current_user
  end 


  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
end

# code for the front_page of the website
def front_page
  respond_to do |format|
    format.html # front_page.html.erb
  end
end


def share_link
  if current_user
     redirect_to(new_post_path) 
    
  else
    respond_to do |format|
      format.js 
    end
  end  
end
