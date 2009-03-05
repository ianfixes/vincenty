require 'test/unit'
require 'vincenty'

class TestVincenty< Test::Unit::TestCase

  def initialize(x)
    super(x)
    
    @path = [ #Path starting at peg by kanaka at end of drive 
       TrackAndDistance.new("215,3,0", 19.73 ) ,
       TrackAndDistance.new(Angle.new("320,14,10").reverse, 12.0), #Note don't need to add the radians=true argument as Angle has to_radians function
       TrackAndDistance.new(Angle.new("281,44,40").reverse, 35.23 ),
       TrackAndDistance.new(Angle.new("247,24,0").reverse, 40.23 ),
       TrackAndDistance.new(Angle.new("218,19,0").reverse, 378.98 ),
       TrackAndDistance.new(Angle.new("158,25,0").reverse, 128.39 ),
       TrackAndDistance.new(Angle.new("17,7,40").reverse, 122.41 ),
       TrackAndDistance.new(Angle.new("51,1,0").reverse, 288.89 ),
       TrackAndDistance.new("158,47,30", 61.78 ),
       TrackAndDistance.new("189,16,10", 26.26 ),
       TrackAndDistance.new("217,14,0", 21.87 ),
    ]

    @waypoints = [
        Vincenty.new(-36.9923293459124, 174.485341187381),
        Vincenty.new(-36.992412464006, 174.485427409127),
        Vincenty.new(-36.9924770796644, 174.485814875954),
        Vincenty.new(-36.9923377696042, 174.486232091137),
        Vincenty.new(-36.9896584018239, 174.488871503953),
        Vincenty.new(-36.988582616694, 174.488340992344),
        Vincenty.new(-36.9896367145752, 174.487936042043),
        Vincenty.new(-36.9912743090293, 174.48541348615),
        Vincenty.new(-36.9917932943506, 174.485664544705),
        Vincenty.new(-36.9920268289562, 174.485617028991),
        Vincenty.new(-36.9921837292671, 174.485468381511),
    ]  
  end

  #The path in @path was entered from the property survey map, with distance and bearings which should form a closed loop
  #verified on google map of my property by creating a KML file and loading the map over the satellite image and checking the
  #coordinates in google earth, and visually checking the route created was a closed loop (it was with a tiny error). 
  def test_vincenty_destination
    start = Vincenty.new(-36.9921838030711, 174.485468469841) 

    next_p = start
#    print "Start at coordinate #{next_p.longitude.to_d}, #{next_p.latitude.to_d}\n"
    @path.each_with_index do |leg,i|
      next_p, spherical_ans = next_p.destination( leg ) , next_p.sphereDestination(leg)
 
      assert_equal(@waypoints[i].longitude.to_d.round(12), next_p.longitude.to_d.round(12))
      assert_equal(@waypoints[i].latitude.to_d.round(12), next_p.latitude.to_d.round(12))
  #    print "Expect  #{waypoints[i].longitude.to_d.round(4)}, #{waypoints[i].latitude.to_d.round(4)}\n"
  #    print "Moved #{leg.bearing.to_d.round(4)} #{leg.distance.round(4)}m to #{next_p.longitude.to_d.round(4)}, #{next_p.latitude.to_d.round(4)}\n"
  #    print "Spherical #{leg.bearing.to_d.round(4)} #{leg.distance.round(4)}m to #{spherical_ans.longitude.to_d.round(4)}, #{spherical_ans.latitude.to_d.round(4)}\n"
  #    puts
    end
  #  assert_equal(0, next_p.distanceAndAngle(start).distance)
  #  puts "distance from end to start should be 0. Actual #{next_p.distanceAndAngle(start)}"
  end
  
  #The waypoints are the latitudes and longitudes of the corners of my property.
  #The resulting bearing and distances between them should match those in @path.
  def test_vincenty_distance_and_angle
    start = Vincenty.new(-36.9921838030711, 174.485468469841) 
    next_p = start
#   print "\nReverse test, c\n"
#    print "Start at coordinate #{next_p.longitude.to_d}, #{next_p.latitude.to_d}\n"
    @waypoints.each_with_index do |point,i|
      vtrack_and_bearing = next_p.distanceAndAngle( point ) 
  #    strack_and_bearing = next_p.sphericalDistanceAndAngle( point )
      
      assert_equal(@path[i].bearing.to_d.round(4), vtrack_and_bearing.bearing.to_d.round(4))
      assert_equal(@path[i].distance.round(4), vtrack_and_bearing.distance.round(4))
  #    print "Expected #{path[i].bearing.to_d.round(4)}(#{((path[i].bearing.to_d+180)%360).round(4)}), #{path[i].distance.round(4)}m\n"
  #    print "WGS-84 track #{vtrack_and_bearing.bearing.to_d.round(4)} #{vtrack_and_bearing.distance.round(4)}m from #{next_p.longitude.to_d.round(4)}, #{next_p.latitude.to_d.round(4)} to #{point.longitude.to_d.round(4)},  #{point.latitude.to_d.round(4)}\n"
  #    print "Spherical track #{strack_and_bearing.bearing.to_d.round(4)} #{strack_and_bearing.distance.round(4)}m from #{next_p.longitude.to_d.round(4)}, #{next_p.latitude.to_d.round(4)} to #{point.longitude.to_d.round(4)},  #{point.latitude.to_d.round(4)}\n"
  #    puts
      next_p = point
    end
  # assert_equal(0, next_p.distanceAndAngle(start).distance)
  #  puts "distance from end to start should be 0. Actual #{next_p.distanceAndAngle(start)}\n"
  end
  
  #Run the Australian Geoscience site example.
  def test_geoscience_au
    flindersPeak = Vincenty.new("-37°57'3.72030″", "144°25'29.52440″" )
    buninyong = Vincenty.new("-37 ° 39 ' 10.15610 ''", "143 ° 55 ' 35.38390 ''") #Buninyong
    track_and_bearing = flindersPeak.distanceAndAngle( buninyong ) 
    assert_equal(Angle.new("306 ° 52 ' 5.37 ''").to_d.round(4), track_and_bearing.bearing.to_d.round(4))
    assert_equal(54972.271, track_and_bearing.distance.round(3))
    
    destination = flindersPeak.destination(TrackAndDistance.new("306 ° 52 ' 5.37 ''", 54972.271))
    assert_equal(buninyong.latitude.to_d.round(4), destination.latitude.to_d.round(4))
    assert_equal(buninyong.longitude.to_d.round(4), destination.longitude.to_d.round(4))
  end
    
end