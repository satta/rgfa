require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineGetters < Test::Unit::TestCase

  def test_headers
    h = ["H\tVN:Z:1.0"]
    assert_equal(h, h.to_rgfa.headers.map(&:to_s))
  end

  def test_each_header
    h1 = ["H\tVN:Z:1.0"]
    h2 = []
    gfa = h1.to_rgfa
    gfa.headers.each {|h| h2 << h.to_s}
    assert_equal(h1, h2)
  end

  def test_segments
    s = ["S\t1\t*","S\t2\t*"]
    gfa = s.to_rgfa
    assert_equal(s, gfa.segments.map(&:to_s))
    gfa.delete_segment("1")
    assert_equal([s[1]], gfa.segments.map(&:to_s))
  end

  def test_each_segment
    s1 = ["S\t1\t*","S\t2\t*"]
    s2 = []
    gfa = s1.to_rgfa
    gfa.segments.each {|s| s2 << s.to_s}
    assert_equal(s1, s2)
    gfa.delete_segment("1")
    s2 = []
    gfa.segments.each {|s| s2 << s.to_s}
    assert_equal([s1[1]], s2)
  end

  def test_links
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l = ["L\t1\t+\t2\t+\t12M", "L\t1\t+\t3\t+\t12M"]
    gfa = (s+l).to_rgfa
    assert_equal(l, gfa.links.map(&:to_s))
    gfa.unconnect_segments("1","2")
    assert_equal([l[1]], gfa.links.map(&:to_s))
  end

  def test_each_link
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l1 = ["L\t1\t+\t2\t+\t12M", "L\t1\t+\t3\t+\t12M"]
    gfa = (s+l1).to_rgfa
    l2 = []
    gfa.links.each {|l| l2 << l.to_s}
    assert_equal(l1, l2)
    gfa.unconnect_segments("1","2")
    l2 = []
    gfa.links.each {|l| l2 << l.to_s}
    assert_equal([l1[1]],l2)
  end

  def test_containments
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    c = ["C\t1\t+\t2\t+\t12\t12M", "C\t1\t+\t3\t+\t12\t12M"]
    gfa = (s+c).to_rgfa
    assert_equal(c, gfa.containments.map(&:to_s))
    gfa.unconnect_segments("1","2")
    assert_equal([c[1]], gfa.containments.map(&:to_s))
  end

  def test_each_containment
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    c1 = ["C\t1\t+\t2\t+\t12\t12M", "C\t1\t+\t3\t+\t12\t12M"]
    gfa = (s+c1).to_rgfa
    c2 = []
    gfa.containments.each {|c| c2 << c.to_s}
    assert_equal(c1, c2)
    gfa.unconnect_segments("1","2")
    c2 = []
    gfa.containments.each {|c| c2 << c.to_s}
    assert_equal([c1[1]], c2)
  end

  def test_paths
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l = ["L\t1\t+\t2\t+\t122M", "L\t1\t+\t3\t+\t120M"]
    pt = ["P\t4\t1+,2+\t122M", "P\t5\t1+,3+\t120M"]
    gfa = (s+l+pt).to_rgfa
    assert_equal(pt, gfa.paths.map(&:to_s))
    gfa.delete_path("4")
    assert_equal([pt[1]], gfa.paths.map(&:to_s))
  end

  def test_each_path
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l = ["L\t1\t+\t2\t+\t122M", "L\t1\t+\t3\t+\t120M"]
    pt1 = ["P\t4\t1+,2+\t122M", "P\t5\t1+,3+\t120M"]
    gfa = (s+l+pt1).to_rgfa
    pt2 = []
    gfa.paths.each {|pt| pt2 << pt.to_s}
    assert_equal(pt1, pt2)
    gfa.delete_path("4")
    pt2 = []
    gfa.paths.each {|pt| pt2 << pt.to_s}
    assert_equal([pt1[1]], pt2)
  end

  def test_segment
    s = ["S\t1\t*","S\t2\t*"]
    gfa = s.to_rgfa
    assert_equal(s[0],gfa.segment("1").to_s)
    assert_equal(s[0],gfa.segment!("1").to_s)
    assert_equal(nil,gfa.segment("0"))
    assert_raises(RGFA::LineMissingError) {gfa.segment!("0").to_s}
  end

  def test_path
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l = ["L\t1\t+\t2\t+\t122M", "L\t1\t+\t3\t+\t120M"]
    pt = ["P\t4\t1+,2+\t122M", "P\t5\t1+,3+\t120M"]
    gfa = (s+l+pt).to_rgfa
    assert_equal(pt[0],gfa.path("4").to_s)
    assert_equal(pt[0],gfa.path!("4").to_s)
    assert_equal(nil,gfa.path("6"))
    assert_raises(RGFA::LineMissingError) {gfa.path!("6").to_s}
  end

  def test_paths_with_segment
    gfa = RGFA.new
    s = (0..3).map{|i| "S\t#{i}\t*".to_rgfa_line}
    p = "P\t4\t2+,0-\t*"
    (s + [p]).each {|line| gfa << line }
    assert_equal([p], gfa.paths_with("0").map(&:to_s))
    assert_equal([p], gfa.paths_with("2").map(&:to_s))
    assert_equal([], gfa.paths_with("1").map(&:to_s))
  end

  def test_containing
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c = "C\t1\t+\t0\t+\t0\t*"
    gfa << c
    assert_equal([c], gfa.containing("0").map(&:to_s))
    assert_equal([],  gfa.containing("1"))
    assert_equal([],  gfa.containing("2"))
  end

  def test_contained_in
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c = "C\t1\t+\t0\t+\t0\t*"
    gfa << c
    assert_equal([],  gfa.contained_in("0"))
    assert_equal([c], gfa.contained_in("1").map(&:to_s))
    assert_equal([],  gfa.contained_in("2"))
  end

  def test_containments_between
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c1 = "C\t1\t+\t0\t+\t0\t*"
    c2 = "C\t1\t+\t0\t+\t12\t*"
    gfa << c1
    gfa << c2
    assert_equal([], gfa.containments_between("0", "1"))
    assert_equal([c1,c2], gfa.containments_between("1", "0").map(&:to_s))
  end

  def test_containment
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c1 = "C\t1\t+\t0\t+\t0\t*"
    c2 = "C\t1\t+\t0\t+\t12\t*"
    gfa << c1
    gfa << c2
    assert_equal(nil, gfa.containment("0", "1"))
    assert_raises(RGFA::LineMissingError) {gfa.containment!("0", "1")}
    assert_equal(c1, gfa.containment("1", "0").to_s)
    assert_equal(c1, gfa.containment!("1", "0").to_s)
  end

  def test_links_of
    gfa = RGFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t+\t*"; gfa << l0
    l1 = "L\t0\t+\t1\t+\t*"; gfa << l1
    l2 = "L\t1\t+\t3\t+\t*"; gfa << l2
    assert_equal([],         gfa.links_of(["0", :B]).map(&:to_s))
    assert_equal([l1],       gfa.links_of(["0", :E]).map(&:to_s))
    assert_equal([l1],       gfa.links_of(["1", :B]).map(&:to_s))
    assert_equal([l0,l2],    gfa.links_of(["1", :E]).map(&:to_s))
    assert_equal([l0],       gfa.links_of(["2", :B]).map(&:to_s))
    assert_equal([],         gfa.links_of(["2", :E]).map(&:to_s))
    assert_equal([l2],       gfa.links_of(["3", :B]).map(&:to_s))
    assert_equal([],         gfa.links_of(["3", :E]).map(&:to_s))
    gfa = RGFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t-\t*"; gfa << l0
    l1 = "L\t0\t+\t1\t-\t*"; gfa << l1
    l2 = "L\t1\t-\t3\t+\t*"; gfa << l2
    assert_equal([],         gfa.links_of(["0", :B]).map(&:to_s))
    assert_equal([l1],       gfa.links_of(["0", :E]).map(&:to_s))
    assert_equal([l2],       gfa.links_of(["1", :B]).map(&:to_s))
    assert_equal([l0,l1],    gfa.links_of(["1", :E]).map(&:to_s))
    assert_equal([],         gfa.links_of(["2", :B]).map(&:to_s))
    assert_equal([l0],       gfa.links_of(["2", :E]).map(&:to_s))
    assert_equal([l2],       gfa.links_of(["3", :B]).map(&:to_s))
    assert_equal([],         gfa.links_of(["3", :E]).map(&:to_s))
  end

  def test_links_between
    gfa = RGFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t+\t11M1D3M"; gfa << l0
    l1 = "L\t1\t+\t2\t+\t10M2D3M"; gfa << l1
    l2 = "L\t1\t+\t3\t+\t*"; gfa << l2
    assert_equal([l0, l1], gfa.links_between(["1", :E], ["2", :B]).map(&:to_s))
    assert_equal([], gfa.links_between(["1", :E], ["2", :E]).map(&:to_s))
  end

  def test_link
    gfa = RGFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t+\t11M1D3M"; gfa << l0
    l1 = "L\t1\t+\t2\t+\t10M2D3M"; gfa << l1
    l2 = "L\t1\t+\t3\t+\t*"; gfa << l2
    assert_equal(l0, gfa.link(["1", :E], ["2", :B]).to_s)
    assert_equal(l0, gfa.link!(["1", :E], ["2", :B]).to_s)
    assert_equal(nil, gfa.link(["1", :E], ["2", :E]))
    assert_raise(RGFA::LineMissingError) { gfa.link!(["1", :E], ["2", :E]) }
  end

  def test_header_tags
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    gfa << "H\taa:i:12\tab:Z:test1"
    gfa << "H\taa:i:15"
    gfa << "H\tac:Z:test2"
    assert_equal([[:VN, :Z, "1.0"],
                 [:aa, :i, 12],
                 [:aa, :i, 15],
                 [:ab, :Z, "test1"],
                 [:ac, :Z, "test2"]].sort,
                 gfa.header.tags.sort)
  end

end
