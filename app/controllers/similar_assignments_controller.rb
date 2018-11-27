class SimilarAssignmentsController < ApplicationController
  include SimilarAssignmentsHelper
  skip_before_action :authorize, only: [:get, :update]

  # GET /similar_assignments/:id
  def get
    @assignment_id = params[:id]
    begin
      if current_user.role.name == 'Student'
        throw Exception.new
      end
      @similar_assignments = SimilarAssignment.where(:assignment_id => @assignment_id).pluck(:is_similar_for)
    rescue ActiveRecord::RecordNotFound => e
      render json: {"success" => false, "error" => "Resource not found"}
    rescue Exception
      render json: {"success" => false, "error" => "Unauthorized"}
    else
      @res = get_asssignments_set(@similar_assignments)
      render json: {"success" => true, "values" => @res}
    end
  end

  # POST /similar_assigments/:id
  def update
    begin
      @check_lists = params[:similar].to_hash
      @assignment_id = params[:id].to_i
      checked_list = @check_lists["checked"]
      unchecked_list = @check_lists["unchecked"]
      if !checked_list.nil?
        checked_list.each do |child|
          id = SimilarAssignment.where(:is_similar_for => child.to_i, :association_intent => 'Review',
                                       :assignment_id => @assignment_id).ids
          if id.empty?
            SimilarAssignment.create({:is_similar_for => child.to_i, :association_intent => 'Review',
                                      :assignment_id => @assignment_id})
          end
        end
      end

      if !unchecked_list.nil?
        unchecked_list.each do |child|
          id = SimilarAssignment.where(:is_similar_for => child.to_i, :association_intent => 'Review',
                                       :assignment_id => @assignment_id).ids
          puts id
          if !(id.empty?)
            SimilarAssignment.where({:is_similar_for => child.to_i, :association_intent => 'Review',
                                     :assignment_id => @assignment_id}).destroy_all
          end
        end
        puts "end of uncheck loop"
      end
    rescue
      render json: {"success" => false, "error" => "Something went wrong"}
    else
      render json: {"success" => true}
    end
  end
end