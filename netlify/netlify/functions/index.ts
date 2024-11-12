import { Config, Context } from "@netlify/functions";
import { ethers } from "ethers";
import { CacheHeaders, ONE_YEAR } from "cdn-cache-control";
import { getStore } from "@netlify/blobs";

const deploymentArtifact = require('../../../contracts/deployments/mainnet/Garden.json');

const CACHE_EXPIRATION_TIME = 12; // Seconds
// const RPC_URL = Netlify.env.get("RPC_URL") || 'https://ethereum-sepolia-rpc.publicnode.com';
// const RPC_URL = 'http://localhost:8545';

export default async (req: Request, context: Context) => {
    const cache = getStore("cache");
    const path = context.url.pathname.slice(1);
    const resource = path.split('/');
    if (resource[resource.length - 1] === '' || resource[resource.length - 1] === "index" || resource[resource.length - 1] === "index.html" || resource[resource.length - 1] === "index.htm") {
        resource.pop();
    }
    const cacheKey = `${deploymentArtifact.address}path:${path}`;

    const cacheInfoRaw = await cache.get(cacheKey, { type: "json" });
    const cacheInfo = { timestamp: cacheInfoRaw?.timestamp || 0, response: cacheInfoRaw?.response || "", statusCode: cacheInfoRaw?.statusCode || 0 };

    const isFlower = path.includes("flower");

    if (isFlower && cacheInfo.response) {
        console.log("Using cached response for flower");
        const netlifyHeaders = new CacheHeaders().ttl(ONE_YEAR);
        return new Response(cacheInfo.response, { status: cacheInfo.statusCode, headers: { 'Content-Type': 'application/json', ...(netlifyHeaders.toObject()) } });
    }

    if (cacheInfo.response && cacheInfo.timestamp > Date.now() - CACHE_EXPIRATION_TIME * 1000) {
        console.log("Using cached HTML");
        const netlifyHeaders = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
        return new Response(cacheInfo.response, { status: cacheInfo.statusCode, headers: { 'Content-Type': 'text/html; charset=utf-8', ...(netlifyHeaders.toObject()) } });
    }

    try {
        // const provider = new ethers.JsonRpcProvider(RPC_URL);
        const provider = ethers.getDefaultProvider('mainnet');
        const contract = new ethers.Contract(deploymentArtifact.address, deploymentArtifact.abi, provider);
        console.log("Fetching HTML from contract");
        let [statusCode, body, headers] = await contract.request(resource, []);
        if (Number(statusCode) === 404) {
            console.log("Page not found");
            cache.setJSON(cacheKey, { timestamp: Date.now(), response: "", statusCode: 404 });
            return new Response("Page not found ⚘", { status: 404 });
        } else if (Number(statusCode) !== 200) {
            cache.setJSON(cacheKey, { timestamp: Date.now(), response: "", statusCode: Number(statusCode) });
            throw new Error(`Unexpected status code: ${statusCode}`);
        }

        if (isFlower) {
            console.log("Resolving planter address");
            try {
                const jsonBody = JSON.parse(body);
                const address = jsonBody.planter;
                console.log(address);
                if (!ethers.isAddress(address)) throw new Error("Invalid address");
                const name = await provider.lookupAddress(address);
                if (name) jsonBody.planter = name;
                console.log(`Resolved planter ${address} to name ${jsonBody.planter}`);
                body = JSON.stringify(jsonBody);
            } catch (error) {
                console.error(error);
            }
        }

        cache.setJSON(cacheKey, { timestamp: Date.now(), response: body, statusCode: Number(statusCode) });
        const netlifyHeaders = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
        return new Response(body, { status: statusCode, headers: { 'Content-Type': isFlower ? 'application/json' : 'text/html; charset=utf-8', ...(netlifyHeaders.toObject()) } });
    } catch (error) {
        console.error("Error fetching HTML from contract:", error);
        if (cacheInfo.response && cacheInfo.timestamp > Date.now() - CACHE_EXPIRATION_TIME * 1000) {
            console.log("Using cached HTML");
            const netlifyHeaders = new CacheHeaders().ttl(CACHE_EXPIRATION_TIME);
            return new Response(cacheInfo.response, { status: cacheInfo.statusCode, headers: { 'Content-Type': 'text/html; charset=utf-8', ...(netlifyHeaders.toObject()) } });
        }
        return new Response("Error fetching HTML from contract", { status: 500 });
    }
};

export const config: Config = {
  path: "/*"
};
