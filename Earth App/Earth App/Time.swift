//
//  Time.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 27/11/2020.
//

import UIKit

class Time{
    
    var longitude:Float = 0.0
    var delta:Float = 0.0
    var lambda:Double = 0.0
    var moonLongitude:Float = 0.0
    var moonDelta: Float = 0.0
    var moonDistance: Float = 0.0
    
    init(){
        //Converting deg to radians
        let toRadians:Double = Double.pi/180
        //Converting radians to deg
        let toDegrees:Double = 180/Double.pi
        
        //Calendar
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        //year
        let y:Int = Int(calendar.component(.year, from: Date()))
        //month
        let m:Int = Int(calendar.component(.month, from: Date()))
        //day
        let day:Int = Int(calendar.component(.day, from: Date()))
        //hour
        let h:Int = Int(calendar.component(.hour, from: Date()))
        //minutes
        let mins:Int = Int(calendar.component(.minute, from: Date()))
        //seconds
        let seconds:Int = Int(calendar.component(.second, from: Date()))
        
        //Computing Greenwich Hour Angle (GHA(longitude = 0) = Angle from the longitude of the sun on Earth to the Greenwich meridian)
        //Negative hour angles (-180 < LHA(0°) < 0) indicate the object is approaching the meridian, positive hour angles (0 < LHA(0°) < 180) indicate the object is moving away from the meridian; an hour angle of zero means the object is on the meridian.
        //So when the meridian
        //Computing J2000 day
        //Formulas from http://www2.arnes.si/~gljsentvid10/sidereal.htm
        //whole part
        //dwhole =367*y-INT(7*(y+INT((m+9)/12))/4)+INT(275*m/9)+day-730531.5
        //In swift : Int(1.5)/1 = Int(1.5/1) so we can remove the Int because our variables are already Int
        let dwhole:Double = Double(367*y - 7*(y+(m+9)/12)/4 + 275*m/9+day)-Double(730531.5)
        //fractional part
        //dfrac = (h + mins/60 + seconds/3600)/24
        let dfrac:Double = Double((Float(h)+Float(mins)/60+Float(seconds)/3600) / 24)
        //days since J2000
        var d:Double = dwhole + dfrac
        //GMST
        //GMST = 280.46061837 + 360.98564736629 * d
        var GMST: Double = 280.46061837 + 360.98564736629 * d
        GMST = GMST.truncatingRemainder(dividingBy: 360)
        
        //Formulas from https://en.wikipedia.org/wiki/Position_of_the_Sun
        //mean longitude sun
        var Ls:Double = 280.460 + 0.9856474*d
        Ls = Ls.truncatingRemainder(dividingBy: 360)
        //mean anomaly of the sun
        var Ms:Double = 357.528 + 0.9856003*d
        Ms = Ms.truncatingRemainder(dividingBy: 360)
        //Ecliptic longitude of the sun
        lambda = Ls + 1.915*sin(Ms*toRadians)+0.020*sin(2*Ms*toDegrees)
        //Obliquity of the ecliptic
        //Linear approximation
        let epsilon: Double = 23.439-0.0000004*d
        //Sun right ascension at the right quadrant
        var alpha: Double = toDegrees*atan2(cos(epsilon*toRadians)*sin(lambda*toRadians),cos(lambda*toRadians))
        alpha = alpha.truncatingRemainder(dividingBy: 360)
        
        //Formula from https://en.wikipedia.org/wiki/Hour_angle
        //LONGITUDE
        longitude = Float(GMST - alpha)
        longitude = longitude.truncatingRemainder(dividingBy: 360)
        //Computing sun's DECLINATION
        delta = Float(asin(sin(epsilon*toRadians)*sin(lambda*toRadians)))
        
        //print(delta*180.0/Float.pi)
        //print(longitude)
        //moon

        //Formulas from http://www.stargazing.net/kepler/moon2.html
        
        //Get the days to Dec 31st 0h 2000 - note, this is NOT same as J2000
        d = d + 1.5
        
        //Moon elements
        // longitude of the ascending node
        var N = 125.1228 - 0.0529538083 * d
        N = N.truncatingRemainder(dividingBy: 360)
        N = range(x: N)
        N = N * toRadians
        
        // inclination to the ecliptic (plane of the Earth's orbit)
        var i = 5.1454
        i = i * toRadians
        // argument of perihelion
        var w = 318.0634 + 0.1643573223 * d
        w = w.truncatingRemainder(dividingBy: 360)
        w = w * toRadians
        // semi-major axis, or mean distance from Sun
        let a = 60.2666 // (Earth radii)
        // eccentricity (0=circle, 0-1=ellipse, 1=parabola)
        let e = 0.0549
        // mean anomaly (0 at perihelion; increases uniformly with time)
        var M = 115.3654 + 13.0649929509 * d // have to be normalized
        M = M.truncatingRemainder(dividingBy: 360)
        M = M * toRadians
        // eccentric anomaly
        let E = M + e * sin(M) * (1.0 + e * cos(M))
        let xv = a * (cos(E) - e)
        let yv = a * (sqrt(1.0 - e*e) * sin(E))
        // true anomaly (angle between position and perihelion)
        let v = atan2(yv, xv)
        var r = sqrt(xv * xv + yv * yv)
        // geocentric ecliptical position
        let xh = r * (cos(N) * cos(v + w) - sin(N) * sin(v + w) * cos(i))
        let yh = r * (sin(N) * cos(v + w) + cos(N) * sin(v + w) * cos(i))
        let zh = r * (sin(v + w) * sin(i))
        //moons geocentric long and lat
        
        var lon = atan2(yh,xh)
        var lat = atan2(zh, sqrt(xh * xh + yh * yh))
        
        Ms = Ms*toRadians //Mean Anomaly of the Sun
        Ls = Ls*toRadians //Mean Longitude of the Sun
        let Lm = M + w + N //Mean longitude of the Moon
        let dm = Lm - Ls //Mean elongation of the Moon
        let F = Lm - N //Argument of latitude for the Moon
        
        
        //then add the following terms to the longitude
        //note amplitudes are in degrees, convert at end
        var dlon = -1.274 * sin(M - 2 * dm)
        dlon = dlon + 0.658 * sin(2 * dm)        //(the Variation)
        dlon = dlon - 0.186 * sin(Ms)            //(the Yearly Equation)
        dlon = dlon - 0.059 * sin(2 * M - 2 * dm)
        dlon = dlon - 0.057 * sin(M - 2 * dm + Ms)
        dlon = dlon + 0.053 * sin(M + 2 * dm)
        dlon = dlon + 0.046 * sin(2 * dm - Ms)
        dlon = dlon + 0.041 * sin(M - Ms)
        dlon = dlon - 0.035 * sin(dm)            //(the Parallactic Equation)
        dlon = dlon - 0.031 * sin(M + Ms)
        dlon = dlon - 0.015 * sin(2 * F - 2 * dm)
        dlon = dlon + 0.011 * sin(M - 4 * dm)
        lon = dlon * toRadians + lon
        
        //latitude terms
        var dlat = -0.173 * sin(F - 2 * dm)
        dlat = dlat - 0.055 * sin(M - F - 2 * dm)
        dlat = dlat - 0.046 * sin(M + F - 2 * dm)
        dlat = dlat + 0.033 * sin(F + 2 * dm)
        dlat = dlat + 0.017 * sin(2 * M + F)
        lat = dlat * toRadians + lat
        
        //distance terms earth radii
        r = r - 0.58 * cos(M - 2 * dm)
        r = r - 0.46 * cos(2 * dm)
        moonDistance = Float(r)
        
        //find the cartesian coordinates of the geocentric lunar position
        let xg = r * cos(lon) * cos(lat)
        let yg = r * sin(lon) * cos(lat)
        let zg = r * sin(lat)
        
        // equatorial coordinates
        let xe = xg
        let ye = yg * cos(epsilon*toRadians) - zg * sin(epsilon*toRadians)
        let ze = yg * sin(epsilon*toRadians) + zg * cos(epsilon*toRadians)
        //right scension
        var moonRA = atan2(ye, xe)
        moonRA = moonRA*toDegrees
        // declination
        var moonDeltaDouble = atan(ze / sqrt(xe * xe + ye * ye))
        moonDeltaDouble = moonDeltaDouble*toDegrees
        // geocentric distance
        moonDelta = Float(moonDeltaDouble)
        moonLongitude = Float(moonRA-alpha)
        moonLongitude = moonLongitude.truncatingRemainder(dividingBy: 360)
        moonLongitude = range(x: moonLongitude)
        
    }
   
    
    /**
    Returns the moon's distance to the Earth
     */
    func getMoonDistance() -> Float{
        return moonDistance
    }
    
    /**
    Returns the LHA of the sun in deg
     */
    func getLongitude() -> Float{
        return longitude
    }
    
    /**
    returns the sun's declination in rad
     */
    func getDelta() -> Float{
        return delta
    }
    
    /**
    returns the ecliptic longitude of the sun in deg
     */
    func getLambda() -> Float{
        return Float(lambda)
    }
    
    /**
    returns the LHA of the moon in deg
     */
    func getMoonLongitude() -> Float{
        return moonLongitude
    }
    
    /**
    returns the declination of the moon in deg
     */
    func getMoonDelta() -> Float{
        return moonDelta
    }
    

    func range(x: Double) -> Double{
        if x >= 0 {
            return x
        }
        else {
            return range(x: x + 360)
        }
    }
    
    func range(x: Float) -> Float{
        if x >= 0 {
            return x
        }
        else {
            return range(x: x + 360)
        }
    }
    
}



