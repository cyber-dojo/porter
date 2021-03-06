
class Porter

  def initialize(externals)
    @externals = externals
  end

  def ready
    storer.sha
    saver.sha
  end

  # Ports an old-format practice-session with the given id from storer to saver.
  # Used by port.rb via docker exec, NOT exposed by dispatcher
  def port(id)
    # parameter, the 10-digit id of the practice session (in storer)
    # Returns, the 6-digit id of the practice session ported to saver.
    # If possible the 6-digit id will be the 1st 6 chars of the 10-digit id.
    # The id10->id6 mapping will be recorded in /porter/mapped-ids/
    id2 = id[0..1]
    id8 = id[2..-1]
    dir = disk["/porter/mapped-ids/#{id2}"]
    if dir.exists?(id8)
      return dir.read(id8)
    end
    if !storer.kata_exists?(id)
      fail "malformed:id: !storer.kata_exists?(#{id})"
    end

    manifest = storer.kata_manifest(id)
    update_manifest(manifest)
    set_id(manifest)
    id6 = saver.group_create(manifest)
    remember_mapping(id, id6)

    storer.avatars_started(id).each do |avatar_name|
      kid = group_join(id6, avatar_name)
      increments = storer.avatar_increments(id, avatar_name)
      # skip [0] which is automatically added for creation event
      increments[1..-1].each do |increment|
        colour = increment['colour'] || increment['outcome']
        time = increment['time']
        if time.nil?
          # some increments.json files have "time":"null"
          # update_manifest() has already added 7th usec
          time = manifest['created']
        else
          # time-stamps now use 7th usec integer
          time << 0
        end
        # duration is now stored
        duration = 0.0
        index = increment['number']
        files = storer.tag_visible_files(id, avatar_name, index)
        # some increments have a manifest.json with no 'output'
        stdout = file(files.delete('output') || '')
        stderr = file('')
        status = 0
        update_files(files)
        saver.kata_ran_tests(kid, index, files, time, duration, stdout, stderr, status, colour)
      end
    end

    storer.kata_delete(id)

    id6
  end

  # - - - - - - - - - - - - - - - - - - -

  def update_manifest(manifest)
    # output is now stdout/stderr/status which
    # are separated from files
    manifest['visible_files'].delete('output')
    # time-stamps now use 7th usec integer
    manifest['created'] << 0
    # runner_choice is now dropped
    manifest.delete('runner_choice')
    # each file is now stored in a hash
    manifest['visible_files'].transform_values!{ |content|
      { 'content' => content }
    }
  end

  private

  def update_files(files)
    files.transform_values!{ |content| file(content) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def file(content, truncated = false)
    { 'content' => content,
      'truncated' => truncated
    }
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_id(manifest)
    id6 = manifest['id'][0..5]
    if from_unique?(id6) && to_available?(id6)
      manifest['id'] = id6
    else
      # force saver to generate a new id
      manifest.delete('id')
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def from_unique?(id6)
    id2 = id6[0..1]
    id4 = id6[2..-1]
    path = "/porter/mapped-ids/#{id2}/#{id4}**"
    ported_ids = Dir.glob(path)
    storer_ids = storer.katas_completed(id6)
    ported_ids.size + storer_ids.size == 1
  end

  def to_available?(id6)
    !saver.group_exists?(id6)
  end

  # - - - - - - - - - - - - - - - - - - -

  def remember_mapping(kata_id, id6)
    id2 = kata_id[0..1]
    id8 = kata_id[2..-1]
    dir = disk["/porter/mapped-ids/#{id2}"]
    dir.make
    dir.write(id8, id6)
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, avatar_name)
    index = Avatars_names.index(avatar_name)
    indexes = (0..63).to_a
    indexes.delete(index)
    indexes.unshift(index)
    saver.group_join(id, indexes)
  end

  # - - - - - - - - - - - - - - - - - - -

  Avatars_names =
    %w(alligator antelope     bat       bear
       bee       beetle       buffalo   butterfly
       cheetah   crab         deer      dolphin
       eagle     elephant     flamingo  fox
       frog      gopher       gorilla   heron
       hippo     hummingbird  hyena     jellyfish
       kangaroo  kingfisher   koala     leopard
       lion      lizard       lobster   moose
       mouse     ostrich      owl       panda
       parrot    peacock      penguin   porcupine
       puffin    rabbit       raccoon   ray
       rhino     salmon       seal      shark
       skunk     snake        spider    squid
       squirrel  starfish     swan      tiger
       toucan    tuna         turtle    vulture
       walrus    whale        wolf      zebra
    )

  # - - - - - - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

  def storer
    @externals.storer
  end

  def saver
    @externals.saver
  end

end
