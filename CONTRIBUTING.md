# Welcome to WeatherXM's iOS App contributing guide.

First of all, thank you for investing your time to contribute in WeatherXM! Any contribution you
make will be reflected on
our [iOS App](https://apps.apple.com/ca/app/weatherxm/id1629841929).

We use **[Github Flow](https://githubflow.github.io/)** as our branching model and *Clean
Architecture*.

In this guide you will get an overview of the contribution workflow from opening an issue, creating
a PR, reviewing, and merging the PR.

## Table Of Contents

[Code of Conduct](#code-of-conduct)

[Building & Environment](#building--environment)

* [Environment Variables](#environment-variables)
* [Different Schemes](#different-schemes)
* [Google Services JSON](#google-services-json)

[How to ask a question, report a bug or suggest a potential new feature/improvement?](#how-to-ask-a-question-report-a-bug-or-suggest-a-potential-new-featureimprovement)

* [Do you have a question](#do-you-have-a-question)
* [Reporting Bugs](#did-you-find-a-bug)
* [Suggesting Enhancements](#do-you-want-to-suggest-a-potential-improvement-or-a-new-feature)

[How to Contribute?](#how-to-contribute)

[Styleguide](#styleguide)

[Additional Notes](#additional-notes)

* [Issue Labels](#issue-labels)

## Code of Conduct

This project and everyone participating in it is governed by the
[Code of Conduct](blob/main/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code to keep our community approachable and
respectable.

## Building & Environment

### Environment Variables

To build the app from source, you need to pass the following environment variables, by creating a `*.xcconfig` file in the [Configuration](/Configuration) directory,
according to
the [template](https://github.com/WeatherXM/wxm-ios/Config.xcconfig-template) file,
that will be
automatically read into env variables. You must use your own environmental
variables
for contributing to the project.

All environment variables have descriptive comments on the template, but some extra information
should be given
regarding the Firebase and the Mapbox ones.

The `ApiUrl` is specified via these `*.xcconfig` files. In order to use a different `ApiUrl` than the
one provided
in `Config.xcconfig-template`, for each different scheme (see below about our different schemes)
you need to create a different `{scheme}.xcconfig` file based on the following map:
Mock -> `ConfigMock.xcconfig` and add it under `Configuration/Mock` folder
Debug -> `ConfigDebug.xcconfig` and add it under `Configuration/Debug` folder
Production -> `Config.xcconfig` and add it under `Configuration/Production` folder

#### Mapbox Variables

We have a variable for Mapbox:

- `MBXAccessToken`
  This is required for building the project. For creating this token you have to create a [Mapbox account](https://account.mapbox.com).
  To download the mapBox SDK you should add `.netrc` file as described [here](https://docs.mapbox.com/ios/maps/guides/install/).

You can view Mapbox guide on Access
Token [here](https://docs.mapbox.com/help/getting-started/access-tokens/).

- `MBXStyle`
  For custom mapbox style. It's optional.

### Different Schemes

We have 3 different app schemes. For each scheme a
different `.xcconfig` file should be created for different environment variables such as `ApiUrl`.

The 3 different app flavors are:

1. **wxm-ios**: This scheme is mainly used for development. Creates an app with a `-DB` suffix. Uses the `ConfigDebug.xcconfig` file as mentioned [below](#environment-variables) and build the app with debug configuration.
2. **wxm-ios-release**: This scheme is used to install an app with `release` configuration. Creates an app with no suffix. Uses the `Config.xcconfig` file as mentioned [below](#environment-variables).
3. **wxm-ios-mock**: This scheme is mainly used only for development purposes and to "mock" specific case. Uses the `ConfigMock.xcconfig` file as mentioned [below](#environment-variables).
Points to the injected `ApiUrl`. The difference here is that for each endpoint we can provide a mock response (`wxm-ios/DataLayer/DataLayer/Networking/Mock/Jsons`).
If it is provided, it retrurns the mock response, otherwise fetches the remote response.

### Google Services JSON

The `GoogleService-Info.plist` configuration file is required for building the app. Depending on the
scheme you want to use,
you should create your own Firebase project and download that file. A guide on how to do it can be
found [here](https://firebase.google.com/docs/ios/setup#console).
For each scheme you should place this file under `wxm-ios/Resources/Debug/` folder for debug builds and under `wxm-ios/Resources/Release/` for any other case. Do the same for the widget (`wxm-ios/station-widget/Resources/Debug` and `wxm-ios/station-widget/Resources/Release`) and for the intent (`wxm-ios/station-intent/Resources/Debug` and `wxm-ios/station-intent/Resources/Release`).

**Each file should be unique for each bundle id**.

You can use, and is recommended during development, the `-WXMAnalyticsDisabled YES` argument to disable every logging and monitoring functionality

## How to ask a question, report a bug or suggest a potential new feature/improvement?

### **Do you have a question?**

* **Ensure your question was not already asked** by searching on GitHub
  under [Issues](https://github.com/WeatherXM/wxm-ios/issues?q=is%3Aopen+is%3Aissue+label%3Aquestion) under the
  label _Question_.

* If you're unable to find a response to your
  question , [open a new issue](https://github.com/WeatherXM/wxm-ios/issues/new/choose) by using
  the [**Ask a question** template](https://github.com/WeatherXM/wxm-ios/blob/main/.github/ISSUE_TEMPLATE/ask_a_question.md).
  Using this template is mandatory. Make sure to have a **clear title** and include as many details
  as possible as that information helps to answer your question as soon as possible.

### **Did you find a bug?**

* **Ensure the bug was not already reported** by searching on GitHub
  under [Issues](https://github.com/WeatherXM/wxm-ios/issues?q=is%3Aopen+is%3Aissue+label%3Abug) under the label
  _Bug_.

* If you're unable to find an open issue addressing the
  problem, [open a new issue](https://github.com/WeatherXM/wxm-ios/issues/new/choose) by using
  the [**Bug Report** template](https://github.com/WeatherXM/wxm-ios/blob/main/.github/ISSUE_TEMPLATE/bug_report.md).
  Using this template is mandatory. Make sure to have a **clear title** and include as many details
  as possible as that information helps to resolve issues faster.

### **Do you want to suggest a potential improvement or a new feature?**

* **Ensure this suggestion was not already reported** by searching on GitHub
  under [Issues](https://github.com/WeatherXM/wxm-ios/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement) under the
  label _Enhancement_.

* If you're unable to find that
  suggestion, [create a new issue](https://github.com/WeatherXM/beta-issue-tracker/issues/new/choose)
  by using the [**Feature Request** template](https://github.com/WeatherXM/beta-issue-tracker/blob/main/.github/ISSUE_TEMPLATE/feature_request.md).
  Using this template is mandatory. Make sure to have a **clear title** and include as many details
  as possible.

## How to contribute?

We are open to contributions on [current issues](https://github.com/WeatherXM/wxm-ios/issues),
if the bug/feature/improvement you would like to work on isn't documented, please open a new issue
so we can approve it before you start working on it.

### Fix a bug, implement a new feature or conduct an optimization

Scan through our existing [issues](https://github.com/WeatherXM/wxm-ios/issues) to find one that
interests you (or create a new one). You can narrow down the search using `labels` as filters.
See [Issue Labels](#issue-and-pull-request-labels) for more information. Please don't start working
on issues that are currently assigned to someone else or have the `in-progress` label. If you find
an issue to work on, please comment in it to get it assigned to you and you are welcome to open a PR
with a fix/implementation.

### Pull Request

When you're finished with the changes, create a pull request, also known as a PR.

- Fill the "Ready for review" template so that we can review your PR. This template helps reviewers
  understand your changes as well as the purpose of your pull request.
- Don't forget
  to [link PR to issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  if you are solving one.
- Enable the checkbox
  to [allow maintainer edits](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/allowing-changes-to-a-pull-request-branch-created-from-a-fork)
  so the branch can be updated for a merge.
  Once you submit your PR, a WeatherXM team member will review your PR. We may ask questions or
  request additional information.
- We may ask for changes to be made before a PR can be merged. You can implement those changes in
  your fork, then commit them to your branch in order to update the PR.
- As you update your PR and apply changes, mark each conversation
  as [resolved](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/commenting-on-a-pull-request#resolving-conversations).

### Your PR is merged!

Congratulations 🥳 The WeatherXM team thanks you! We really appreciate your effort and help! ♥️

Once your PR is merged, your contributions will be publicly visible on
our [iOS App](https://apps.apple.com/ca/app/weatherxm/id1629841929) on the next
release.

## Styleguide

We use **[Github Flow](https://githubflow.github.io/)** as our branching model and *Clean
Architecture*.

## Additional Notes

### Issue Labels

This section lists the labels we use to help us track and manage issues.

#### Type of Issue Labels

| Label name        | Description                                                               |
|-------------------|---------------------------------------------------------------------------|
| `enhancement`     | New feature request or improvement                                        |
| `bug`             | Confirmed bugs or reports that are very likely to be bugs.                |
| `question`        | Questions more than bug reports or feature requests (e.g. how do I do X). |
| `in-progress`     | A bug, feature or improvement that is currently a Work-In-Progress.       |
| `needs-attention` | An issue that needs attention to be put under specific categories/labels. |
| `wontfix`         | An issue that won't be worked on.                                         |
