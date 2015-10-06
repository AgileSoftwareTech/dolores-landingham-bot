class EmployeesController < ApplicationController
  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)

    unless EmployeeFinder.new.employee_exists?(@employee.slack_username)
      flash.now[:error] = "\"#{@employee.slack_username}\" is not a valid employee (that username was not found)."
      render action: :new
      return
    end

    if @employee.save
      flash[:notice] = "Thanks for adding #{@employee.slack_username}"
      redirect_to root_path
    else
      flash.now[:error] = "Could not create employee"
      render action: :new
    end
  end

  def index
    @employees = Employee.order(started_on: :desc)
  end

  def edit
    @employee = Employee.find(params[:id])
  end

  def update
    @employee = Employee.find(params[:id])

    unless EmployeeFinder.new.employee_exists?(@employee.slack_username)
      flash.now[:error] = "\"#{@employee.slack_username}\" is not a valid employee (that username was not found)."
      render action: :edit
      return
    end

    if @employee.update(employee_params)
      flash[:notice] = "Employee updated successfully"
      redirect_to employees_path
    else
      flash.now[:error] = "Could not update employee"
      render action: :edit
    end
  end

  private

  def employee_params
    params.require(:employee).permit(:slack_username, :started_on)
  end
end
