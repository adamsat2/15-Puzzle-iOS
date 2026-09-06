# 15-Puzzle for iOS

A modern iOS implementation of the classic sliding puzzle game, originally developed by Andy Hertzfeld as a desk accessory for the 1984 Macintosh. Built natively with SwiftUI, this project brings the nostalgic 4x4 number grid into the modern era with fluid animations and a clean interface.

## Visual Overview

Below is a look at the game in both light and dark appearances.

| Initial State (Light Mode) | Initial State (Dark Mode) |
| :---: | :---: |
| ![Initial Light](screenshots/initial-light.jpeg) | ![Initial Dark](screenshots/initial-dark.jpeg) |

| Win State (Light Mode) | Win State (Dark Mode) |
| :---: | :---: |
| ![Win Light](screenshots/win-light.jpeg) | ![Win Dark](screenshots/win-dark.jpeg) |

## How to Play

The game consists of a 4x4 grid containing numbered tiles from 1 to 15, leaving one cell blank. At the start of every game, the tiles are randomly scrambled into a solvable configuration. 

The objective is to rearrange the tiles in numerical order from left to right, top to bottom, with the blank space resting in the bottom right corner. 

To move tiles, tap on any numbered tile in the same row or column as the blank space. The selected tile, along with any adjacent tiles, will slide smoothly into the empty spot. Once the correct order is achieved, the game locks the board and displays a victory message.

## Features

* Algorithmic Scrambling: The game simulates 150 random valid moves from a solved state. This guarantees that every generated puzzle is 100 percent solvable.
* Fluid Animations: Utilizing SwiftUI spring animations, the tiles slide naturally into place. The logic supports shifting entire rows or columns at once.
* Modular Architecture: The user interface is broken down into clean, reusable components.
* System Theme Support: The interface seamlessly adapts to the system appearance settings, supporting both bright and dark modes.

## Project Structure

The codebase is organized into modular SwiftUI views:
* **MainView.swift**: The central container managing the game state and view composition.
* **HeaderView.swift**: Displays the title and the historical attribution subtitle.
* **GameGridView.swift**: Renders the 4x4 grid and handles the tap gestures and movement logic.
* **TileView.swift**: The visual representation of individual numbered cells and the blank space.
