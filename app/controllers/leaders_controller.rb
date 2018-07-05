class LeadersController < ApplicationController
  
  respond_to :json
  
  
  before_action do
    #raise params[:action].inspect
    @state = State.find_by_code(params[:state_id].upcase) if params[:state_id]
    @scope1 = params[:controller]
    @scope2 = params[:action]
    if params[:action] == "show" || params[:action] == "states"
    else
      @source_offset = SourceOffset.get_last(@state.code, @scope1, @scope2)
    end
    if params[:action] == "show" || params[:action] == "states"
      #raise "ddd"
    elsif @source_offset.nil?
      # Case 0 - never served an entry so create an offset of 0
      @source_offset = SourceOffset.save_offset_position(@state.code, @scope1, @scope2, 0)
    elsif @source_offset && @source_offset.date_created_at == Date.today
      # Case 1 - already served for today so do nothing; use what was found
    # elsif @source_offset.offset * ROWS_TO_SERVE >= total_rows
    #   # Case 1a - no more data to serve so reset to 0
    #   # todo
    #   @source_offset = SourceOffset.save_offset_position(@state.code, @scope1, @scope2, 0)
    else @source_offset
      # Case 2 -- offset exists but its older so need to create one for today to record
      @source_offset = SourceOffset.save_offset_position(@state.code, @scope1, @scope2, @source_offset.offset + ROWS_TO_SERVE)
    end
  end

  # tested -- wget http://localhost:3010/states/IN/leaders
  def index
    if Rails.env.development?
      @leaders = @state.leaders.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    else
      @leaders = @state.leaders.current.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    end
    render json: @leaders
  end

  def show
    @leader = Leader.find_by_slug(params[:id])
    @state = @leader.state
    render json: @leader
  end
  
  def states
    #raise "foo"
    #debugger
    @state = State.where(code: params[:id].upcase).first
    render json: @state
  end
  
  def leaders
    if Rails.env.development?
      @leaders = @state.leaders.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    else
      @leaders = @state.leaders.current.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    end
    render json: @leaders
  end

  # tested -- wget http://localhost:3010/states/IN/leaders/us_senate
  def us_senate
    if Rails.env.development?
      #debugger
      @leaders = @state.leaders.us_senate.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    else
      @leaders = @state.leaders.us_senate.current.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    end
    render json: @leaders
  end

  # tested -- wget http://localhost:3010/states/IN/leaders/us_house
  def us_house
    if Rails.env.development?
      @leaders =  @state.leaders.us_house.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    else
      @leaders =  @state.leaders.us_house.current.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    end
    render json: @leaders
  end

  # tested -- wget http://localhost:3010/states/IN/leaders/state_senate
  def state_senate
    if Rails.env.development?
      @leaders =  @state.leaders.state_senate.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    else
      @leaders =  @state.leaders.state_senate.current.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    end
    render json: @leaders
  end

  # tested -- wget http://localhost:3010/states/IN/leaders/state_house
  def state_house
    if Rails.env.development?
      @leaders =  @state.leaders.state_house.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    else
      @leaders =  @state.leaders.state_house.current.limit(ROWS_TO_SERVE).offset(@source_offset.offset)
    end
    #raise @leaders.map(&:name).inspect
    render json: @leaders
  end
  
  private
  
end
