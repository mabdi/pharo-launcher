Class {
	#name : #PhLProcessWrapperTest,
	#superclass : #TestCase,
	#category : #'PharoLauncher-Tests-Functional'
}

{ #category : #tests }
PhLProcessWrapperTest >> testCanDetectAvailableCommandOnLinux [
	Smalltalk os isWindows ifTrue: [ self skip. ^ self ].

	self assert: (PhLProcessWrapper isCommandAvailable: 'ls').
	self deny: (PhLProcessWrapper isCommandAvailable: 'foobar').
]

{ #category : #tests }
PhLProcessWrapperTest >> testCanDetectAvailableCommandOnWindows [
	Smalltalk os isWindows ifFalse: [ self skip. ^ self  ].

	self assert: (PhLProcessWrapper isCommandAvailable: 'dir').
	self deny: (PhLProcessWrapper isCommandAvailable: 'foobar').
]

{ #category : #tests }
PhLProcessWrapperTest >> testCanRunCommandWithNonAsciiCharacters [
	| process fileRef |

	fileRef := (FileLocator temp / 'Yann-Gaël Bérès.bat') asFileReference.
	fileRef ensureCreateFile.

	process := PhLProcessWrapper new 
		shellCommand;
		addArgument: (Smalltalk os isWindows 
			ifTrue: [ 'dir' ]
			ifFalse: [ 'ls' ]);
		addArgument: fileRef fullName surroundedByDoubleQuotes;
		runAndWait.
	self assert: process isSuccess
]

{ #category : #tests }
PhLProcessWrapperTest >> testLinuxCommandRemoveDoubleQuotesFromArguments [
	"OSSubProcess gets an array of arguments as input. If arguments are protected with double-quotes, they are interpreted as part of the argument. Protecting arguments with double quotes only works when using a shell command with an arguments string. The shell the interprets double-quotes and remove them to run the command."
	| process argument |
	Smalltalk os isWindows ifTrue: [ self skip. ^ self ].

	process := PhLProcessWrapper new 
		command: 'sleep';
		addArgument: '1'.
	
	argument := process arguments first.
	self deny: (argument includes: $").
	process runAndWait.
	self assert: process isSuccess
]

{ #category : #tests }
PhLProcessWrapperTest >> testLinuxShellCommandDoesNotRemoveDoubleQuotesFromArguments [
	"OSSubProcess gets an array of arguments as input. If arguments are protected with double-quotes, they are interpreted as part of the argument. Protecting arguments with double quotes only works when using a shell command with an arguments string. The shell the interprets double-quotes and remove them to run the command."
	| process pathArgument |
	Smalltalk os isWindows ifTrue: [ self skip. ^ self ].

	process := PhLProcessWrapper new 
		shellCommand;
		addArgument: 'ls';
		addArgument: FileLocator home fullName surroundedByDoubleQuotes.
	
	pathArgument := process arguments second.
	self assert: pathArgument first equals: $".
	self assert: pathArgument last equals: $".
	process runAndWait.
	self assert: process isSuccess
]

{ #category : #tests }
PhLProcessWrapperTest >> testRunningInfiniteProcessThrowsTimeout [
	| process |
	process := PhLProcessWrapper new 
		shellCommand;
		yourself.
	Smalltalk os isWindows 
		ifTrue: [ process addArgument: 'FOR /L %N IN () DO @echo Oops' ]
		ifFalse: [ process addArgument: 'bash -c " while true; do echo ''Hit CTRL+C''; sleep 1; done"' ].

	self 
		should: [ process runAndWaitTimeOut: 300 milliSeconds. ]
		raise: PhLProcessTimeOut.
]

{ #category : #tests }
PhLProcessWrapperTest >> testRunningShortProcessDoesNotTimeout [
	| cmd |
	 cmd := Smalltalk os isWindows 
		ifTrue: [ 'timeout 1' ]
		ifFalse: [ 'sleep 1' ].
	self 
		shouldnt: [ PhLProcessWrapper new 
			shellCommand;
			addArguments: cmd;
			runAndWaitTimeOut: 2 seconds ]
		raise: PhLProcessTimeOut.
]

{ #category : #tests }
PhLProcessWrapperTest >> testWindowsCommandDoesNotRemoveDoubleQuotesFromArguments [
	"Windows API takes a single String with all arguments as parameter. Paths have to be protected by double quotes."
	| process argument |
	Smalltalk os isWindows ifFalse: [ self skip. ^ self ].

	process := PhLProcessWrapper new 
		command: Smalltalk vmBinary fullName;
		addArgument: Smalltalk imagePath surroundedByDoubleQuotes;
		addArgument: '--headless'.
	
	argument := process arguments first.
	self assert: argument first equals: $".
	self assert: argument last equals: $".
	process runAndWait.
	self assert: process isSuccess
]

{ #category : #tests }
PhLProcessWrapperTest >> testWindowsShellCommandOnWindowsDoesNotRemoveDoubleQuotesFromArguments [
	"Windows API takes a single String with all arguments as parameter. Paths have to be protected by double quotes."
	| process argument |
	Smalltalk os isWindows ifFalse: [ self skip. ^ self ].

	process := PhLProcessWrapper new 
		shellCommand;
		addArgument: 'timeout';
		addArgument: '"/?"'.
	
	argument := process arguments last.
	self assert: argument first equals: $".
	self assert: argument last equals: $".
	process runAndWait.
	self assert: process isSuccess
]