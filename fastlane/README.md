fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### test
```
fastlane test
```
Runs all the tests
### beta
```
fastlane beta
```
Submit a new Beta Build to Apple TestFlight
### release
```
fastlane release
```
Deploy a new version to the App Store
### upload_metadata
```
fastlane upload_metadata
```
Deploy a new version to the App Store
### storyboard_ids
```
fastlane storyboard_ids
```
Updates the storyboard identifier Swift values.
### reorganize_project_folder
```
fastlane reorganize_project_folder
```
Reorganizes Xcode project folder to match Xcode groups.
### install_dependencies
```
fastlane install_dependencies
```
Install dependencies (gems, cocoapods)
### update_dependencies
```
fastlane update_dependencies
```
Update dependencies (bundler, gems, cocoapods)
### reintegrate
```
fastlane reintegrate
```
Delete cocoapods from the project and reinstall

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
