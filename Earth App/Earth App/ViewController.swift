//
//  ViewController.swift
//  Earth App
//
//  Created by Lucas Cavatoni on 19/11/2020.
//

import UIKit
import SceneKit

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
    let MaxZoomIn: Float = 1.1
    
    //To convert degrees to radians
    let toRadians = Float.pi/180
    
    //Initial camera Distance to center of scene
    let initialCameraRadius: Float = 3.5

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

        let startTime = CFAbsoluteTimeGetCurrent()
        
        //Adding halo
        let halo = HaloNode()
        halo.eulerAngles.x = -(time?.getDelta())! //Already in radians
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(String(describing: title)): \(timeElapsed) s.")
        
        //Creating the moon
        let moon = MoonNode()
        //Positioning the moon at the proper distance
        moon.position = SCNVector3(x: 0, y: 0,z: Float((time?.getMoonDistance())!))
        //Calculating Moonlight intensity depending on lunar phase
        let maxIntensity: Float = 50
        //Calculate intensity multiple depending on angle
        //Transform [0->180->360] to [0->1->0]
        let intensityMultiple: Float = (180-abs(((time?.getMoonLongitude())!-180)))/180
        //A pretty good approximation is to say the intensity of light is equal to the angle on the moon's orbit to the power of 4. Centered on the full moon. The curve is very pronounced, making quarter moon light almost invisible on earth, we can use a linear model to get a compromise between realism and conveniency.
        //see https://www.researchgate.net/profile/Laszlo-Nowinszky/publication/230095239_The_effect_of_the_moon_phases_and_of_the_intensity_of_polarized_moonlight_on_the_light-trap_catches/links/5a5dc23eaca272d4a3de916f/The-effect-of-the-moon-phases-and-of-the-intensity-of-polarized-moonlight-on-the-light-trap-catches.pdf
        //and http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?bibcode=1966JRASC..60..221E&db_key=AST&page_ind=0&plate_select=NO&data_type=GIF&type=SCREEN_GIF&classic=YES
        moon.light?.intensity = CGFloat(maxIntensity*pow(intensityMultiple,4))
        
        let moonOrbit = SCNNode()
        moonOrbit.addChildNode(moon)
        moonOrbit.eulerAngles.y = (time?.getMoonLongitude())!*toRadians
        moonOrbit.eulerAngles.x = -(time?.getMoonDelta())!*toRadians
        
        
        //Create sun node
        let sun = SunNode()
        //Sun position and orientation
        let sunDistance: Float = 800.0
        sun.eulerAngles.y = Float.pi
        sun.position = SCNVector3(x: 0,y: 0,z: sunDistance)
        
        //Create Sunlight
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = .directional
        //Sun surface temperature is 5778 K
        sunLight.light?.temperature = 5778
        sunLight.light?.intensity = 6000
        sunLight.position = SCNVector3(x: 0,y: 0,z: 0)

        let sunOrbit = SCNNode()
        sunOrbit.addChildNode(sun)
        sunOrbit.addChildNode(sunLight)
        sunOrbit.eulerAngles.x = -(time?.getDelta())!
        
        //Create Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.temperature = 4100
        ambientLight.light?.intensity = 10
        ambientLight.light?.castsShadow = false
        
        //Create the camera
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.bloomIntensity = 0
        cameraNode.camera?.colorFringeIntensity = 0
        cameraNode.camera?.wantsExposureAdaptation = false
        cameraNode.camera?.zFar = 820
        cameraNode.camera?.zNear = 0
        cameraNode.position = earth.position
        cameraNode.position = SCNVector3(x: 0, y: 0, z: initialCameraRadius)
        cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        cameraOrbit.eulerAngles.x = -(time?.getDelta())!
        
        
        
        let solarSystem = SCNNode()
        
        

        //solarSystem.addChildNode(ambientLight)
        //solarSystem.addChildNode(earth)
        //solarSystem.addChildNode(halo)
        //solarSystem.addChildNode(moonOrbit)
        //solarSystem.addChildNode(sunOrbit)
        //solarSystem.addChildNode(cameraOrbit)
        
        solarSystem.eulerAngles.y = starAngle
        
        //View scene
        sceneView = view as! SCNView?
        sceneView?.scene = scene
        
        
        
        self.sceneView?.prepare([ambientLight], completionHandler: { (success) in
            solarSystem.addChildNode(ambientLight)
        })
        
        self.sceneView?.prepare([earth,halo], completionHandler: { (success) in
            solarSystem.addChildNode(earth)
            solarSystem.addChildNode(halo)
        })
        
        
        self.sceneView?.prepare([moonOrbit], completionHandler: { (success) in
            solarSystem.addChildNode(moonOrbit)
        })
        
        self.sceneView?.prepare([sunOrbit], completionHandler: { (success) in
            solarSystem.addChildNode(sunOrbit)
        })
        
        self.sceneView?.prepare([cameraOrbit], completionHandler: { (success) in
            solarSystem.addChildNode(self.cameraOrbit)
        })
        
        self.sceneView?.prepare([solarSystem], completionHandler: { (success) in
            self.scene?.rootNode.addChildNode(solarSystem)
        })
        
        
        
        
        scene?.background.contents = UIImage(named: "starmap_2019_8k.jpg")
       
        
        
        
        
        //Disable camera control because a custom camera is coded
        sceneView?.allowsCameraControl = false
        
        sceneView?.showsStatistics = true
        
        //sceneView?.antialiasingMode = SCNAntialiasingMode.multisampling2X
        
        sceneView?.backgroundColor = UIColor.black
        
        //sceneView?.preferredFramesPerSecond = 60
        
        
        // add a tap gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView!.addGestureRecognizer(panGesture)

        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView!.addGestureRecognizer(pinchGesture)
    }
    
    func refresh(){
        

    }
    

    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let child = scene?.rootNode.childNode(withName: "solarSystem", recursively: true) {
//            child.removeFromParentNode()
//        }
//        //View scene
//        sceneView = view as! SCNView?
//        sceneView?.scene = scene
//        print("viewDidLoad");
//
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("View will appear")
//    }
    
    
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
        guard let camera = cameraOrbit.childNodes.first else {
          return
        }
        let scale = recognizer.velocity
        var factor = Float(cameraNode.position.z/initialCameraRadius)
        factor = factor * factor
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

