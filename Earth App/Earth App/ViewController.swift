//
//  ViewController.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 19/11/2020.
//

import UIKit
import SceneKit
import SceneKit.ModelIO

class ViewController: UIViewController {
    
    var cameraOrbit = SCNNode()
    let cameraNode = SCNNode()
    var sceneView: SCNView?
    var time: Time?
    var scene: SCNScene?
    
    //Handle Pan
    //Higher values means less sensitive
    let panModifier = 200
    //Handle Pinch
    //Higher values means less sensitive
    let pinchModifier = 20
    //Zoom
    let MaxZoomOut: Float = 10.0
    let MaxZoomIn: Float = 1.2
    
    //To convert degrees to radians
    let toRadians = Float.pi/180
    
    //Initial camera Distance to center of scene
    let initialCameraRadius: Float = 7.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.time = Time()
        
        
        //Star Angle, ecliptic angle of the sun, for the starmap background
        //Scene will be rotated by that angle in the end, to match current stars and milky way
        // -PI/2 is because the skybox is rotated by -PI/2 initially (IDK why...)
        let starAngle = (time?.getLambda())!*toRadians-Float.pi/2
             
        
        
        //Create the scene
        scene = SCNScene()
        
        
        
        
        //Creating the earth node
        let earth = EarthNode()
        //Ajdusting Earth's position to match current date and time
        earth.eulerAngles.y = ((time?.getLongitude())!)*toRadians
        
        
        //Creating the moon
        let moon = MoonNode()
        //Positioning the moon at the proper distance
        moon.position = SCNVector3(x: 0, y: 0,z: Float((time?.getMoonDistance())!))
        moon.eulerAngles.y = Float.pi
        //Calculating Moonlight intensity depending on lunar phase
        let maxIntensity: Float = 10
        //Calculate intensity multiple depending on angle
        //Transform [0->180->360] to [0->1->0]
        let intensityMultiple: Float = (180-abs(((time?.getMoonLongitude())!-180)))/180
        //A pretty good approximation is to say the intensity of light is equal to the angle on the moon's orbit to the power of 3.60-3.70. Centered on the full moon. The curve is very pronounced, making quarter moon light almost invisible on earth, we can use a linear model to get a compromise between realism and conveniency.
        //see https://www.researchgate.net/profile/Laszlo-Nowinszky/publication/230095239_The_effect_of_the_moon_phases_and_of_the_intensity_of_polarized_moonlight_on_the_light-trap_catches/links/5a5dc23eaca272d4a3de916f/The-effect-of-the-moon-phases-and-of-the-intensity-of-polarized-moonlight-on-the-light-trap-catches.pdf
        //and http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?bibcode=1966JRASC..60..221E&db_key=AST&page_ind=0&plate_select=NO&data_type=GIF&type=SCREEN_GIF&classic=YES
        
        let moonLight = SCNNode()
        moonLight.light = SCNLight()
        moonLight.light?.intensity = CGFloat(maxIntensity*pow(intensityMultiple,3))
        //moon.light?.intensity = CGFloat(maxIntensity*intensityMultiple)
        moonLight.light?.type = .directional
        moonLight.light?.color = UIColor.green
        
        let moonOrbit = SCNNode()
        moonOrbit.addChildNode(moon)
        moonOrbit.addChildNode(moonLight)
        moonOrbit.eulerAngles.y = (time?.getMoonLongitude())!*toRadians
        moonOrbit.eulerAngles.x = -(time?.getMoonDelta())!*toRadians
        
        
        
        
        
        //Create sun node
        let sun = SunNode()
        //Sun position and orientation
        let sunDistance: Float = 80.0
        sun.eulerAngles.y = Float.pi
        sun.position = SCNVector3(x: 0,y: 0,z: sunDistance)
        
        //Create Sunlight
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = .directional
        //Sun surface temperature is 5780 K
        sunLight.light?.color = UIColor.red
        sunLight.light?.intensity = 1000
        sunLight.position = SCNVector3(x: 0,y: 0,z: 0)
        
        let sunOrbit = SCNNode()
        sunOrbit.addChildNode(sun)
        sunOrbit.addChildNode(sunLight)
        sunOrbit.eulerAngles.x = -(time?.getDelta())!
        
