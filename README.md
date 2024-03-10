# MovieApp

## Built With
- [Swift](https://developer.apple.com/swift/)
- [UIKit](https://developer.apple.com/documentation/uikit)
- [TMDB API](https://developer.themoviedb.org/reference/intro/getting-started)
- [YT API](https://developers.google.com/youtube/v3)

<p>
  <img src="MovieX.png"/>
</p>

Build a four-paged movie list app.
It will have four screens. The first appearing screen is the splash screen. The data must be fetched from the API in here. As soon as the process is done, endirect the user to the app. The first screen inside the app is the list screen that has list of movies.  Each cell must at least have an image, title, and image of the movie. By tapping one of the movies, the movie detail screen must appear. I can able to add the movie into the bookmarks via a button. The last screen is the bookmarks which have the bookmarked movies. No need filter and search here, only a list.
The list and bookmarks screens must be on a TabBarController. Tab bars' each first item must be NavigationController.

## Goals

* Understand Tab Bar and Navigation Controller
* Understand MVVM by separating logic between controller and view model
* Learn to implement table view
* Integrate third-party library
* Build UI programmatically in controller
* Use UserDefaults
* Integrate network layer by URLSession
* Use model(such as Movie) with Codable

## Architecture

* Use simple MVVM. Do not forget that you must not import UIKit in the view model
* Use protocols to pass the data from the network layer to the screen

## Responsive Design

No need to use any Storyboard od xib files
Use table view and collection view in the list screen
Download movie images via SDWebImage

## Logic

The search and filter mechanism in the list screen must work without blocking UI
Implement Codable to your Movie model and store movies as an array in a singleton object
Store bookmarked movies in the UserDefaults as an array

## Keywords
* MVVM
* Table view
* Collection view
* Codable
* SPM
* SDWebImage
* Network layer
* URLSession
* Singleton
* UserDefaults
