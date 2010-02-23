class Admin::CommentsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def index
    @current_comment_id = params[:comment_id]
    page = params[:page] || 1
    per_page = params[:per_page] || 50
    @show_spam = (params[:spam] and params[:spam] == '1') ? true : false
    @comments = Comment.paginate :page => page, :per_page => per_page, :conditions => ['spam = ?', @show_spam], :order => 'created_at DESC'
    respond_to do |format|
      format.html 
    end
  end

  def show
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_to do |format|
      flash[:notice] = "Kommentaren #{t(:deleted, :scope => [:app, :admin_general])}"
      format.html { 
        redirect_to params[:return_to] || comments_admin_page_path(@comment.commentable)
      }
    end
  end
  
  def destroy_all_spam
    @comment = Comment.destroy_all('spam = 1')
    respond_to do |format|
      flash[:notice] = "Alla spam-kommentarer #{t(:deleted, :scope => [:app, :admin_general])}"
      format.html { 
        redirect_to params[:return_to] || comments_admin_page_path(@comment.commentable)
      }
    end
  end
  
  def report_as_spam
    @comment = Comment.find(params[:id])
    @comment.report_as_spam
    respond_to do |format|
      format.html { 
        redirect_to params[:return_to] || admin_comments_path
      }
    end
  end
  
  def report_as_ham
    @comment = Comment.find(params[:id])
    @comment.report_as_ham
    respond_to do |format|
      format.html { 
        redirect_to params[:return_to] || admin_comments_path
      }
    end
  end
end