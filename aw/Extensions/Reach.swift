import Foundation
import MapKit

extension Reach {

    var readingFormatted: String {
        guard let lastGageReading = lastGageReading, let unit = unit else {
            //print(self.lastGageReading, self.unit)
            return "n/a"
        }
        return "\(lastGageReading) \(unit)"
    }

    var color: UIColor {
        let con = Condition.fromApi(condition: condition ?? "")

        return con.color
    }

    var icon: UIImage? {
        return Condition.fromApi(condition: condition ?? "").icon
    }

    var distanceFormatted: String? {
        return distance != 0 ? "\(Int(distance)) mi" : ""
    }

    var lengthFormatted: String? {
        guard let length = length else { return nil }
        return length != "" ? "\(length) mi" : ""
    }

    var updatedString: String? {
        guard let date = gageUpdated else {
            if detailUpdated != nil {
                return "No flow information"
            }
            return nil
        }
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.doesRelativeDateFormatting = true

        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "h:mm a"

        return "\(dateFormat.string(from: date)) at \(timeFormat.string(from: date))"
    }

    var photoUrl: String? {
        if photoId != 0 {
            return "https://www.americanwhitewater.org/photos/archive/medium/\(photoId).jpg"
        } else {
            return nil
        }
    }

    var runnable: String {
        if let rcString = rc {
            return Runnable.fromRc(rcString: rcString)
        } else {
            return ""
        }
    }

    var url: URL? {
        return URL(string: "https://www.americanwhitewater.org/content/River/detail/id/\( id )/")
    }

    var runnableClass: String {
        return "Level: \(readingFormatted) Class: \(difficulty ?? "Unknown")"
    }
}

// MARK: - MKAnnotation
extension Reach: MKAnnotation {
    public var title: String? {
        if let difficulty = difficulty, let name = name {
            return "\(name) (\(difficulty))"
        } else {
            return name
        }
    }

    public var coordinate: CLLocationCoordinate2D {
        guard let lat = putInLat, let latitude = Double(lat),
            let lon = putInLon, let longitude = Double(lon) else {
                print("\(id) has invalid coordinates")
                return kCLLocationCoordinate2DInvalid
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if CLLocationCoordinate2DIsValid(coordinate) {
            return coordinate
        } else {
            print("\(id) has invalid coordinates")
            return kCLLocationCoordinate2DInvalid
        }
    }
}
