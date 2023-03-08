//
//  ViewController.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 19/11/2020.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import SpriteKit

let segments:Int = 36 ///360/n=deg
let anisotropy = 1.0
let fov: Float = 17.0 //Geosynchronous satellites FOV
let realHalfFOV: Float = sin(fov.toRadians()/2.0)

class ViewController: UIViewController {
    
    let sunOrbit = SCNNode()
    var sun = SunNode()
    var earth = EarthNode()
    let moon = MoonNode()
    let glare = SunGlare()
    var cameraOrbit = SCNNode()
    let cameraNode = SCNNode()
    var sceneView: SCNView?
    var time: Time?
    var scene: SCNScene?
    
    let panModifier = 200
    let pinchModifier = 20
    
    let MaxZoomOut: Float = 60.0 //about moon distance
    let MaxZoomIn: Float = 1.07
    
    //Initial camera Distance to center of scene
    let earthCameraRadius: Float = AtmosphereRadius/realHalfFOV
    
    let moonCameraRadius: Float = moonRadius/realHalfFOV
    
    var referenceCameraRadius: Float = 0
    
    var referenceRadius: Float = earthRadius
    
    let minimum_exposure = -2.0
    let maximum_exposure = 6.0
    
    let sunDistance: Float = 23481
    
    var displayLink: CADisplayLink? // for real time rendering
    
    var sunVisible = false
    
    var sunThroughAtm = false
    
    var onSun = false
    
    let animationDuration = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.time = Time()
        
        referenceCameraRadius = earthCameraRadius
        //Star Angle, ecliptic angle of the sun, for the starmap background
        //Scene will be rotated by that angle in the end, to match current stars and milky way
        // PI/2 is because the skybox is rotated by PI/2 initially (IDK why...)
        let starAngle = -(time?.getLambda())!+Float.pi/2
        
        
        // CREATING THE SCENE
        scene = SCNScene()
        
        // CREATING THE EARTH
        earth.name = "earth"
        // ADJUSTING EARTH'S POSITION TO MATCH CURRENT DATE AND TIME
        earth.eulerAngles.y = (time?.getLongitude())!
        
        moon.name = "moon"
        
        // MOON DISTANCE TO THE EARTH
        moon.position = SCNVector3(x: 0, y: 0,z: Float((time?.getMoonDistance())!))
        // MOON ORIENTATION TO THE EARTH
        moon.eulerAngles.y = Float.pi
        
        //Calculating Moonlight intensity depending on lunar phase
        // sun / moon = 380,000
        // order of magnitude 10^0, I put 10^1 for amplified effect, otherwise too low
        let maxMoonIntensity: Double = 10
        //Calculate intensity multiple depending on angle
        //Transform [0->180->360] to [0->1->0]
        let moonIF: Double = (Double.pi-abs((Double((time?.getMoonLongitude())!)-Double.pi)))/Double.pi
        //A pretty good approximation is to say the intensity of light is equal to the angle on the moon's orbit to the power of 3.60-3.70. Centered on the full moon. We take 3 to keep it simple and a little brighter than real, so we can see better.
        //see https://www.researchgate.net/profile/Laszlo-Nowinszky/publication/230095239_The_effect_of_the_moon_phases_and_of_the_intensity_of_polarized_moonlight_on_the_light-trap_catches/links/5a5dc23eaca272d4a3de916f/The-effect-of-the-moon-phases-and-of-the-intensity-of-polarized-moonlight-on-the-light-trap-catches.pdf
        //and http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?bibcode=1966JRASC..60..221E&db_key=AST&page_ind=0&plate_select=NO&data_type=GIF&type=SCREEN_GIF&classic=YES
        
        let moonLight = SCNNode()
        moonLight.light = SCNLight()
        moonLight.light?.categoryBitMask = LightType.earth
        moonLight.light?.intensity = CGFloat(maxMoonIntensity * moonIF*moonIF*moonIF)
        moonLight.light?.type = .directional
        //https://physics.stackexchange.com/questions/244922/why-does-moonlight-have-a-lower-color-temperature
        moonLight.light?.temperature = 4100 //"Moonlight has a color temperature of 4100K"
        
        // changing/swapping the intensity multiple for the earth light
        let earthIF = 1.0 - moonIF
        
        let maxEarthIntensity: Double = 100
        
