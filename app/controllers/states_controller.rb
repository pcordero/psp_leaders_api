class StatesController < ApplicationController
  respond_to :json

  before_action do
    @state = State.find_by_code(params[:id].upcase) if params[:id]
  end

  # tested -- wget http://localhost:3010/states/
  def index
    #debugger
    #@leaders = @state.leaders.current
    @states = State.all
    #debugger
    render json: @states
  end

  # tested -- wget http://localhost:3010/states/IN 
  # tested -- wget http://localhost:3010/states/in
  def show
    #@leader = Leader.find_by_slug(params[:id])
    #@state = State.find_by_slug(params[:id])
    #debugger
    render json: @state
    #render json: @state
    #debugger
    #raise @state.inspect
    #@state = @leader.state
  end

  # def us_senate
  #   @leaders =  @state.leaders.us_senate
  #   render json: @leaders
  #   #render 'index'
  # end
  #
  # def us_house
  #   #@leaders = @state.leaders.us_house
  #   #render 'index'
  # end
  #
  # def state_senate
  #   #@leaders = @state.leaders.state_senate
  #   #render 'index'
  # end
  #
  # def state_house
  #   #@leaders = @state.leaders.state_house
  #   #render 'index'
  # end
end
