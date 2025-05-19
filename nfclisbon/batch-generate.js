#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

// Configuration
const configs = [
  // Large screen size (2560x1422)
  { size: 1, fontSize: 15, count: 300, inverted: false },
  { size: 1, fontSize: 20, count: 300, inverted: false },
  { size: 1, fontSize: 25, count: 300, inverted: false },
  
  // Small screen size (1336x1422)
  { size: 2, fontSize: 15, count: 300, inverted: false },
  { size: 2, fontSize: 20, count: 300, inverted: false },
  { size: 2, fontSize: 25, count: 300, inverted: false },
  
  // Inverted versions
  { size: 1, fontSize: 15, count: 300, inverted: true },
  { size: 2, fontSize: 15, count: 300, inverted: true },
];

// Function to run the generator with specific config
function runGenerator(config) {
  return new Promise((resolve, reject) => {
    const args = [
      path.join(__dirname, 'generate.js'),
      `--size=${config.size}`,
      `--fontSize=${config.fontSize}`,
      `--count=${config.count}`
    ];
    
    if (config.inverted) {
      args.push('--inverted');
    }
    
    console.log(`Running: node ${args.join(' ')}`);
    
    const process = spawn('node', args);
    
    process.stdout.on('data', (data) => {
      console.log(data.toString());
    });
    
    process.stderr.on('data', (data) => {
      console.error(data.toString());
    });
    
    process.on('close', (code) => {
      if (code === 0) {
        console.log(`Generation complete for size=${config.size}, fontSize=${config.fontSize}`);
        resolve();
      } else {
        reject(new Error(`Process exited with code ${code}`));
      }
    });
  });
}

// Run all configurations sequentially
async function main() {
  console.log(`Starting batch generation of ${configs.length} variations...`);
  
  for (let i = 0; i < configs.length; i++) {
    const config = configs[i];
    console.log(`\nGenerating variation ${i + 1}/${configs.length}:`);
    console.log(`- Size: ${config.size === 1 ? '2560x1422' : '1336x1422'}`);
    console.log(`- Font size: ${config.fontSize}`);
    console.log(`- Color mode: ${config.inverted ? 'inverted' : 'normal'}`);
    
    try {
      await runGenerator(config);
    } catch (error) {
      console.error(`Error generating variation ${i + 1}:`, error);
    }
  }
  
  console.log('\nBatch generation complete!');
}

// Run the main function
main();