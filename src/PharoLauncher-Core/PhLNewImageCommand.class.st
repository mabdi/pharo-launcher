"
Open the image creation UI.
"
Class {
	#name : #PhLNewImageCommand,
	#superclass : #PhLGeneralCommand,
	#category : #'PharoLauncher-Core-Commands'
}

{ #category : #converting }
PhLNewImageCommand >> asSpecCommand [
	^ super asSpecCommand
		iconName: #smallNew;
		shortcutKey: $n meta;
		yourself
]

{ #category : #executing }
PhLNewImageCommand >> execute [
	^ (PhLTemplatesPresenter 
			newApplication: self application
			model: PhLTemplateGroupRepository default)
		selectCategory: 3; "official category"
		openWithSpec;
		yourself
]

{ #category : #initialization }
PhLNewImageCommand >> initialize [
	super initialize.
	self
		name: 'New';
		description: self class comment.
]