
require 'angle.rb'

#Subclass of Angle to add in special treatment of to_d, to_r , to_s
#Latitude degrees are between -PI and PI, South to North (+/- 90 degrees)

class Latitude < Angle
  
  #Returns angle as degrees in range -90 and 90
  def to_degrees
    degrees = super
    case
    when degrees > 270 ; -(360 - degrees)
    when degrees > 180 ; 180 - degrees
    when degrees > 90 ; 180 - degrees
    when degrees < -90 ; 180 - degrees
    else degrees
    end
  end
  
  #Returns: angle as degrees in range -PI and PI
  def to_radians
    case
    when @angle > 3*Math::PI/2 ;  @angle - Math::PI * 2
    when @angle > Math::PI ; Math::PI - @angle
    when @angle > Math::PI/2 ; Math::PI - @angle
    when @angle < -Math::PI/2 ; -Math::PI - @angle
    else @angle
    end
  end

  #Returns: angle as string in degrees minutes seconds direction.
  #A South angle is negative, North is Positive.
  def to_s(fmt="%2d %2m'%2.4s\"%N")
      super(fmt)
  end
  
  alias to_r to_radians
  alias to_d to_degrees

end