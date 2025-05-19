# World Computer Sculpture Garden Visualization Generator

## Overview
This script generates static visualizations of a flower field for the Presentation of the World Computer Sculpture Garden exhibition at NFC Lisbon 2025.

The script creates PNG images with randomly placed flowers (⚘) using a monospace aesthetic on a grid, similar to the existing World Computer Sculpture Garden website.

## Installation

```bash
# Clone the repository (if you haven't already)
cd worldcomputersculpturegarden/nfclisbon

# Install dependencies
npm install
```

## Usage

```bash
# Generate a default flower field (2560x1422, 300 flowers, font size 15)
npm start

# Generate with custom options
node generate.js --size=1 --fontSize=15 --count=300 --outputDir=output

# Generate the smaller size
node generate.js --size=2

# Generate with inverted colors (white on black)
node generate.js --inverted

# Run batch generation of multiple variations (different sizes, font sizes, and color modes)
npm run batch
```

### Command Line Options

| Option | Alias | Description | Default |
|--------|-------|-------------|---------|
| --size | -s | Screen size (1 for 2560x1422, 2 for 1336x1422) | 1 |
| --fontSize | -f | Font size for flowers | 15 |
| --count | -c | Number of flowers to generate | 300 |
| --outputDir | -o | Output directory for generated images | "output" |
| --inverted | -i | Use inverted colors (white on black) | false |
| --help | -h | Show help information | - |

## Output

The script will generate PNG files named with the format:
`{width}x{height}_{timestamp}.png`

For example: `2560x1422_1621234567.png`

The images are saved in the specified output directory (default is `./output`).

## Batch Generation

The `batch-generate.js` script generates multiple variations of the flower field with different configurations:

- Both screen sizes: 2560x1422 and 1336x1422
- Font sizes: 15px, 20px, and 25px
- Color modes: normal (black on white) and inverted (white on black)

You can customize the configurations by editing the `configs` array in the `batch-generate.js` file.

## Requirements

- Node.js 14.x or later
- The `canvas` package requires some system dependencies. See [node-canvas installation guide](https://github.com/Automattic/node-canvas#installation) for details.