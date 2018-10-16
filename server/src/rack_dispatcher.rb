require_relative 'client_error'
require_relative 'well_formed_args'
require 'json'

class RackDispatcher

  def initialize(externals, request_class)
    @externals = externals
    @request_class = request_class
  end

  def call(env)
    request = @request_class.new(env)
    path = request.path_info[1..-1] # lose leading /
    body = request.body.read
    target, name, args = validated_name_args(path, body)
    result = target.public_send(name, *args)
    json_response(200, plain({ name => result }))
  rescue => error
    diagnostic = pretty({
      'exception' => {
        'path' => path,
        'body' => body,
        'class' => error.class.name,
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    })
    $stderr.puts(diagnostic)
    $stderr.flush
    json_response(code(error), diagnostic)
  end

  private # = = = = = = = = = = = = = = = = = = =

  def validated_name_args(name, body)
    @well_formed_args = WellFormedArgs.new(body)
    args = case name
      when /^sha$/  then [image]
      when /^port$/ then [porter, kata_id, avatar_name]
      else
        raise ClientError, 'json:malformed'
    end
    target = args.shift
    [target, name, args]
  end

  def porter
    @externals.porter
  end

  def image
    @externals.image
  end

  # - - - - - - - - - - - - - - - -

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  def plain(body)
    JSON.generate(body)
  end

  def pretty(body)
    JSON.pretty_generate(body)
  end

  def code(error)
    if error.is_a?(ClientError)
      400 # client_error
    else
      500 # server_error
    end
  end

  def self.well_formed_args(*names)
    names.each do |name|
      define_method name, &lambda {
        @well_formed_args.send(name)
      }
    end
  end

  well_formed_args :kata_id,
                   :avatar_name

end