import CoreData
import CoreLocation
import UIKit

class OnboardLocationViewController: UIViewController, MOCViewControllerType {
    @IBOutlet weak var awTitle: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var buttonText: UILabel!
    @IBOutlet weak var zipcodeField: UITextField!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var locationArrow: UIImageView!

    var managedObjectContext: NSManagedObjectContext?

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        awTitle.font = UIFont.italicSystemFont(ofSize: 28)
        zipcodeField.attributedPlaceholder = NSAttributedString(string: "Zipcode",
                                                                attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.25),
                                                                             NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 26)!])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        injectContextAndContainerToChildVC(segue: segue)
    }

    @IBAction func zipcodeChanged(_ sender: UITextField) {
        if sender.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            toggleLayout(.noZip)
        } else if sender.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 5 {
            toggleLayout(.fullZip)
        } else {
            toggleLayout(.partialZip)
        }
    }

    @IBAction func zipcodeContinueHit(_ sender: UITextField) {
        locationFromZip()
    }

    @IBAction func allowLocationPressed(_ sender: Any) {
        if zipcodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            setupLocationUpdates()
        } else if zipcodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 5 {
            locationFromZip()
        }

    }
}

// MARK: - Extension
extension OnboardLocationViewController {
    func initialize() {
        locationManager.delegate = self
        
        if let context = managedObjectContext {
            AWArticleAPIHelper.updateArticles(viewContext: context) {
                print("fetched articles")
                print(DefaultsManager.articlesLastUpdated as Any)
            }
        }
    }

    func saveLocationAndSegue(location: CLLocationCoordinate2D) {
        DefaultsManager.latitude = location.latitude
        DefaultsManager.longitude = location.longitude
        DefaultsManager.distanceFilter = 100

        performSegue(withIdentifier: Segue.onboardingCompleted.rawValue, sender: nil)
    }

    func locationFromZip() {
        guard zipcodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 5,
            let zipcode = zipcodeField.text else { return }

        let decoder = CLGeocoder()
        toggleLayout(.locating)
        decoder.geocodeAddressString(zipcode) { (placemarks, error) in
            guard error == nil,
                let placemarks = placemarks,
                let place = placemarks.first,
                let coordinates = place.location?.coordinate else {
                self.toggleLayout(.fullZip)
                return
            }
            self.saveLocationAndSegue(location: coordinates)
        }
    }

    enum LocationState {
        case noZip, partialZip, fullZip, locating
    }

    func toggleLayout(_ zipEntry: LocationState) {
        switch zipEntry {
        case .noZip:
            locationButton.isEnabled = true
            orLabel.isHidden = false
            buttonText.textColor = UIColor(named: "primary")
            buttonText.text = "Use your current location?"
            locationArrow.isHidden = false
            zipcodeField.isEnabled = true
        case .partialZip:
            locationButton.isEnabled = false
            orLabel.isHidden = true
            buttonText.textColor = UIColor(named: "font_grey")
            buttonText.text = "Confirm location"
            locationArrow.isHidden = true
            zipcodeField.isEnabled = true
        case .fullZip:
            locationButton.isEnabled = true
            orLabel.isHidden = true
            buttonText.textColor = UIColor(named: "primary")
            buttonText.text = "Confirm location"
            locationArrow.isHidden = true
            zipcodeField.isEnabled = true
        case .locating:
            locationButton.isEnabled = false
            buttonText.textColor = UIColor(named: "font_grey")
            buttonText.text = "Locating..."
            zipcodeField.isEnabled = false
        }
    }

    func setupLocationUpdates() {
        toggleLayout(.locating)
        let authStatus = CLLocationManager.authorizationStatus()

        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            updateLocation()
        default:
            break
        }
    }

    func updateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension OnboardLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // allow location updates
            print("Authorized to get location")
            updateLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        print(location)
        locationManager.stopUpdatingLocation()

        saveLocationAndSegue(location: location.coordinate)
    }
}
