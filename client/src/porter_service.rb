require_relative 'http_json_service'

class PorterService

  def sha
    get(__method__)
  end

  def port(id)
    post(__method__, id)
  end

  private

  include HttpJsonService

end
