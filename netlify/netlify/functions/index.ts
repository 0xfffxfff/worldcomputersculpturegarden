import { Config, Context } from "@netlify/functions";
import { ethers } from "ethers";
import { CacheHeaders } from "cdn-cache-control";
import { getStore } from "@netlify/blobs";

const deploymentArtifact = require('../../../contracts/deployments/sepolia/Garden.json');

const CACHE_EXPIRATION_TIME = 12; // Seconds
const RPC_URL = Netlify.env.get("RPC_URL") || 'https://ethereum-sepolia-rpc.publicnode.com';
// const RPC_URL = 'http://localhost:8545';

export default async (req: Request, context: Context) => {
    const cache = getStore("cache");
    const path = context.url.pathname.slice(1);
    const resource = path.split('/');
    if (resource[resource.length - 1] === '' || resource[resource.length - 1] === "index" || resource[resource.length - 1] === "index.html" || resource[resource.length - 1] === "index.htm") {
        resource.pop();
    }

    const cacheInfoRaw = await cache.get(`path:${path}`, { type: "json" });
    const cacheInfo = { timestamp: cacheInfoRaw?.timestamp || 0, html: cacheInfoRaw?.html || "", statusCode: cacheInfoRaw?.statusCode || 0 };

    if (cacheInfo.html && cacheInfo.timestamp > Date.now() - CACHE_EXPIRATION_TIME * 1000) {
        console.log("Using cached HTML");
        const netlifyHeaders = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
        return new Response(cacheInfo.html, { status: cacheInfo.statusCode, headers: { 'Content-Type': 'text/html; charset=utf-8', ...(netlifyHeaders.toObject()) } });
    }

    try {
        // const provider = new ethers.JsonRpcProvider(RPC_URL);
        const provider = ethers.getDefaultProvider('sepolia');
        const contract = new ethers.Contract(deploymentArtifact.address, deploymentArtifact.abi, provider);
        console.log("Fetching HTML from contract");
        const [statusCode, body, headers] = await contract.request(resource, []);
        // TODO: handle statusCode and use headers
        if (Number(statusCode) === 404) {
            cache.setJSON(`path:${path}`, { timestamp: Date.now(), html: "", statusCode: 404 });
            return new Response("Page not found ⚘", { status: 404 });
        } else if (Number(statusCode) !== 200) {
            cache.setJSON(`path:${path}`, { timestamp: Date.now(), html: "", statusCode: Number(statusCode) });
            throw new Error(`Unexpected status code: ${statusCode}`);
        }
        cache.setJSON(`path:${path}`, { timestamp: Date.now(), html: body, statusCode: Number(statusCode) });
        const netlifyHeaders = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
        return new Response(body, { status: statusCode, headers: { 'Content-Type': 'text/html; charset=utf-8', ...(netlifyHeaders.toObject()) } });
    } catch (error) {
        console.error("Error fetching HTML from contract:", error);
        if (cacheInfo.html && cacheInfo.timestamp > Date.now() - CACHE_EXPIRATION_TIME * 1000) {
            console.log("Using cached HTML");
            const netlifyHeaders = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
            return new Response(cacheInfo.html, { status: cacheInfo.statusCode, headers: { 'Content-Type': 'text/html; charset=utf-8', ...(netlifyHeaders.toObject()) } });
        }
        return new Response("Error fetching HTML from contract", { status: 500 });
    }
};

export const config: Config = {
  path: "/*"
};