        let earthLight = SCNNode()
        earthLight.light = SCNLight()
        earthLight.light?.categoryBitMask = LightType.moon
        earthLight.light?.intensity = CGFloat(maxEarthIntensity * earthIF*earthIF*earthIF)
        earthLight.light?.type = .directional
        earthLight.eulerAngles.y = Float.pi
        earthLight.light?.temperature = 10000 //blueish tint from the blue color of earth
        
        
        
        let moonOrbit = SCNNode()
        moonOrbit.addChildNode(moon)
        moonOrbit.addChildNode(moonLight)
        moonOrbit.addChildNode(earthLight)
        moonOrbit.eulerAngles.y = (time?.getMoonLongitude())!
        moonOrbit.eulerAngles.x = -(time?.getMoonDelta())!
        //moonOrbit.eulerAngles.x = -(time?.getDelta())! //to test eclipses
        
        // CREATING THE SUN
        sun.name = "sun"
        glare.name = "glare"
        
        // SUN ORIENTATION
        sun.eulerAngles.y = Float.pi
        glare.eulerAngles.y = Float.pi
        
        // SUN DISTANCE TO EARTH
        sun.position = SCNVector3(x: 0,y: 0,z: sunDistance)
        glare.position = SCNVector3(x: 0,y: 0,z: -sunDistance)
        
        // SUNLIGHT
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.categoryBitMask = LightType.sunlight
        sunLight.light?.type = .directional
        sunLight.light?.temperature = 5772 //https://en.wikipedia.org/wiki/Sun
        // sun / moon = 380,000
        //order of magnitude about 10^5, 10^6 is burned
        sunLight.light?.intensity = 100000
        sunLight.position = SCNVector3(x: 0,y: 0,z: 0)
        
        // CAMERA
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.wantsExposureAdaptation = true
        // BLOOM (disabled because effect is an ugly ass small white square)
//        cameraNode.camera?.bloomIntensity = 100
//        cameraNode.camera?.bloomThreshold = 100
//        cameraNode.camera?.bloomBlurRadius = 100
        cameraNode.camera?.exposureAdaptationDarkeningSpeedFactor = 1000
        cameraNode.camera?.exposureAdaptationBrighteningSpeedFactor = 1000
        cameraNode.camera?.exposureOffset = minimum_exposure
        cameraNode.camera?.minimumExposure = minimum_exposure //default -15
        cameraNode.camera?.maximumExposure = maximum_exposure //default 15
        cameraNode.camera?.whitePoint = 10 //default 1
        cameraNode.camera?.fieldOfView = CGFloat(fov)
        cameraNode.camera?.projectionDirection = .horizontal
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 30000
        cameraNode.position = SCNVector3(x: 0, y: 0, z: referenceCameraRadius)
        cameraOrbit.addChildNode(cameraNode)
        
        sunOrbit.addChildNode(sun)
        sunOrbit.addChildNode(glare)
        sunOrbit.addChildNode(sunLight)
        sunOrbit.addChildNode(cameraOrbit)
        sunOrbit.eulerAngles.x = -(time?.getDelta())!
        
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.categoryBitMask = LightType.sunlight
        ambient.light?.temperature = 4100 //https://bigthink.com/13-8/average-star/
        ambient.light?.intensity = maxMoonIntensity/10 //star light is 1/300th of the full moon source vsauce https://www.youtube.com/watch?v=rltpH6ck2Kc but we take about 10x so that we can see some ambient light

        // ADDING SCENE ELEMENTS
        self.scene?.rootNode.addChildNode(ambient)
        self.scene?.rootNode.addChildNode(moonOrbit)
        self.scene?.rootNode.addChildNode(sunOrbit)
        self.scene?.rootNode.addChildNode(earth)

        scene?.background.contents = UIImage(named: "starmap")
        scene?.background.contentsTransform = SCNMatrix4MakeRotation(starAngle, 0, 1, 0)
        scene?.background.mipFilter = .linear
        scene?.background.maxAnisotropy = anisotropy
        scene?.background.intensity = 0.1
        scene?.lightingEnvironment.maxAnisotropy = anisotropy
        
        // VIEW SCENE
        sceneView = view as! SCNView?
        sceneView?.scene = scene
        
        sceneView?.allowsCameraControl = false
        sceneView?.showsStatistics = true
        sceneView?.antialiasingMode = .none
        sceneView?.rendersContinuously = false
        sceneView?.autoenablesDefaultLighting = false
        sceneView?.backgroundColor = UIColor.black
        
        // TAP GESTURE
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView!.addGestureRecognizer(tapGesture)
        
