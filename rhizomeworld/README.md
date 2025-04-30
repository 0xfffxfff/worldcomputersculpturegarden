# World Computer Sculpture Garden Visualization

## Overview
Create an interactive visualization of a flower field for the World Computer Sculpture Garden exhibition. The visualization will display flowers based on the current count from the exhibition's smart contract and respond to changes in real-time as new flowers are "planted" through transactions to the contract.

## Context and Existing Resources
- The World Computer Sculpture Garden (https://worldcomputersculpturegarden.com/) already has HTML/CSS styling that can be adapted
- The website currently displays flowers with a monospace aesthetic using the ⚘ Unicode character
- The existing contract code in `contracts/GardenContributions.sol` contains a deterministic noise algorithm for placing flowers
- The exhibition's aesthetic is minimalist, with flower symbols arranged in a grid-like pattern on a simple background
- The smart contract at `0x2a362fF002f7ce62D3468509dD2A4a9f5A8EBBb0` tracks the number of flowers planted by visitors

## Technical Requirements

### Display
- Fullscreen browser application optimized for 16:9 (presumably 1920x1080) projection
- Monospace grid layout for flower placement Clean, minimalist aesthetic consistent with the exhibition's design (copy from existing css/show page)

### Data Fetching
- Connect to the Ethereum blockchain to read the flower count from contract at `0x2a362fF002f7ce62D3468509dD2A4a9f5A8EBBb0`
- Listen for block updates to detect changes in the flower count
- Refetch data on each new block
- Also fetch artist names and artwork titles from the contract for optional display

### Visualization Features
- Display flowers (⚘) representing the current count from the contract
- Use deterministic noise algorithm for initial flower placement (similar to the algorithm in `contracts/GardenContributions.sol`)
- New flowers should fade in gradually over approximately 15 seconds when the count increases
- Periodic wind animations that move flowers in various directions:
  - Horizontal (left to right, right to left)
  - Vertical (top to bottom, bottom to top)
  - Diagonal (45° and -45°)
- Wind effects should be subtle and periodic, creating a gentle swaying effect
- Artist names and artwork titles should be integrated into the flower field itself, spatially distributed across the screen
- Text elements should follow the same monospace aesthetic and should subtly fade in and out or drift slowly with the wind effects

### Optional Features
- Display titles and names of artists and their works, fetched from the contract
- These texts should also update on block changes
- Implement day/night cycle or other ambient changes for extended viewing
- Allow customization of animation speeds and flower density via URL parameters

## Contract Integration Details
- The flower count can be fetched by calling `flowerCount()` on the main exhibition contract
- To get information about each artwork, you must:
  1. First get the list of artist contract addresses from the main exhibition contract
  2. Then individually call each artist's contract address with these Sculpture interface methods:
     - `title()` - Returns the title of that specific artwork
     - `authors()` - Returns an array of artist names for that artwork
- Only these two methods (title and authors) are needed for the visualization
- This means creating multiple contract instances, one for each artist's address, and calling these methods on each
- The data from all artists should be distributed spatially around the flower field, not displayed in a rotating manner
- Artist names and artwork titles should be positioned strategically across the screen, integrated with the flower field
- Event listening should track the `NewContribution` event to detect when new flowers are planted

## Technical Approach
- Use Web3.js or ethers.js for blockchain interaction
- Implement with HTML5 Canvas or WebGL for optimal performance
- Consider using a noise library (Perlin, Simplex) for deterministic placement
- Use requestAnimationFrame for smooth animations
- **All code should be contained in a single index.html file**
  - Include CSS in a `<style>` section
  - Include JavaScript in a `<script>` section
  - Do not use external files or resources
  - Use default system monospace fonts, no external font files

## Example Code Structure
```
index.html            // Single file containing all code
├── <head>
│   └── <style>       // CSS styling inline in the document
└── <body>
    └── <script>      // All JavaScript inline in the document
        ├── Contract interaction
        ├── Animation logic
        └── UI display
```

## Notes
- Focus on gentle, subtle movements that aren't distracting
- Ensure the application runs efficiently to prevent browser crashes during extended exhibition display
- Include error handling for network disconnections or contract issues
- Provide a fallback static display if blockchain connection fails
- The existing aesthetic uses Courier or similar monospace font, minimal styling
- Consider implementing a debug mode that can be toggled via URL parameter