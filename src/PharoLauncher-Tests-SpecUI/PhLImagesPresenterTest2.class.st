Class {
	#name : #PhLImagesPresenterTest2,
	#superclass : #TestCase,
	#instVars : [
		'presenter'
	],
	#category : #'PharoLauncher-Tests-SpecUI'
}

{ #category : #'as yet unclassified' }
PhLImagesPresenterTest2 class >> smallAmpTargetClasses [ 
	^ { PhLImagesPresenter }
]

{ #category : #tests }
PhLImagesPresenterTest2 >> testFirstImageIsSelectedAtOpening [
	presenter := PhLTestImagesPresenter new.
	presenter openWithSpec.
	
	self assert: presenter hasSingleImageSelected.
	self assert: presenter singleImage name equals: presenter singleImageName
]
