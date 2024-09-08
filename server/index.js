const express = require('express');
const { ethers } = require('ethers');
const dotenv = require('dotenv');

const deploymentArtifact = require('../contracts/deployments/localhost/Web.json');

dotenv.config();

const app = express();
const port = process.env.PORT || 3333;
const CACHE_EXPIRATION_TIME = 12 * 1000; // 12 seconds
const CACHE_ENABLED = process.env.CACHE_ENABLED === 'false' ? false : true; // Enable/disable cache

let latestHtml = '';  // Store the latest successful HTML response
let lastUpdated = null; // To track when the last update occurred

// Setup provider and contract
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const contractAddress = process.env.CONTRACT_ADDRESS;

// const contractABI = [
//     "function content() public view returns (string memory)"
// ];
const contract = new ethers.Contract(deploymentArtifact.address, deploymentArtifact.abi, provider);

app.get('/', async (req, res) => {
    const now = new Date();
    const cacheValid = lastUpdated && (now - lastUpdated) < CACHE_EXPIRATION_TIME;

    if (CACHE_ENABLED && cacheValid && latestHtml) {
        console.log("Serving cached HTML (still valid)");
        res.setHeader('Content-Type', 'text/html');
        return res.send(latestHtml);
    }

    try {
        console.log("Fetching HTML from contract");
        const htmlString = await contract.content(); // Call the contract method
        latestHtml = htmlString;  // Update the cached HTML
        lastUpdated = now; // Store the time of the update
        res.setHeader('Content-Type', 'text/html');
        res.send(htmlString);  // Return HTML
    } catch (error) {
        console.error("Error fetching HTML from contract:", error);

        // Return the cached HTML in case of an error
        if (latestHtml) {
            console.log("Serving cached HTML due to error");
            res.setHeader('Content-Type', 'text/html');
            res.send(latestHtml);
        } else {
            res.status(500).send("Error fetching HTML and no cached content available.");
        }
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