        //Create the camera
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.bloomIntensity = 0.0
        cameraNode.camera?.wantsExposureAdaptation = true
        cameraNode.camera?.exposureAdaptationDarkeningSpeedFactor = 10.0
        cameraNode.camera?.exposureAdaptationBrighteningSpeedFactor = 10.0
        //cameraNode.camera?.motionBlurIntensity = 1.0
        cameraNode.camera?.maximumExposure = 1.0
        //cameraNode.camera?.exposureOffset = -1.0
        cameraNode.camera?.fieldOfView = 30.0
        cameraNode.camera?.zNear = 0.1
        cameraNode.position = SCNVector3(x: 0, y: 0, z: initialCameraRadius)
        cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        cameraOrbit.eulerAngles.x = -(time?.getDelta())!
        
        
        let solarSystem = SCNNode()
        solarSystem.eulerAngles.y = starAngle
        
        
        
        //View scene
        sceneView = view as! SCNView?
        sceneView?.scene = scene
        
        //self.sceneView?.prepare([earth,atmosphere], completionHandler: { (success) in
            solarSystem.addChildNode(earth)
        //})
        
        //self.sceneView?.prepare([moonOrbit], completionHandler: { (success) in
            solarSystem.addChildNode(moonOrbit)
        //})
        
        //self.sceneView?.prepare([sunOrbit], completionHandler: { (success) in
            solarSystem.addChildNode(sunOrbit)
        //})
        
        //self.sceneView?.prepare([cameraOrbit], completionHandler: { (success) in
            solarSystem.addChildNode(self.cameraOrbit)
        //})
        
        //self.sceneView?.prepare([solarSystem], completionHandler: { (success) in
            self.scene?.rootNode.addChildNode(solarSystem)
        //})
        
        
        
        //scene?.background.contents = UIImage(named: "starmap")
    
        
        //Disable camera control because a custom camera is coded
        sceneView?.allowsCameraControl = false
        
        sceneView?.showsStatistics = true
        
        //sceneView?.antialiasingMode = SCNAntialiasingMode.multisampling4X
        
        sceneView?.rendersContinuously = false
        
        sceneView?.autoenablesDefaultLighting = false
        
        sceneView?.backgroundColor = UIColor.black

        
        // add a tap gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView!.addGestureRecognizer(panGesture)

        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView!.addGestureRecognizer(pinchGesture)
        
        // tap recognizer
//        let tapRecognizer = UITapGestureRecognizer()
//            tapRecognizer.numberOfTapsRequired = 1
//            tapRecognizer.numberOfTouchesRequired = 1
//        tapRecognizer.addTarget(self, action: Selector(("sceneTapped:")))
//            sceneView?.gestureRecognizers = [tapRecognizer]

    }
    
    func sceneTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
         
        let hitResults = sceneView?.hitTest(location, options: nil)
        if (hitResults?.count)! > 0 {
            let result = hitResults![0]
            let node = result.node
            node.removeFromParentNode()
        }
    }
    
    func refresh(){



        cameraOrbit.eulerAngles.y += Float.pi/2
        print("refresh")


    }
    
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let factor = Float(cameraNode.position.z/initialCameraRadius)

        let translation = recognizer.velocity(in: recognizer.view)
        cameraOrbit.eulerAngles.y -= Float(translation.x/CGFloat(panModifier))*toRadians*factor
        let xAngle = cameraOrbit.eulerAngles.x - Float(translation.y/CGFloat(panModifier))*toRadians*factor
        //Prevent from putting th camera upside down by rotating past the north and south pole
        if xAngle > -Float.pi/2, xAngle < Float.pi/2 {
            cameraOrbit.eulerAngles.x = xAngle
        }
    }

    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        //CameraNode (variable called camera is actually cameraNode)
        guard let camera = cameraOrbit.childNodes.first else {
          return
        }
        let scale = recognizer.velocity
        let factor = Float(camera.position.z/initialCameraRadius)
        let z = camera.position.z - Float(scale)/Float(pinchModifier)*factor
        if z < MaxZoomOut, z > MaxZoomIn {
          camera.position.z = z
        }
    }
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}

