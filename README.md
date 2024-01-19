# WeatherXM iOS app

The iOS app powering the people's weather network.

We use [**Github Flow**](https://githubflow.github.io/) as our branching model.

## Getting started
Clone the repo and navigate to the project's folder
- The app uses the [Mapbox SDK](https://docs.mapbox.com/ios/maps/guides/). We have to do a couple of things to install it.
  - Add `.netrc` file as described [here](https://docs.mapbox.com/ios/maps/guides/install/). Fill the `SECRET_MAPBOX_ACCESS_TOKEN` creating a [MapBox account](https://account.mapbox.com/).
  - Add a new `*.xcconfig` in the project under the `Configuration/` folder following the `Config.xcconfig-template` file as described [here](https://github.com/WeatherXM/wxm-ios/blob/main/CONTRIBUTING.md).
- Choose a scheme to run the app
  - `wxm-ios`: the main scheme pointing to the injected `ApiUrl` with `debug` build configuration. Installed with bundle id `com.weatherxm.app.debug`
  - `wxm-ios-release`: the main scheme pointing to the injected `ApiUrl` with `release` build configuration. Installed with bundle id `com.weatherxm.app`
  - `wxm-ios-mock`: the scheme pointing to the injected `ApiUrl` and returns a local json for every endpoint is provided. Installed with bundle id `com.weatherxm.app.mock`

## Architecture
The project structure follows [the clean architecture design pattern](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3) and every screen is following the [MVVM design pattern](https://blog.devgenius.io/mvvm-architectural-design-pattern-in-swift-87dde74758b0).
## Pull requests
Create a new branch naming with the `feature/` prefix following with the Linear task number. eg `feature/fe-123-{short_description_with_underscores}`
Once is ready for review open a new pull request and when is ready merge in base branch. Before merge rebase your branch to keep ther repo's history clean.
## Release
- Update the app version and build number and commit this change.
- Add a tag with the app version, eg 1.5.2
- Submit the version using the "Automatically manage signing" option. Ask the team for access in [appstore connect](https://appstoreconnect.apple.com)
- [Create a new GitHub release](https://github.com/WeatherXM/wxm-ios/releases/new) out of main with the title being the version name (`X.X.X`).
- Upload dsyms in [firebase crashlytics portal](https://console.firebase.google.com/u/1/project/weatherxm-321811/crashlytics/app/ios:com.weatherxm.app/dsyms). To get the dsyms go to `Window` -> `Organizer` -> Choose the uploaded archive -> Show In Finder -> Show Package Contents -> Compress dsyms folder and upload it
- Once the app is "ready for sale" in app store connect make an announcement on Discord using [this template](https://outline.weatherxm.com/doc/templates-for-update-announcements-Uiek4uZYjE)
## Xcode Cloud
You can declare a job in [XCode cloud](https://developer.apple.com/xcode-cloud/) to submit a new version for review or testing. For this reason there is a `ci_post_clone` scripts which generates the `.netrc` file mentioned above and the `/Configuration/Production/Config.xcconfig` file. To inject the necessary variables you should declare the following as `Environment variables` in your workflow. Keep in mind that every http url value should contain a `$()` before the secnond slash. Just like described in config templates

| Variable             | Value                                    | Is secret |
|----------------------|------------------------------------------|-----------|
| `MAPBOX_TOKEN`       | The mapbox `password`                    | YES       |                                |
| `MAPBOX_ACCESS_TOKEN`| The mapbox access token                  | YES       |
| `CLAIM_TOKEN_URL`    | The DApp url for the claim flow          | NO        |
| `APP_STORE_URL`      | The app store url                        | NO        |
| `SUPPORT_URL`        | The link to navigate for contact support | NO        |
| `API_URL`            | The API url                              | NO        |
