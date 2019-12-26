# Danger plugin for ktlint and detekt on Android

It helps users report ktlint and detekt issues via Danger.

## Installation

    $ gem install danger-android_ktlint_detekt

## Usage

    Just add this to your Dangerfile:

    ```
    android_ktlint_detekt.ktlint_report_file = path_to_ktlint_xml
    android_ktlint_detekt.detekt_report_file = path_to_detekt_xml
    android_ktlint_detekt.report(inline_mode: true)
    ```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
