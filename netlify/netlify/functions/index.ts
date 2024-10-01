import { Config, Context } from "@netlify/functions";
import { ethers } from "ethers";
import { CacheHeaders } from "cdn-cache-control";

const deploymentArtifact = require('../../../contracts/deployments/sepolia/Garden.json');

const CACHE_EXPIRATION_TIME = 12;
const RPC_URL = Netlify.env.get("RPC_URL") || 'https://ethereum-sepolia-rpc.publicnode.com';

export default async (req: Request, context: Context) => {
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const contract = new ethers.Contract(deploymentArtifact.address, deploymentArtifact.abi, provider);
    try {
        console.log("Fetching HTML from contract");
        const htmlString = await contract.html(); // Call the contract method
        const headers = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
        console.log(htmlString)
        return new Response(htmlString, { headers: { 'Content-Type': 'text/html; charset=utf-8', ...(headers.toObject()) } });
    } catch (error) {
        console.error("Error fetching HTML from contract:", error);
        return new Response("Error fetching HTML from contract", { status: 500 });
    }
};

export const config: Config = {
  path: "/"
};
