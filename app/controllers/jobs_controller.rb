class JobsController < ApplicationController
  authorize_resource

  def index
    @events = Event.all
    @jobs = Job.all
  end

  def new
    @events = Event.all
    @job = Job.new(job_params)
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      flash[:notice] = "#{@job.name} has been successfully created."
      redirect_to @job.workable
    else
      render :new
    end
  end

  def edit
    @events = Event.all
    @job = Job.find(params[:id])
  end

  def update
    @job = Job.find(params[:id])
    if params[:job][:signing_up]
      @job.update(user_id: current_user.id)
      flash[:notice] = "Congratulations! You are signed up for the job #{@job.name}."
      redirect_to @job
    elsif params[:job][:resigning]
      @job.update(user_id: nil)
      flash[:notice] = "You have resigned from the job #{@job.name}."
      redirect_to @job
    elsif params[:job][:job_done]
      @job.change_status
      @job.save
      flash[:notice] = "You have changed the job completion status."
      redirect_to @job
    else
      @job.update(job_params)
      flash[:notice] = "#{@job.name} got updated."
      redirect_to @job
    end
  end

  def show
    @events = Event.all
    @job = Job.find(params[:id])
    @task = Task.new(params[:job_id])
    @comment = Comment.new(:commentable => @job)
    @commentable = @job
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    flash[:notice] = "Job '#{@job.name}' deleted."
    redirect_to @job.workable
  end

private

  def job_params
    params.require(:job).permit(:name, :workable_id, :workable_type, :description, :due_date, :done)
  end
end
