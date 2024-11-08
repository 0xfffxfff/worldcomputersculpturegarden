import { Config, Context } from "@netlify/functions";
import { ethers } from "ethers";
import { CacheHeaders } from "cdn-cache-control";

const deploymentArtifact = require('../../../contracts/deployments/localhost/Garden.json');

const CACHE_EXPIRATION_TIME = 12;
// const RPC_URL = Netlify.env.get("RPC_URL") || 'https://ethereum-sepolia-rpc.publicnode.com';
const RPC_URL = 'http://localhost:8545';

export default async (req: Request, context: Context) => {
    console.log(req);
    // path with leading slash removed:
    const path = context.url.pathname.slice(1);
    const resource = path.split('/');
    if (resource[resource.length - 1] === '' || resource[resource.length - 1] === "index" || resource[resource.length - 1] === "index.html" || resource[resource.length - 1] === "index.htm") {
        resource.pop();
    }
    console.log("Resource:", resource);
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const contract = new ethers.Contract(deploymentArtifact.address, deploymentArtifact.abi, provider);
    try {
        console.log("Fetching HTML from contract");
        const [statusCode, body, headers] = await contract.request(resource, []);
        // TODO: handle statusCode and use headers
        if (Number(statusCode) === 404) {
            return new Response("Page not found ⚘", { status: 404 });
        } else if (Number(statusCode) !== 200) {
            throw new Error(`Unexpected status code: ${statusCode}`);
        }
        const netlifyHeaders = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
        return new Response(body, { headers: { 'Content-Type': 'text/html; charset=utf-8', ...(netlifyHeaders.toObject()) } });
    } catch (error) {
        console.error("Error fetching HTML from contract:", error);
        return new Response("Error fetching HTML from contract", { status: 500 });
    }
};

export const config: Config = {
  path: "/*"
};
