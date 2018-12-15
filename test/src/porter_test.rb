require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E4', %w(
  port of id that does not exist raises
  ) do
    id = '9k81d40123'
    error = assert_raises(RuntimeError) { port(id) }
    assert_equal "malformed:id:#{id} !exist", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E2', %w(
  port of id that has already been ported raises
  ) do
    id = '9f8TeZMZAq'
    port(id)
    error = assert_raises(RuntimeError) { port(id) }
    assert_equal "malformed:id:#{id} !exist", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E5', %w(
  after port of id which is unique in 1st 6 chars in storer,
  saver has saved the practice-session
  with an id equal to its original 1st 6 chars
  ) do
    Katas_old_ids.each do |id10|
      assert storer.kata_exists?(id10), id10
      id6 = id10[0..5]
      assert_equal [id10], storer.katas_completed(id6) # unique
      was = was_data(id10)
      refute saver.group_exists?(id6), id10

      gid = port(id10)

      assert_equal id6, gid, id10
      assert saver.group_exists?(gid), id10
      now = now_data(gid)
      refute storer.kata_exists?(id10), id10
      assert_ported(was, now, id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E6', %w(
  after port of id that has more than one 6-char match in storer
  saver has saved the practice-session
  with an id unequal to its original 1st 6 chars
  ) do
    id1 = '0BA7E1E01B'
    id2 = '0BA7E16149'

    assert storer.kata_exists?(id1), id1
    id6 = id1[0..5]
    assert_equal [id1,id2].sort, storer.katas_completed(id6).sort # not-unique
    was = was_data(id1)
    refute saver.group_exists?(id6), id1
    gid1 = port(id1)
    refute_equal id6, gid1, id1
    assert saver.group_exists?(gid1), id1
    now = now_data(gid1)
    refute storer.kata_exists?(id1), id1
    assert_ported(was, now, id1)

    assert storer.kata_exists?(id2), id2
    id6 = id2[0..5]
    assert_equal [id2].sort, storer.katas_completed(id6).sort # now unique in storer
    was = was_data(id2)
    refute saver.group_exists?(id6), id2
    gid2 = port(id2)
    refute_equal id6, gid2, id2
    assert saver.group_exists?(gid2), id2
    now = now_data(gid2)
    refute storer.kata_exists?(id2), id2
    assert_ported(was, now, id2)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E3', %w(
  port of newer ids some of which include l (ell, lowercase L)
  ) do
    Katas_new_ids.each do |id10|
      assert storer.kata_exists?(id10), id10
      id6 = id10[0..5]
      assert_equal [id10], storer.katas_completed(id6)
      was = was_data(id10)
      refute saver.group_exists?(id6), id10

      gid = port(id10)

      assert_equal id6, gid, id10
      assert saver.group_exists?(gid), id10
      now = now_data(gid)
      refute storer.kata_exists?(id10), id10
      assert_ported(was, now, id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test '1E7', %w(
  after port of id which is unique in 1st 7 chars in storer
  saver has saved the practice-session with a new id
  and you cannot access the new practice-sesssion with partial_id's 1st 6 chars
  ) do
    ids = {}
    katas_dup_ids = %w( 463748A0E8
                        463748D943 )
    katas_dup_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
      partial_id = kata_id[0..6]
      assert_equal 7, partial_id.size
      assert_equal [kata_id], storer.katas_completed(partial_id)
      was = was_data(kata_id)

      gid = port(partial_id)

      assert_equal 6, gid.size
      id6 = kata_id[0..5]
      refute_equal id6, gid, kata_id # new-id
      assert saver.group_exists?(gid), kata_id
      now = now_data(gid)
      refute storer.kata_exists?(kata_id)
      assert_ported(was, now, kata_id)
      ids[kata_id] = gid

      dup_id = kata_id[0..5]
      assert_equal 6, dup_id.size
      gid = port(dup_id)
      assert_equal '', gid, kata_id
    end
  end
=end

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
      '7E53732F00', # 'Clojure, .test'
    ]
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EA', %w(
  ids from 7E dir that initially failed to port
  because in storer 'colour' used to be called 'outcome' ) do
    kata_ids = %w(
      7E53666BFE
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EC', %w(
  ids from 7E dir that initially failed to port
  because they hold a bunch of now-dead diff/fork related properties
  which storer was not deleting
  ) do
    kata_ids = %w(
      7EBAEC5207
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EF', %w(
  ids from 7E dir that initially failed to port
  because they are for (modern) custom start-points,
  whose manifest does do contain an 'image_name'
  but do not contain a 'runner_choice',
    eg 'Java Countdown, Round 1',
  and storer failed to cater for this
  ) do
    kata_ids = %w(
      7EC7A19DF3
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '120', %w(
  ids from 4D that initially failed to port
  ) do
    # "display_name"=>"git, bash"
    assert_now_ported('4D29143FE1')
  end

  private

  # 421F303E80 has revert_tag entries in its increments
  Katas_old_ids = %w(
    1F00C1BFC8
    5A0F824303
    420B05BA0A
    420F2A2979
    421F303E80
    420BD5D5BE
    421AFD7EC5
  )

  Katas_new_ids = %w(
    9f67Q9PyZm
    9fcW44ltyz
    9fDYJR3BfG
    9fH6TumFV2
    9fSqUqMecK
    9fT2wMW0BM
    9fUSFm6hmT
    9fvMuUlKbh
  )

end
