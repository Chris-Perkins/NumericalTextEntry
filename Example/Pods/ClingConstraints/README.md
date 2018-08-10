<p align="center">
	<img src="Readme_Imgs/ClingConstraintsHeader.png" />
</p>

Yet another programmatic constraints library for iOS. The focus of ClingConstraints is to have clean, readable, and powerful constraint creation.

For instance, `thisView.copy(.height, of: thatView)`

<p align="center">
<img src="Readme_Imgs/ClingConstraintsDemo.gif" /> <img src="Readme_Imgs/MovingBox.gif" /> <img src="Readme_Imgs/StackingBoxes.gif" />
</p>

## Features

✅ One-line constraint creation  
✅ One-line copy of multiple constraints  
✅ Chainable property editing for constraints  
✅ Clinging differing constraint attributes together  
✅ One-line vertical or horizontal view filling  
✅ Auto-disable `translatesAutoresizingMaskIntoConstraints`  
✅ Automatically activate constraints  
✅ NSLayoutConstraint collection mass activation/deactivation  
❌ Something bad 


## Installation

1. Install [CocoaPods](https://cocoapods.org)
1. Add this repo to your `Podfile`

	```ruby
	target 'Example' do
		# IMPORTANT: Make sure use_frameworks! is included at the top of the file
		use_frameworks!

		pod 'ClingConstraints'
	end
	```
1. Run `pod install` in the podfile directory from your terminal
1. Open up the `.xcworkspace` that CocoaPods created
1. Done!

## Examples

##### Copy another View's Attribute
```Swift
//  Creates and activates a constraint that makes thisView's height equal to thatView's
thisView.copy(.height, of: thatView)
```

##### Copying Constraints with Personal Space
```Swift
// thisView copies thatView's height * 0.5 - 30.
thisView.copy(.height, of: thatView).withOffset(-30).withMultiplier(0.5)
```

##### Copying Multiple Constraints In-Line
```Swift
// thisView copies the right, top, and left anchor constraints of that view-- in one line.
thisView.copy(.right, .top, .left, of: thatView)
```

##### Clinging Constraints Together
```Swift
// thisView positions itself to the right of thatView with a spacing of 5
thisView.cling(.left, to: thatView, .right).withOffset(5)
```

##### Filling a View
```Swift
// Fills a view from the top to the bottom with the given views
thisView.fill(.topToBottom, withViews: [thatView1, thatView2], spacing: 0)
```

#### What's in the box?

##### Constraint Creation:
On any UIView, you can call the following functions.

Note that these all return the created constraint. If multiple constraints are created, a list of constraints are returned.
```Swift
// This view copies the other view's attributes (returns list of created constraints)
copy(_: NSLayoutAttribute..., of: UIView)

// This view copies the other view's attribute
copy(_: NSLayoutAttribute, of: UIView)

// Clings the calling view's attribute to the other view's attribute.
cling(_: NSLayoutAttribute, to: UIView, _: NSLayoutAttribute)

// Fills the calling view with the given FillMethod from left to right.
// FillMethods: .leftToRight, .rightToLeft, .topToBottom, .bottomToTop
fill(_: FillMethod, withViews: [UIView], withSpacing: CGFloat, spacesInternally: Bool = true)

// Sets the height for this view
setHeight(_: CGFloat)

// Sets the width for this view
setWidth(_: CGFloat)
```


##### Constraint Property Chaining:
On any NSLayoutConstraint:
```Swift
withMultiplier(_: CGFloat)
withOffset(_: CGFloat)
withPriority(_: UILayoutPriority)
withRelation(_: NSLayoutRelation)
```

#### For constraint activation and deactivation:
In any collection of constraints:
```Swift
activateAllConstraints()
deactivateAllConstraints()  
```

## Example Project

<p align="center">
	<img src="Readme_Imgs/ClingConstraintsDemo.gif" />
</p>

The example project in this repository will show how the above animation was created using constraints. Clone this repository and open `.xcodeproj` file located in the "Example Project" directory. 

## Documentation

Read the [docs](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Chris-Perkins/ClingConstraints/master/docs/index.html)

## Author

[Chris Perkins](chrisperkins.me)

Thanks to [Luis Padron](https://github.com/luispadron) for helping set this up! 👍
