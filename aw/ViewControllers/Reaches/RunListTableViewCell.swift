import CoreData
import UIKit

class RunListTableViewCell: UITableViewCell, MOCViewControllerType {
//    @IBOutlet weak var favoriteButton: UIButton!

    var managedObjectContext: NSManagedObjectContext?

    var reach: Reach?

    private let conditionColorView: UIView = {
        let colorView = UIView()
        return colorView
    }()

    private let riverName: UILabel = {
        let lbl = UILabel()
        lbl.text = "name"
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .vertical)
        lbl.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .vertical)
        return lbl
    }()

    private let sectionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "section"
        lbl.textColor = UIColor(named: "font_grey")
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .vertical)
        lbl.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .vertical)
        return lbl
    }()

    private let difficultyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "difficulty"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .vertical)
        lbl.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .vertical)
        return lbl
    }()

    private let distanceLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "distance"
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textAlignment = .right
        lbl.textColor = UIColor(named: "font_grey")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        contentView.addSubview(conditionColorView)
        conditionColorView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                                  bottom: contentView.bottomAnchor, right: nil,
                                  paddingTop: 0, paddingLeft: 0,
                                  paddingBottom: -1, paddingRight: 0,
                                  width: 8, height: 0, enableInsets: false)
        conditionColorView.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .vertical)

        let rightStack = UIStackView(arrangedSubviews: [distanceLabel])
        rightStack.axis = .vertical
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        rightStack.distribution = .fill
        rightStack.alignment = .fill
        rightStack.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)

        let leftSubStack = UIStackView(arrangedSubviews: [riverName, sectionLabel])
        leftSubStack.axis = .vertical
        leftSubStack.spacing = 2
        leftSubStack.translatesAutoresizingMaskIntoConstraints = false
        leftSubStack.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)

        let leftStack = UIStackView(arrangedSubviews: [leftSubStack, difficultyLabel])
        leftStack.axis = .vertical
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.distribution = .fill
        leftStack.alignment = .fill
        leftStack.spacing = 8
        leftStack.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)

        let horizontalStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        horizontalStack.distribution = .fill
        horizontalStack.alignment = .fill
        contentView.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            horizontalStack.leftAnchor.constraint(equalTo: conditionColorView.rightAnchor, constant: 16),
            horizontalStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(reach: Reach) {
        self.reach = reach

        draw()
    }

    func draw() {
        if let reach = reach {
            conditionColorView.backgroundColor = reach.color

            riverName.text = reach.name
            sectionLabel.text = reach.sectionCleanedHTML
            difficultyLabel.text = "Level: \(reach.readingFormatted) Class: \(reach.difficulty ?? "Unknown")"
            difficultyLabel.textColor = reach.color
            distanceLabel.text = reach.distanceFormatted

            let favoriteIcon = reach.favorite ?
                UIImage(named: "icon_favorite_selected") : UIImage(named: "icon_favorite")
//            favoriteButton.setImage(favoriteIcon, for: .normal)

        }
    }

    @IBAction func favoriteButtonTapped(_ sender: Any) {
        managedObjectContext?.persist {
            guard let reach = self.reach else { return }
            reach.favorite = !reach.favorite
        }

        //favoriteButton.setImage(UIImage(named: "icon_favorite_selected"), for: .normal)
    }
}
