#!/usr/bin/env node

const { createCanvas } = require('canvas');
const fs = require('fs-extra');
const path = require('path');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

// Parse command line arguments
const argv = yargs(hideBin(process.argv))
  .option('size', {
    alias: 's',
    description: 'Screen size to generate (1 for 2560x1422, 2 for 1336x1422)',
    type: 'number',
    default: 1
  })
  .option('fontSize', {
    alias: 'f',
    description: 'Font size for flowers',
    type: 'number',
    default: 15
  })
  .option('count', {
    alias: 'c',
    description: 'Number of flowers to generate',
    type: 'number',
    default: 300
  })
  .option('outputDir', {
    alias: 'o',
    description: 'Output directory for generated images',
    type: 'string',
    default: 'output'
  })
  .option('inverted', {
    alias: 'i',
    description: 'Use inverted colors (white on black)',
    type: 'boolean',
    default: false
  })
  .help()
  .alias('help', 'h')
  .argv;

// Configuration
const SIZES = {
  1: { width: 2560, height: 1422 },
  2: { width: 1336, height: 1422 }
};

const config = {
  width: SIZES[argv.size].width,
  height: SIZES[argv.size].height,
  fontSize: argv.fontSize,
  flowerCount: argv.count,
  outputDir: argv.outputDir,
  inverted: argv.inverted,
  flowerChar: '⚘',
  fontFamily: 'Courier New, Courier, monospace'
};

// Function to create a seeded random number generator (same as in rhizomeworld)
function createSeededRandom(seed) {
  return function() {
    seed = (seed * 16807) % 2147483647;
    return (seed - 1) / 2147483646;
  };
}

// Grid noise function from the rhizomeworld implementation
function gridNoise(x, y, seed) {
  let n = (1619 * x + 31337 * y + 1013 * seed) & 0x7fffffff;
  n = ((n >> 13) ^ n);
  
  // Use BigInt for large number calculations
  let bigN = BigInt(n);
  bigN = bigN * (bigN * BigInt(60493) + BigInt(19990303)) + BigInt(1376312589);
  
  // Convert to binary and slice the last 31 bits
  const binaryStr = bigN.toString(2);
  const last31Bits = binaryStr.slice(-31);
  
  // Convert back to decimal and normalize to the range [-1, 1]
  n = parseInt(last31Bits, 2);
  return 1 - n / 1073741824;
}

// Create an empty grid
function createEmptyGrid(width, height) {
  const grid = [];
  for (let y = 0; y < height; y++) {
    const row = [];
    for (let x = 0; x < width; x++) {
      row.push(' ');
    }
    grid.push(row);
  }
  return grid;
}

// Place flowers using random placement with collision detection
function placeFlowersRandomly(grid, count) {
  // Fixed seed for reproducibility
  const fixedSeed = 12345;
  const random = createSeededRandom(fixedSeed);
  
  const positions = [];
  let placed = 0;
  let attempts = 0;
  const maxAttempts = count * 100; // Plenty of attempts
  
  const gridWidth = grid[0].length;
  const gridHeight = grid.length;
  
  console.log(`Attempting to place ${count} flowers...`);
  
  // Try to place all flowers
  while (placed < count && attempts < maxAttempts) {
    attempts++;
    
    // Get random position
    const x = Math.floor(random() * gridWidth);
    const y = Math.floor(random() * gridHeight);
    
    // For this grid cell, calculate a noise value
    const noiseVal = gridNoise(x, y, 0xf);
    
    // Use a fixed threshold that ensures we get enough flowers
    const threshold = 0.3;
    
    // Only place if position is valid according to noise and grid
    if (Math.abs(noiseVal) > threshold && grid[y][x] === ' ') {
      // Place flower in grid
      grid[y][x] = config.flowerChar;
      positions.push({ x, y });
      placed++;
    }
  }
  
  console.log(`Placed ${placed} flowers out of ${count} requested`);
  return positions;
}

// Generate flower field image
async function generateFlowerField() {
  // Create canvas with the specified dimensions
  const canvas = createCanvas(config.width, config.height);
  const ctx = canvas.getContext('2d');
  
  // Set background color
  if (config.inverted) {
    ctx.fillStyle = '#000000';
  } else {
    ctx.fillStyle = '#FFFFFF';
  }
  ctx.fillRect(0, 0, config.width, config.height);
  
  // Calculate grid dimensions based on font size
  const charWidth = config.fontSize;
  const charHeight = config.fontSize * 1.2;
  
  const gridWidth = Math.floor(config.width / charWidth);
  const gridHeight = Math.floor(config.height / charHeight);
  
  console.log(`Grid size: ${gridWidth} x ${gridHeight}`);
  
  // Create grid and place flowers
  const grid = createEmptyGrid(gridWidth, gridHeight);
  const flowerPositions = placeFlowersRandomly(grid, config.flowerCount);
  
  // Draw flowers on canvas
  ctx.font = `${config.fontSize}px ${config.fontFamily}`;
  if (config.inverted) {
    ctx.fillStyle = '#FFFFFF';
  } else {
    ctx.fillStyle = '#000000';
  }
  
  flowerPositions.forEach(pos => {
    ctx.fillText(
      config.flowerChar,
      pos.x * charWidth,
      (pos.y + 1) * charHeight // +1 to account for baseline
    );
  });
  
  // Generate filename with timestamp and resolution
  const timestamp = Math.floor(Date.now() / 1000);
  const resolution = `${config.width}x${config.height}`;
  const filename = `${resolution}_${timestamp}.png`;
  
  // Create output directory if it doesn't exist
  await fs.ensureDir(config.outputDir);
  
  // Save the image
  const outputPath = path.join(config.outputDir, filename);
  const out = fs.createWriteStream(outputPath);
  const stream = canvas.createPNGStream();
  stream.pipe(out);
  
  return new Promise((resolve, reject) => {
    out.on('finish', () => {
      console.log(`Generated image saved to: ${outputPath}`);
      resolve(outputPath);
    });
    out.on('error', reject);
  });
}

// Main function
async function main() {
  try {
    const sizeType = argv.size === 1 ? '2560x1422' : '1336x1422';
    const colorMode = config.inverted ? 'inverted' : 'normal';
    
    console.log(`Generating ${config.flowerCount} flowers at ${sizeType} with font size ${config.fontSize} in ${colorMode} mode`);
    
    const outputPath = await generateFlowerField();
    console.log('Generation complete!');
    console.log(`Saved to: ${outputPath}`);
  } catch (error) {
    console.error('Error generating flower field:', error);
    process.exit(1);
  }
}

// Run the main function
main();