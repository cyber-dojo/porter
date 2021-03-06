require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E4', %w(
  port of id that does not exist on storer raises
  ) do
    id = '9k81d40123'
    error = assert_raises(RuntimeError) { port(id) }
    expected = "malformed:id: !storer.kata_exists?(#{id})"
    assert_equal expected, error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E2', %w(
  port of id that has already been ported returns the ported id
  ) do
    kata_ids = %w( 029CD5E9ED 029CD5A603 )
    kata_ids.each do |id|
      id6 = port(id)
      idempotent = port(id)
      assert_equal idempotent, id6
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '444', %w(
  after port of id which is unique in 1st 6 chars in storer,
  and the id6 is available in saver, then
  saver has saved the practice-session
  with an id equal to its original 1st 6 chars
  ) do
    kata_ids = %w(
      1F00C1BFC8
      5A0F824303
      420B05BA0A
    )
    kata_ids << '421F303E80' # 'revert_tag' in its increments
    kata_ids.each do |id10|
      assert_ports_with_matching_id(id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '445', %w(
  after port of id which is unique in 1st 6 chars in storer,
  but the id6 is _not_ available in saver, then
  saver has saved the practice-session
  with an id unequal to its original 1st 6 chars
  ) do
    kata_ids = %w(
      420F2A2979
      420BD5D5BE
      421AFD7EC5
    )
    kata_ids.each do |id10|
      manifest = storer.kata_manifest(id10)
      porter.update_manifest(manifest)
      id6 = id10[0..5]
      manifest['id'] = id6
      saver.group_create(manifest)
      assert saver.group_exists?(id6)
      assert_ports_with_different_id(id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '446', %w(
  after port of id that has more than one 6-char match in storer
  saver has saved the practice-session
  with an id unequal to its original 1st 6 chars
  and records the mapping in /porter/id_map.json
  ) do
    assert_matching_pair('463748'+'A0E8',
                         '463748'+'D943')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '447', %w(
  port of id with broken json raises
  ) do
    assert_raises(ServiceError) { port('4DFAC32630') }
    assert_raises(ServiceError) { port('4DxsSZpqTZ') }
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E1',
  'port of a big session' do
    assert_ports_with_matching_id('9fH6TumFV2')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E7',
  'port of newer sessions whose id includes l (ell, lowercase L)' do
    assert_ports_with_matching_id('9fcW44ltyz')
    assert_ports_with_matching_id('9fvMuUlKbh')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E3',
  'port of newer ids' do
    kata_ids = %w(
      9f67Q9PyZm
      9fDYJR3BfG
      9fSqUqMecK
      9fT2wMW0BM
      9fUSFm6hmT
    )
    kata_ids.each do |id10|
      assert_ports_with_matching_id(id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E9', %w(
  ids from 7E dir that initially failed to port
  because they have a display_name
  that was missing from storer's Updater.cache ) do
    kata_ids = [
      '7E010BE86C', # 'Java, JUnit-Mockito'
      '7E2AEE8E64', # 'Java, JUnit-Mockito'
      '7E9B1F7E60', # 'Scala, scalatest'
      '7E218AC28C', # 'Scala, scalatest'
      '7E6DEF1D86', # 'Scala, scalatest'
      '7EA354ED66', # 'Ruby, Approval'
      '7EC98B56F7', # 'Java, JUnit-Mockito'
      '7EA0979D3E', # 'Java, Approval'
      '7E246F2339', # 'C (gcc), Unity'
      '7E12E5A294', # 'C (gcc), Unity'
    ]
    kata_ids.each do |id10|
      assert_ports_with_matching_id(id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EA', %w(
  id from 7E dir that initially failed to port
  because in storer 'colour' used to be called 'outcome' ) do
    assert_ports_with_matching_id('7E53666BFE')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EC', %w(
  id from 7E dir that initially failed to port
  because it holds a bunch of now-dead diff/fork related properties
  which storer was not deleting
  ) do
    assert_ports_with_matching_id('7EBAEC5207')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EF', %w(
  id from 7E dir that initially failed to port
  because it is for (modern) custom start-points,
  whose manifest does contain an 'image_name'
  but does not contain a 'runner_choice',
    eg 'Java Countdown, Round 1',
  and storer was failing to cater for this
  ) do
    assert_ports_with_matching_id('7EC7A19DF3')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '944', %w(
  ids from 02 dir that initially failed to port
  because some avatars have no increments.json file
  ) do
    assert_ports_with_matching_id('020123D57E')
    assert_ports_with_matching_id('0237439B3C')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '945', %w(
  ids from 03 dir that initially failed to port
  because some increments.json files have 'time' field set to null
  ) do
    assert_ports_with_matching_id('03310BDE8F')
    assert_ports_with_matching_id('03A0F63283')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '946', %w(
  ids from 05 dir that initially failed to port
  because of more fields set to null
  ) do
    assert_ports_with_matching_id('05BF0BCE3C') # exercise:null
    assert_ports_with_matching_id('05E221728D') # stdout['content']:null
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '947', %w(
  ids from 89 dir have sandbox/ dirs owned by nobody and so storer.kata_delete()
  cannot fully delete, causing storer work-around with DELETED.marker file
  ) do
    kata_ids = %w(
      890C8AE514
      89716C1BC6
    )
    kata_ids.each do |kata_id|
      assert_ports_with_matching_id(kata_id)
      all89 = storer.katas_completions('89')
      refute all89.include?(kata_id[2..-1]), all89
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '948', %w(
  ids from 34 dir that initially failed to port
  because of dead 'name' manifest property
  which storer's Updater needed to strip out
  ) do
    kata_id = '346EF637B9' # red data-set
    assert_ports_with_matching_id(kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def assert_matching_pair(id1, id2)
    assert_equal id1[0..5], id2[0..5]
    dup = id1[0..5]
    assert_equal [id1,id2].sort, storer.katas_completed(dup).sort
    assert_ports_with_different_id(id1)
    assert_ports_with_different_id(id2)
  end

=begin
  test '120', %w(
  ids from 4D that initially failed to port
  ) do
    # "display_name" => "git, bash"
    assert_ports_with_matching_id('4D29143FE1')
  end
=end

end