        // PAN GESTURE
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView!.addGestureRecognizer(panGesture)
        
        // PINCH GESTURE
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView!.addGestureRecognizer(pinchGesture)
        
        // LOOP
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .default)
        
        // Add observer for UIApplicationDidBecomeActive notification
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    @objc func applicationDidBecomeActive() {
        // Update the Earth's position
        updateScene()
        print("refresh")
    }
    
    func updateScene() {
        self.time = Time()
        earth.eulerAngles.y = (time?.getLongitude())!
        
        // CLOUDS
        let clouds_url = URL(string: "https://view.eumetsat.int/geoserver/ows?service=WMS&request=GetMap&version=1.3.0&layers=mumi:worldcloudmap_ir108&styles=&format=image/png&crs=EPSG:4326&bbox=-90,-180,90,180&width=4096&height=2048")! /// max allowed size 6688x3344
        
        let clouds_task = URLSession.shared.dataTask(with: clouds_url) { data, response, error in
            guard let data = data, error == nil else { return }
            let cloudsRaw = UIImage(data: data)!.replaceColor(UIColor.white, with: UIColor.darkGray)
            let cloudsFinal = cloudsRaw.modifyContrastAndInvert(value: 2, context: myContext) /// 1.13  2.2 see line.

            let cloudsNormal = cloudsRaw.makeNormal(context: myContext)
            
            DispatchQueue.main.async { // execute on main thread
                
                for childNode in self.earth.childNodes {
                    if childNode.name == "clouds" {
                        childNode.geometry?.firstMaterial?.transparent.contents = cloudsFinal
                        childNode.geometry?.firstMaterial?.normal.contents = cloudsNormal
                    }
                }
                
            }
        }
        clouds_task.resume()
        
        // AURORA
        let aurora_url = URL(string: "https://services.swpc.noaa.gov/json/ovation_aurora_latest.json")
        let aurora_task = URLSession.shared.dataTask(with: aurora_url!) { data, response, error in
            
            guard let data = data, error == nil else { return }
        
            var contents = String(data: data, encoding: .utf8)
            contents = contents!.substring(fromIndex: 150)
            contents = contents!.filter("-0123456789,".contains)
            let stringArray = contents!.components(separatedBy: ",")
            let pixels = makePixelsFromData(stringArray: stringArray)
            let auroraTexture = UIImage(pixels: pixels, width: 360, height: 181)
            
            DispatchQueue.main.async() { // execute on main thread
                for childNode in self.earth.childNodes {
                    if childNode.name == "aurora" {
                        childNode.geometry?.firstMaterial?.emission.contents = auroraTexture
                        childNode.geometry?.firstMaterial?.transparent.contents = auroraTexture
                        childNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                    }
                }
            }
        }
        aurora_task.resume()
        
    }
    
    @objc func update() {
        adjust_exposure_glare()
    }
    
    func adjust_exposure_glare(){
        // CHECKING IF THE SUN IS IN THE CAMERA FRUSTUM
        let newSunVisible = sceneView!.isNode(sun, insideFrustumOf: cameraNode) && is_sun_visible()
        if newSunVisible != sunVisible {
            sunVisible = newSunVisible
            
            // TOGGLE GLARE
            glare_toggle()
            
            // MANAGE EXPOSURE WHEN LOOKING AT THE SUN OR NOT
//            if sunVisible {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 1.0
//                cameraNode.camera?.maximumExposure = minimum_exposure
//                glare.geometry?.firstMaterial?.emission.intensity = 100
//                SCNTransaction.commit()
//            } else {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 1.0
//                cameraNode.camera?.maximumExposure = maximum_exposure
//                glare.geometry?.firstMaterial?.emission.intensity = 1
//                SCNTransaction.commit()
//            }
            
        }
    }
    
    func glare_toggle(){
        glare.position.z = -glare.position.z
    }
    
    func adjust_sun_shader(){
        let newSunThroughAtm = is_sun_through_atm()
        if newSunThroughAtm != sunThroughAtm {
            sunThroughAtm = newSunThroughAtm
            if sunThroughAtm {
                sun.geometry?.firstMaterial?.shaderModifiers = [.surface: sunSurfaceShader]
                glare.geometry?.firstMaterial?.shaderModifiers = [.surface: sunSurfaceShader]
                glare.renderingOrder = 0
            } else {
                sun.geometry?.firstMaterial?.shaderModifiers = nil
                glare.geometry?.firstMaterial?.shaderModifiers = nil
                glare.renderingOrder = 100
            }
        }
        
    }

    func is_sun_visible() -> Bool {
        let cameraOrbitPosition = cameraOrbit.position
        let cameraNodePosition = cameraOrbit.convertPosition(cameraNode.position, to: sunOrbit)
        let x = cameraNodePosition.x - cameraOrbitPosition.x
        let y = cameraNodePosition.y - cameraOrbitPosition.y
        return x * x + y * y > referenceRadius * referenceRadius
    }

    
    func is_sun_visible_pixels() -> Bool {
        // Get the bounding box of the sun's node
        let sunBoundingBox = sun.boundingBox

        // Convert the corners of the bounding box to screen space
        let min = sceneView?.projectPoint(sunBoundingBox.min)
        let max = sceneView?.projectPoint(sunBoundingBox.max)

        // Get the visible portion of the screen
        let visibleRect = CGRect(origin: CGPoint.zero, size: (sceneView?.bounds.size)!)

        // Check if the bounding box intersects with the visible portion of the screen
        let intersects = visibleRect.intersects(CGRect(origin: CGPoint(x: Double((min?.x)!), y: Double((min?.y)!)), size: CGSize(width: Double((max?.x)! - (min?.x)!), height: Double((max?.y)! - (min?.y)!))))
        
        return intersects
    }
    
    func is_sun_through_atm() -> Bool {
        let position = cameraNode.convertPosition(cameraNode.position, from: sunOrbit)
        return position.x*position.x+position.y*position.y < AtmosphereRadius*AtmosphereRadius
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let factor = Float(cameraNode.position.z/referenceCameraRadius)

        let translation = recognizer.velocity(in: recognizer.view)
        
        var yAngle = cameraOrbit.eulerAngles.y - Float(translation.x/CGFloat(panModifier)).toRadians()*factor
        let xAngle = cameraOrbit.eulerAngles.x - Float(translation.y/CGFloat(panModifier)).toRadians()*factor
        
        if abs(yAngle) > Float.pi {
            yAngle -= yAngle.sign()*2*Float.pi
        }
        cameraOrbit.eulerAngles.y = yAngle
        //Prevent from putting th camera upside down by rotating past the north and south pole
        if xAngle > -Float.pi/2 && xAngle < Float.pi/2 {
            cameraOrbit.eulerAngles.x = xAngle
        }
    }
    
    @objc func handleDoublePan(_ recognizer: UIPanGestureRecognizer) {
        let factor = Float(1.0)
        
        let translation = recognizer.velocity(in: recognizer.view)
        var yAngle = cameraNode.eulerAngles.y + Float(translation.x/CGFloat(panModifier)).toRadians()*factor
        let xAngle = cameraNode.eulerAngles.x + Float(translation.y/CGFloat(panModifier)).toRadians()*factor
        if abs(yAngle) > Float.pi {
            yAngle -= yAngle.sign()*2*Float.pi
        }
        cameraNode.eulerAngles.y = yAngle
        cameraNode.eulerAngles.x = xAngle
    }
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        let scale = recognizer.velocity
        let factor = Float(cameraNode.position.z/referenceCameraRadius)
        //let factor = Float(1.0)
        let z = cameraNode.position.z - Float(scale)/Float(pinchModifier)*factor
        if z < MaxZoomOut, z > MaxZoomIn {
            cameraNode.position.z = z
        }
    }
    
    func resetCameraOrientation(){
        cameraNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        let hits = sceneView!.hitTest(location, options: nil)
        
        let delta = (time?.getDelta())!
        
        if ((hits.first?.node) != nil) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = animationDuration
            resetCameraOrientation()
            SCNTransaction.commit()
            let node = hits.first?.node
            if (node?.name == "glare" || node?.name == "sun") && !onSun || node?.name == "sun" {
                onSun = true
                referenceRadius = 0 ///large value
                let distanceToSun: Float = sunRadius/tan(realHalfFOV)
                let travelDistance = sunDistance-distanceToSun
                SCNTransaction.begin()
                SCNTransaction.animationDuration = animationDuration
                glare.opacity = 0
                travel_to_sun(travelDistance: travelDistance, delta: delta, reference: "ecliptic")
                cameraOrbit.position.x = 0
                cameraOrbit.eulerAngles.y = cameraOrbit.eulerAngles.y.sign()*Float.pi
                SCNTransaction.commit()
                
            } else if node?.name == "moon" {
                referenceCameraRadius = moonCameraRadius
                referenceRadius = moonRadius
                SCNTransaction.begin()
                SCNTransaction.animationDuration = animationDuration
                let moonWorldPosition = node?.worldPosition
                let moonPositionInSunOrbit = sunOrbit.convertPosition(moonWorldPosition!, from: nil)
                cameraOrbit.position = moonPositionInSunOrbit
                cameraNode.position.z = referenceCameraRadius
                SCNTransaction.commit()
            } else if node?.parent?.name == "earth" {
                referenceCameraRadius = earthCameraRadius
                referenceRadius = earthRadius
                SCNTransaction.begin()
                SCNTransaction.animationDuration = animationDuration
                cameraOrbit.position = SCNVector3(x: 0, y: 0, z: 0)
                cameraNode.position.z = referenceCameraRadius
                SCNTransaction.commit()
                
            } else if node?.name != "sun" && onSun {
                sun_to_earth(delta: delta)
            } }
        else if onSun {
                sun_to_earth(delta: delta)
        
        }
        
    }
    
    func travel_to_sun(travelDistance: Float, delta: Float, reference: String){
        switch reference {
        case "equator":
            cameraOrbit.position.z = travelDistance*cos(delta)
            cameraOrbit.position.y = travelDistance*sin(delta)
            cameraOrbit.eulerAngles.x = delta
            break
        case "ecliptic":
            cameraOrbit.position.z = travelDistance
            cameraOrbit.position.y = 0.0
            cameraOrbit.eulerAngles.x = 0.0
            break
        default:
            print("no referenced case")
        }
    }
    
    func sun_to_earth(delta: Float){
        onSun = false
        glare.opacity = 1
        referenceCameraRadius = earthCameraRadius
        referenceRadius = earthRadius
        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        cameraOrbit.eulerAngles.y = 0
        //cameraOrbit.eulerAngles.x = -delta
        
        cameraNode.position.z = referenceCameraRadius
        
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = self.animationDuration
            self.cameraOrbit.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
            SCNTransaction.commit()
        }
        
        SCNTransaction.commit()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    deinit {
        displayLink?.invalidate()
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
}
        
        //    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //        // Get the view's current post-processing stack, or create one if none exists
        //
        //
        //        // Create a bloom filter and configure its parameters
        //        let bloomFilter = CIFilter(name: "CIBloom")!
        //        bloomFilter.setValue(5.0, forKey: "inputIntensity")
        //        bloomFilter.setValue(1.0, forKey: "inputRadius")
        //
        //        // Add the bloom filter to the post-processing stack for the view
        //        sceneView?.layer.filters = [bloomFilter]
        //    }
        
        //let atmosphereShader = SCNProgram()
        //atmosphereShader.vertexShader = "SkyFromSpaceVert.vert"
        //atmosphereShader.fragmentShader = "SkyFromSpaceFrag.frag"
        //self.scene?.rootNode.geometry?.firstMaterial?.program = atmosphereShader
        
        // tap recognizer
        //        let tapRecognizer = UITapGestureRecognizer()
        //            tapRecognizer.numberOfTapsRequired = 1
        //            tapRecognizer.numberOfTouchesRequired = 1
        //        tapRecognizer.addTarget(self, action: Selector(("sceneTapped:")))
        //            sceneView?.gestureRecognizers = [tapRecognizer]
        
    
    //    func sceneTapped(recognizer: UITapGestureRecognizer) {
    //        let location = recognizer.location(in: sceneView)
    //
    //        let hitResults = sceneView?.hitTest(location, options: nil)
    //        if (hitResults?.count)! > 0 {
    //            let result = hitResults![0]
    //            let node = result.node
    //            node.removeFromParentNode()
    //        }
    //    }
    
    // 4. Implement touchesBegan function
    //    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
    //        super.beginAppearanceTransition(isAppearing, animated: animated)
    //        self.time = Time()
    //        //earth.eulerAngles.y = (time?.getLongitude())!
    //        earth.eulerAngles.y += 1.0
    //        print("refresh")
    //    }

// let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
// doubleTapGesture.numberOfTapsRequired = 2
// sceneView!.addGestureRecognizer(doubleTapGesture)

//let doublePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDoublePan(_:)))
//doublePanGesture.minimumNumberOfTouches = 2
//sceneView!.addGestureRecognizer(doublePanGesture)
