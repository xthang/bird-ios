//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit

import XLibrary

class WelcomeView: OverlayView {
	
	private let TAG = "WC"
	
	@IBOutlet private weak var collectionView: UICollectionView!
	@IBOutlet private weak var pageControl: UIPageControl!
	@IBOutlet private var pages: [UIView]!
	
	private var completion: (() -> Void)?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		pages.sort { $0.tag < $1.tag }
		pages.forEach { v in
			v.translatesAutoresizingMaskIntoConstraints = false
		}
		
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		
		pageControl.numberOfPages = pages.count
	}
	
	override func didMoveToSuperview() {
		guard superview != nil else { return }
		
		super.didMoveToSuperview()
		
		SceneManager.prepareScene(.home)
	}
	
	override func layoutSubviews() {
		// NSLog("--  \(TAG) | layoutSubviews")
		
		collectionView.collectionViewLayout.invalidateLayout()
		// setNeedsLayout()
		super.layoutSubviews()	// super has to be called after
		pageChanged(pageControl)
	}
	
	public func onCompletion(completion: @escaping () -> Void) {
		self.completion = completion
	}
	
	@IBAction func pageChanged(_ sender: UIPageControl) {
		collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0),
											 at: .centeredHorizontally, animated: true)
	}
	
	@IBAction func getStartedButtonTapped(_ sender: UIButton) {
		self.removeFromSuperview()
		UserDefaults.standard.setValue(Helper.appVersion, forKey: CommonConfig.Keys.welcomeVersion)
		completion?()
	}
}

extension WelcomeView: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// NSLog("--  \(TAG) | collectionView: numberOfItemsInSection: \(section)")
		return pages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		let v = pages[indexPath.row]
		cell.addSubview(v)
		cell.addConstraints([
			NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: v, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: 0),
		])
		return cell
	}
}

extension WelcomeView: UICollectionViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
		let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
		
		// let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
		// let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
		
		let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
		// let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
		
		let pageCount = pages.count
		let unit = 1.0 / CGFloat((pageCount - 1))
		
		if (percentageHorizontalOffset < 0) {
			(pages[0].subviews[0] as? UIImageView)?.transform = CGAffineTransform(scaleX: 1+percentageHorizontalOffset/unit, y: 1+percentageHorizontalOffset/unit)
		} else if (percentageHorizontalOffset >= 0 && percentageHorizontalOffset < unit) {
			(pages[0].subviews[0] as? UIImageView)?.transform = CGAffineTransform(scaleX: (unit-percentageHorizontalOffset)/unit, y: (unit-percentageHorizontalOffset)/unit)
			(pages[1].subviews[0] as? UIImageView)?.transform = CGAffineTransform(scaleX: percentageHorizontalOffset/unit, y: percentageHorizontalOffset/unit)
		} else if (percentageHorizontalOffset >= unit && percentageHorizontalOffset < 1) {
			(pages[1].subviews[0] as? UIImageView)?.transform = CGAffineTransform(scaleX: (1-percentageHorizontalOffset)/unit, y: (1-percentageHorizontalOffset)/unit)
			(pages[2].subviews[0] as? UIImageView)?.transform = CGAffineTransform(scaleX: (percentageHorizontalOffset-unit)/unit, y: (percentageHorizontalOffset-unit)/unit)
		} else if (percentageHorizontalOffset >= 1) {
			(pages[2].subviews[0] as? UIImageView)?.transform = CGAffineTransform(scaleX: 1-(percentageHorizontalOffset-1)/unit, y: 1-(percentageHorizontalOffset-1)/unit)
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		// NSLog("--  \(TAG) | scrollViewDidEndDecelerating")
		pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
	}
}

extension WelcomeView: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// NSLog("--  \(TAG) | collectionView: sizeForItemAt: \(indexPath)")
		return collectionView.bounds.size
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets.zero
	}
}
